//
//  SCXFileVideoCapturer.m
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/26.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXFileVideoCapturer.h"
#import "SCXCVPixelBuffer.h"
#import "SCXVideoFrame.h"
NSString *const kRTCFileVideoCapturerErrorDomain = @"com.rongcloud.scx";
typedef NS_ENUM(NSInteger , SCXFileVideoCaptureErrorCode) {
    SCXFileVideoCaptureErrorCode_CapturerRunning = 2000,
    SCXFileVideoCaptureErrorCode_FileNotFound
};
typedef NS_ENUM(NSInteger , SCXFileVideoCaptureStatus) {
    SCXFileVideoCaptureStatus_NotInitialized,
    SCXFileVideoCaptureStatus_Started,
    SCXFileVideoCaptureStatus_Stoped
};
@implementation SCXFileVideoCapturer{
    SCXFileVideoCaptureStatus _status;
    CMTime _lastPresentationTime;
    NSURL *_fileURL;
    AVAssetReader *_reader;
    AVAssetReaderTrackOutput *_outTrack;
    dispatch_queue_t _frameQueue;
}
-(void)startCapturingWithFileName:(NSString *)fileName onError:(SCXFileVideoCapturerErrorBlock)errorBlock{
    if (_status == SCXFileVideoCaptureStatus_Started) {
        NSError *error = [NSError errorWithDomain:kRTCFileVideoCapturerErrorDomain code:SCXFileVideoCaptureErrorCode_CapturerRunning userInfo:@{NSUnderlyingErrorKey : @"Capturer has been started."}];
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    } else {
        _status = SCXFileVideoCaptureStatus_Started;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [self pathForFileName:fileName];
        if (!filePath) {
            NSString *errorStr = [NSString stringWithFormat:@"file %@ not found in bundle",fileName];
            NSError *error = [NSError errorWithDomain:kRTCFileVideoCapturerErrorDomain code:SCXFileVideoCaptureErrorCode_FileNotFound userInfo:@{NSUnderlyingErrorKey:errorStr}];
            if (errorBlock) {
                errorBlock(error);
            }
            return ;
        }
        self->_lastPresentationTime = CMTimeMake(0, 0);
        self->_fileURL = [NSURL fileURLWithPath:filePath];
        [self setupReaderOnErrorBlock:errorBlock];
    });
}
- (void)setupReaderOnErrorBlock:(SCXFileVideoCapturerErrorBlock)errorBlock{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_fileURL options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    _reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if (error) {
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    NSDictionary *options = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    _outTrack = [[AVAssetReaderTrackOutput alloc] initWithTrack:tracks.firstObject outputSettings:options];
    [_reader addOutput:_outTrack];
    [_reader startReading];
    
    [self readNextBuffer];
}
- (void)readNextBuffer{
    if (_status == SCXFileVideoCaptureStatus_Stoped) {
        [_reader cancelReading];
        _reader = nil;
        return;
    }
    if (_reader.status == AVAssetReaderStatusCompleted) {
        [_reader cancelReading];
        _reader = nil;
        [self setupReaderOnErrorBlock:nil];
        return;
    }
    CMSampleBufferRef sampleBuffer = [_outTrack copyNextSampleBuffer];
    if (!sampleBuffer) {
        [self readNextBuffer];
        return;
    }
    if (CMSampleBufferGetNumSamples(sampleBuffer) != 1 || !CMSampleBufferIsValid(sampleBuffer) || !CMSampleBufferDataIsReady(sampleBuffer)) {
        CFRelease(sampleBuffer);
        return;
    }
    [self publishSampleBuffer:sampleBuffer];
}
- (void)publishSampleBuffer:(CMSampleBufferRef )sampleBuffer{
    CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    Float64 presentationDiff = CMTimeGetSeconds(CMTimeSubtract(presentationTime, _lastPresentationTime));
    _lastPresentationTime = presentationTime;
    int64_t presentationDiffRound = lroundf(presentationDiff * NSEC_PER_SEC);
    __block dispatch_source_t timer = [self createStrictTimer];
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, presentationDiffRound), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(timer, ^{
       
        dispatch_source_cancel(timer);
        timer = nil;
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (!pixelBuffer) {
            CFRelease(pixelBuffer);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self readNextBuffer];
            });
            return ;
        }
        SCXCVPixelBuffer *cvpixelBuffer = [[SCXCVPixelBuffer alloc] initWithPixelBuffer:pixelBuffer];
        NSTimeInterval timestampSecond = CACurrentMediaTime();
        int64_t timestampNs = lroundf(timestampSecond * NSEC_PER_SEC);;
        SCXVideoFrame *videoFrame = [[SCXVideoFrame alloc] initWithPixelBuffer:cvpixelBuffer timeStampNs:timestampNs];
        
        CFRelease(sampleBuffer);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self readNextBuffer];
        });
        if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didCaptureVideoFrame:)]) {
            [self.delegate capture:self didCaptureVideoFrame:videoFrame];
        }
    });
    
    dispatch_activate(timer);
    
}
- (NSString *)pathForFileName:(NSString *)fileName{
    NSArray *nameComponents = [fileName componentsSeparatedByString:@"."];
    if (nameComponents.count != 2) {
        return nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:nameComponents[0] ofType:nameComponents[1]];
    return path;
}
- (dispatch_queue_t)frameQueue{
    if (!_frameQueue) {
        _frameQueue = dispatch_queue_create("com.rongcloud.scx.filecapture.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_frameQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    }
    return _frameQueue;
}
- (dispatch_source_t)createStrictTimer{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, DISPATCH_TIMER_STRICT, [self frameQueue]);
    return timer;
}
-(void)stopCapture{
    _status = SCXFileVideoCaptureStatus_Stoped;
}
-(void)dealloc{
    [self stopCapture];
}
@end
