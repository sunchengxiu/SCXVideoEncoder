//
//  SCXEncodedImage.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCXVideoFrame.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SCXFrameType) {
  SCXFrameTypeEmptyFrame = 0,
  SCXFrameTypeAudioFrameSpeech = 1,
  SCXFrameTypeAudioFrameCN = 2,
  SCXFrameTypeVideoFrameKey = 3,
  SCXFrameTypeVideoFrameDelta = 4,
};
typedef NS_ENUM(NSUInteger, SCXVideoContentType) {
  SCXVideoContentTypeUnspecified,
  SCXVideoContentTypeScreenshare,
};
@interface SCXEncodedImage : NSObject
@property(nonatomic, strong) NSData *buffer;
@property(nonatomic, assign) int32_t encodedWidth;
@property(nonatomic, assign) int32_t encodedHeight;
@property(nonatomic, assign) uint32_t timeStamp;
@property(nonatomic, assign) int64_t captureTimeMs;
@property(nonatomic, assign) int64_t ntpTimeMs;
@property(nonatomic, assign) uint8_t flags;
@property(nonatomic, assign) int64_t encodeStartMs;
@property(nonatomic, assign) int64_t encodeFinishMs;
@property(nonatomic, assign) SCXFrameType frameType;
@property(nonatomic, assign) SCXVideoRotation rotation;
@property(nonatomic, assign) BOOL completeFrame;
@property(nonatomic, strong) NSNumber *qp;
@property(nonatomic, assign) SCXVideoContentType contentType;
@end

NS_ASSUME_NONNULL_END
