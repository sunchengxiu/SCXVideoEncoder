//
//  SCXVideoEncoder.h
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
#import "SCXVideoEncoderQpThresholds.h"
NS_ASSUME_NONNULL_BEGIN
typedef BOOL (^SCXVideoEncoderCallback)(SCXEncodedImage *frame , id <SCXCodecSpecificInfo> info , SCXRtpFragmentationHeader *header);
@protocol SCXVideoEncoder <NSObject>
- (void)setCallback:(SCXVideoEncoderCallback)callback;
- (NSInteger)startEncoderWithSettings:(SCXVideoEncoderSettings *)settings numberOfCores:(int)cores;
- (NSInteger)releaseEncoder;
- (NSInteger)encode:(SCXVideoFrame *)frame codecSpecificInfo:(nullable id<SCXCodecSpecificInfo>)info frameTypes:(NSArray <NSNumber *>*)frameTypes;
- (int)setBitrate:(uint32_t)bitrateKbit frameRate:(uint32_t)frameRate;
- (NSString *)implementionName;

/** Returns QP scaling settings for encoder. The quality scaler adjusts the resolution in order to
 *  keep the QP from the encoded images within the given range. Returning nil from this function
 *  disables quality scaling. */
- (nullable SCXVideoEncoderQpThresholds *)scalingSettings;
@end

NS_ASSUME_NONNULL_END
