//
//  SCXVideoEncoderSettings.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SCXVideoCodecMode) {
  SCXVideoCodecModeRealtimeVideo,
  SCXVideoCodecModeScreensharing,
};
@interface SCXVideoEncoderSettings : NSObject
@property(nonatomic , copy)NSString *name;
@property(nonatomic , assign)unsigned short width;
@property(nonatomic , assign)unsigned short height;
@property(nonatomic, assign) unsigned int startBitrate;
@property(nonatomic, assign) unsigned int maxBitrate;
@property(nonatomic, assign) unsigned int minBitrate;
@property(nonatomic, assign) uint32_t maxFramerate;
@property(nonatomic, assign) unsigned int qpMax;
@property(nonatomic, assign) SCXVideoCodecMode mode;
@end

NS_ASSUME_NONNULL_END
