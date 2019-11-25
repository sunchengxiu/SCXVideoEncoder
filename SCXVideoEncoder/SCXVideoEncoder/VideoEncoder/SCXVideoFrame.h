//
//  SCXVideoFrame.h
//  SCXMediaService
//
//  Created by 孙承秀 on 2019/11/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SCXVideoFrameBuffer.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SCXVideoRotation) {
  SCXVideoRotation_0 = 0,
  SCXVideoRotation_90 = 90,
  SCXVideoRotation_180 = 180,
  SCXVideoRotation_270 = 270,
};
@protocol SCXVideoFrameBuffer;
@interface SCXVideoFrame : NSObject

@property(nonatomic, readonly) int width;

@property(nonatomic, readonly) int height;
@property(nonatomic, readonly) int64_t timeStampNs;
@property(nonatomic, readonly) SCXVideoRotation rotation;
@property(nonatomic, assign) int32_t timeStamp;
@property(nonatomic, readonly) id<SCXVideoFrameBuffer> buffer;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype) new NS_UNAVAILABLE;
- (instancetype)initWithPixelBuffer:(id<SCXVideoFrameBuffer>)pixelBuffer timeStampNs:(int64_t)timeStampns;
@end

NS_ASSUME_NONNULL_END
