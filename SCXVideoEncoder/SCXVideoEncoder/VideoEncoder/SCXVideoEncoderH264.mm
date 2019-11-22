//
//  SCXVideoEncoderH264.m
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXVideoEncoderH264.h"
#import <VideoToolbox/VideoToolbox.h>
#import "SCXCodecSpecificInfoH264.h"
#import "helpers.h"
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

@implementation SCXVideoEncoderH264{
    SCXVideoCodecInfo *_codecInfo;
    SCXH264PacketizationMode _packetizationMode;
    int32_t _width;
    int32_t _height;
    SCXVideoCodecMode _mode;
    uint32_t _targetBitrateBps ;
    uint32_t _encoderBitrateBps ;
    VTCompressionSessionRef *_compressionSession;
    uint32_t _encoderFrameRate;
    uint32_t _maxFrameRate;
}

-(instancetype)initWithVideoCodecInfo:(SCXVideoCodecInfo *)info{
    if (self = [super init]) {
        _codecInfo = info;
         _packetizationMode = SCXH264PacketizationModeNonInterleaved;
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
@end
