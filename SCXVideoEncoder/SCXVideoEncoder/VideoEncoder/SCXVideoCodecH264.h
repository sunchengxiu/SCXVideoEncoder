//
//  SCXVideoCodecH264.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCXVideoEncoder.h"
#import "SCXEncodedImage.h"
#import "SCXCodecSpecificInfo.h"
#import "SCXRtpFragmentationHeader.h"
#import "SCXVideoEncoderSettings.h"
#import "SCXVideoFrame.h"
NS_ASSUME_NONNULL_BEGIN
typedef BOOL (^SCXVideoEncoderCallback)(SCXEncodedImage *frame , id <SCXCodecSpecificInfo> info , SCXRtpFragmentationHeader *header);
@interface SCXVideoCodecH264 : NSObject<SCXVideoEncoder>
- (void)setCallback:(SCXVideoEncoderCallback)callback;
- (NSInteger)startEncoderWithSettings:(SCXVideoEncoderSettings *)settings numberOfCores:(int)cores;
- (NSInteger)releaseEncoder;
- (NSInteger)encode:(SCXVideoFrame *)frame codecSpecificInfo:(nullable id<SCXCodecSpecificInfo>)info frameTypes:(NSArray <NSNumber *>*)frameTypes;
- (int)setBitrate:(uint32_t)bitrateKbit frameRate:(uint32_t)frameRate;
- (NSString *)implementionName;
@end

NS_ASSUME_NONNULL_END
