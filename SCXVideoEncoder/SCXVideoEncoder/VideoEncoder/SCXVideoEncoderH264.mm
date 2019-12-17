//
//  SCXVideoEncoderH264.m
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//
#import <VideoToolbox/VideoToolbox.h>
#import "SCXVideoEncoderH264.h"
#import "SCXCodecSpecificInfoH264.h"
#import "helpers.h"

#import "SCXVideoEncoderErrorCodes.h"
#import "SCXCVPixelBuffer.h"

constexpr int64_t kNumNanosecsPerMillisec = 1000000;
@interface SCXVideoEncoderH264()

- (void)frameWasEncoded:(OSStatus)status
                  flags:(VTEncodeInfoFlags)infoFlags
           sampleBuffer:(CMSampleBufferRef)sampleBuffer
      codecSpecificInfo:(id <SCXCodecSpecificInfo>)codecSpecificInfo
                  width:(int32_t)width
                 height:(int32_t)height
           renderTimeMs:(int64_t)renderTimeMs
              timeStamp:(uint32_t)timeStamp
               rotation:(SCXVideoRotation)rotation;


@end
// The ratio between kVTCompressionPropertyKey_DataRateLimits and
// kVTCompressionPropertyKey_AverageBitRate. The data rate limit is set higher
// than the average bit rate to avoid undershooting the target.
const float kLimitToAverageBitRateFactor = 1.5f;
// These thresholds deviate from the default h264 QP thresholds, as they
// have been found to work better on devices that support VideoToolbox
const int kLowH264QpThreshold = 28;
const int kHighH264QpThreshold = 39;

const OSType kNV12PixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
struct SCXFrameEncodeParams {
    SCXFrameEncodeParams(SCXVideoEncoderH264 *e,
                         SCXCodecSpecificInfoH264 *csi,
                         int32_t w,
                         int32_t h,
                         int64_t rtms,
                         uint32_t ts,
                         SCXVideoRotation r)
    : encoder(e) , width(w) , height(h) , render_time_ms(rtms) , timeStamp(ts) , rotation(r){
        if (csi) {
            codecSpecificInfoH264 = csi;
        } else {
            codecSpecificInfoH264 = [[SCXCodecSpecificInfoH264 alloc] init];
        }
    }
    
    SCXVideoEncoderH264 *encoder;
    SCXCodecSpecificInfoH264 *codecSpecificInfoH264;
    int32_t width;
    int32_t height;
    int64_t render_time_ms;
    uint32_t timeStamp;
    SCXVideoRotation rotation;
};
void compressionOutputCallback(void *encoder,
                               void *params,
                               OSStatus status,
                               VTEncodeInfoFlags infoFlags,
                               CMSampleBufferRef sampleBuffer){
    if (!params) {
        return;
    }
    std::unique_ptr<SCXFrameEncodeParams> encodeParams(reinterpret_cast<SCXFrameEncodeParams *>(params));
    [encodeParams->encoder frameWasEncoded:status flags:infoFlags sampleBuffer:sampleBuffer codecSpecificInfo:encodeParams->codecSpecificInfoH264 width:encodeParams->width height:encodeParams->height renderTimeMs:encodeParams->render_time_ms timeStamp:encodeParams->timeStamp rotation:encodeParams->rotation];
    
}
@implementation SCXVideoEncoderH264{
    SCXVideoCodecInfo *_codecInfo;
    SCXH264PacketizationMode _packetizationMode;
    int32_t _width;
    int32_t _height;
    SCXVideoCodecMode _mode;
    uint32_t _targetBitrateBps ;
    uint32_t _encoderBitrateBps ;
    VTCompressionSessionRef _compressionSession;
    uint32_t _encoderFrameRate;
    uint32_t _maxFrameRate;
    CFStringRef _profileId;
    SCXVideoEncoderCallback _callback;
    CVPixelBufferPoolRef _pixelBufferPool;
}

