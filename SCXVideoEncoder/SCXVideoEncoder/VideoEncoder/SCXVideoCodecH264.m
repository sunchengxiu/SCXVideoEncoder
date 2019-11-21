//
//  SCXVideoCodecH264.m
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXVideoCodecH264.h"
#import <VideoToolbox/VideoToolbox.h>
@interface SCXVideoCodecH264()

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
    
};

@implementation SCXVideoCodecH264

-(instancetype)initWithVideoCodecInfo:(SCXVideoCodecInfo *)info{
    if (self = [super init]) {
        
    }
    return self;
}
@end