-(instancetype)initWithVideoCodecInfo:(SCXVideoCodecInfo *)info{
    if (self = [super init]) {
        _codecInfo = info;
        _packetizationMode = SCXH264PacketizationModeNonInterleaved;
        _profileId = kVTProfileLevel_H264_High_3_1;
    }
    if (![info.name isEqualToString:kH264Encoder]) {
        return nil;
    }
    return self;
}
- (NSInteger)startEncoderWithSettings:(SCXVideoEncoderSettings *)settings numberOfCores:(int)cores{
    _width = settings.width;
    _height = settings.height;
    _mode = settings.mode;
    _targetBitrateBps = settings.startBitrate * 1000;
    _maxFrameRate = settings.maxFramerate;
    _encoderFrameRate = _maxFrameRate;
    [self resetCompressionSessionWithPixelFormat:kNV12PixelFormat];
    [self setBitrateBps:_targetBitrateBps frameRate:_maxFrameRate];
    return 1;
}

- (void)setBitrateBps:(uint32_t)bitrateBps frameRate:(uint32_t)frameRate {
    if (_encoderBitrateBps != bitrateBps || _encoderFrameRate != frameRate) {
        [self setEncoderBitrateBps:bitrateBps frameRate:frameRate];
    }
}
- (void)setEncoderBitrateBps:(uint32_t)bitrateBps frameRate:(uint32_t)frameRate{
    if (_compressionSession) {
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, bitrateBps);
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, frameRate);
        int64_t datasLimitBytesPerSecondValue = static_cast<int64_t>(bitrateBps * kLimitToAverageBitRateFactor / 8);
        CFNumberRef bytesPersecond = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &datasLimitBytesPerSecondValue);
        int64_t oneSecondValue = 1;
        CFNumberRef oneSecond = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &oneSecond);
        const void *nums[2] = {bytesPersecond,oneSecond};
        CFArrayRef dataRateLimits = CFArrayCreate(nullptr, nums, 2, &kCFTypeArrayCallBacks);
        OSStatus status = VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_DataRateLimits, dataRateLimits);
        if (bytesPersecond) {
            CFRelease(bytesPersecond);
        }
        if (oneSecond) {
            CFRelease(oneSecond);
        }
        if (dataRateLimits) {
            CFRelease(dataRateLimits);
        }
        if (status != noErr) {
            NSLog(@"setEncoderBitrateBps error : %@",@(status));
        }
        _encoderFrameRate = frameRate;
        _encoderBitrateBps = bitrateBps;
    }
}
-(void)frameWasEncoded:(OSStatus)status flags:(VTEncodeInfoFlags)infoFlags sampleBuffer:(CMSampleBufferRef)sampleBuffer codecSpecificInfo:(id<SCXCodecSpecificInfo>)codecSpecificInfo width:(int32_t)width height:(int32_t)height renderTimeMs:(int64_t)renderTimeMs timeStamp:(uint32_t)timeStamp rotation:(SCXVideoRotation)rotation{
    if (status != noErr) {
        return;
    }
    if (infoFlags & kVTEncodeInfo_FrameDropped) {
        return;
    }
    BOOL isKeyFrame = NO;
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, 0);
    if (attachments != nullptr && CFArrayGetCount(attachments)) {
        CFDictionaryRef attachment = static_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(attachments, 0)) ;
        isKeyFrame = !CFDictionaryContainsKey(attachment, kCMSampleAttachmentKey_NotSync);
    }
    CMBlockBufferRef block_buffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    CMBlockBufferRef contiguous_buffer = nullptr;
    if (!CMBlockBufferIsRangeContiguous(block_buffer, 0, 0)) {
        status = CMBlockBufferCreateContiguous(
                                               nullptr, block_buffer, nullptr, nullptr, 0, 0, 0, &contiguous_buffer);
        if (status != noErr) {
            return;
        }
    } else {
        contiguous_buffer = block_buffer;
        CFRetain(contiguous_buffer);
        block_buffer = nullptr;
    }
    size_t block_buffer_size = CMBlockBufferGetDataLength(contiguous_buffer);
    NSLog(@"reportEncodedImage %d %zu %lld",isKeyFrame , block_buffer_size,renderTimeMs * 1000LL);
}
-(NSInteger)encode:(SCXVideoFrame *)frame codecSpecificInfo:(id<SCXCodecSpecificInfo>)info frameTypes:(NSArray<NSNumber *> *)frameTypes{
    if ( !_compressionSession) {
        return SCX_VIDEO_CODEC_UNINITIALIZED;
    }
    BOOL isKeyFrameRequired = NO;
    _pixelBufferPool = VTCompressionSessionGetPixelBufferPool(_compressionSession);
    if ([self resetCompressionSessionIfNeededWithFrame:frame]) {
        isKeyFrameRequired = YES;
    }
    CVPixelBufferRef pixelBuffer = nullptr;
    if ([frame.buffer isKindOfClass:[SCXCVPixelBuffer class]]) {
        SCXCVPixelBuffer *selfPixelBuffer = (SCXCVPixelBuffer *)frame.buffer;
        if (selfPixelBuffer) {
            pixelBuffer = selfPixelBuffer.pixelBuffer;
            CVBufferRetain(pixelBuffer);
        }
    }
    if (!pixelBuffer) {
        pixelBuffer = CreatePixelBuffer(_pixelBufferPool);
        if (!pixelBuffer) {
            return SCX_VIDEO_CODEC_ERROR;
        }
    }
    if (!isKeyFrameRequired && frameTypes) {
        for (NSNumber *type in frameTypes) {
            if ((SCXFrameType)type.intValue == SCXFrameTypeVideoFrameKey) {
                isKeyFrameRequired = YES;
                break;
            }
        }
    }
    CMTime pts = CMTimeMake(frame.timeStampNs / kNumNanosecsPerMillisec, 1000);
    CFDictionaryRef framePropertys = nullptr;
    if (isKeyFrameRequired) {
        CFTypeRef keys[] = {kVTEncodeFrameOptionKey_ForceKeyFrame};
        CFTypeRef values[] = {kCFBooleanTrue};
        framePropertys = CreateCFTypeDictionary(keys, values, 0);
    }
    std::unique_ptr<SCXFrameEncodeParams> encodeParams;
    encodeParams.reset(new SCXFrameEncodeParams(self,info,_width,_height,frame.timeStampNs / kNumNanosecsPerMillisec , frame.timeStamp,frame.rotation));
    encodeParams->codecSpecificInfoH264.packetizationMode = _packetizationMode;
    OSStatus status = VTCompressionSessionEncodeFrame(_compressionSession, pixelBuffer, pts, kCMTimeInvalid, framePropertys, encodeParams.release(), nullptr);
    if (framePropertys) {
        CFRelease(framePropertys);
    }
    if (pixelBuffer) {
        CVBufferRelease(pixelBuffer);
    }
    if (status != noErr) {
        return SCX_VIDEO_CODEC_ERROR;
    }
    return SCX_VIDEO_CODEC_OK;
}
- (BOOL)resetCompressionSessionIfNeededWithFrame:(SCXVideoFrame *)frame {
    BOOL resetCompressionSession = NO;
    OSType framePixelFormat = [self pixelFormatOfFrame:frame];
    if (_compressionSession) {
        NSDictionary *poolAttributes = (__bridge NSDictionary *)CVPixelBufferPoolGetPixelBufferAttributes(_pixelBufferPool);
        id pixelFormats = [poolAttributes objectForKey:(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey];
        NSArray<NSNumber *> *compressionPixelFormats = nil;
        if ([pixelFormats isKindOfClass:[NSArray class]]) {
            compressionPixelFormats = (NSArray *)pixelFormats;
        } else if ([pixelFormats isKindOfClass:[NSNumber class]]){
            compressionPixelFormats = @[(NSNumber *)pixelFormats];
        }
        if (![compressionPixelFormats containsObject:[NSNumber numberWithLong:framePixelFormat]]) {
            resetCompressionSession = YES;
        }
    } else {
        resetCompressionSession = YES;
    }
    
    if (resetCompressionSession) {
        [self resetCompressionSessionWithPixelFormat:framePixelFormat];
    }
    return resetCompressionSession;
}
- (OSType)pixelFormatOfFrame:(SCXVideoFrame *)frame{
    if ([frame isKindOfClass:[SCXVideoFrame class]]) {
        SCXCVPixelBuffer *pixelBuffer = (SCXCVPixelBuffer *)frame.buffer;
        return CVPixelBufferGetPixelFormatType(pixelBuffer.pixelBuffer);
    }
    return kNV12PixelFormat;
}

- (int)resetCompressionSessionWithPixelFormat:(OSType)framePixelFormat{
    [self destroyCompressionSession];
    const size_t attributeSize = 3;
    CFTypeRef keys[attributeSize] = {
        kCVPixelBufferOpenGLCompatibilityKey,
        kCVPixelBufferIOSurfacePropertiesKey,
        kCVPixelBufferPixelFormatTypeKey
    };
    CFDictionaryRef IOSurfaceValue = CreateCFTypeDictionary(nullptr, nullptr, 0);
    int64_t pixelFormatType = framePixelFormat;
    CFNumberRef pixelFormat = CFNumberCreate(nullptr, kCFNumberLongType, &pixelFormatType);
    CFTypeRef values[attributeSize] = {kCFBooleanTrue,IOSurfaceValue,pixelFormat};
    CFDictionaryRef sourceAttribute = CreateCFTypeDictionary(keys, values, attributeSize);
    if (IOSurfaceValue) {
        CFRelease(IOSurfaceValue);
        IOSurfaceValue = nullptr;
    }
    if (pixelFormat) {
        CFRelease(pixelFormat);
        pixelFormat = nullptr;
    }
    OSStatus status = VTCompressionSessionCreate(nullptr, _width, _height, kCMVideoCodecType_H264, nullptr, sourceAttribute, nullptr, compressionOutputCallback, nullptr, &_compressionSession);
    if (sourceAttribute) {
        CFRelease(sourceAttribute);
        sourceAttribute = nullptr;
    }
    if (status != noErr) {
        return SCX_VIDEO_CODEC_ERROR;
    }
    [self configureCompressionSession];
    return SCX_VIDEO_CODEC_OK;
}
- (void)configureCompressionSession {
    SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_RealTime, true);
    SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, _profileId);
    SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, false);
    [self setEncoderBitrateBps:_targetBitrateBps frameRate:_encoderFrameRate];
    SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, 7200);
    SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, 24);
}
CVPixelBufferRef CreatePixelBuffer(CVPixelBufferPoolRef pixelBufferPool){
    if (!pixelBufferPool) {
        NSLog(@"failed to get pixel buffer pool");
        return nullptr;
    }
    CVPixelBufferRef pixelBuffer ;
    CVReturn ret = CVPixelBufferPoolCreatePixelBuffer(nullptr, pixelBufferPool, &pixelBuffer);
    if (ret != kCVReturnSuccess) {
        NSLog(@"faile to create pixel buffer");
        return nullptr;
    }
    return pixelBuffer;
}
- (void)destroyCompressionSession{
    if (_compressionSession) {
        VTCompressionSessionInvalidate(_compressionSession);
        CFRelease(_compressionSession);
        _compressionSession = nullptr;
    }
}
-(NSInteger)releaseEncoder{
    [self destroyCompressionSession];
    _callback = nullptr;
    return SCX_VIDEO_CODEC_OK;
}
-(void)setCallback:(SCXVideoEncoderCallback)callback{
    _callback = callback;
}

- (nonnull NSString *)implementionName {
    return @"VideoToolbox";
}



@end
