//
//  SCXVideoCodecInfo.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString *kH264Encoder = @"h264";
static NSString *kVP8Encoder = @"vp8";
NS_ASSUME_NONNULL_BEGIN

@interface SCXVideoCodecInfo : NSObject
-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name parameters:(nullable NSDictionary <NSString * , NSString *>*)parameters NS_DESIGNATED_INITIALIZER;

/**
 name
 */
@property(nonatomic , copy , readonly)NSString *name;

/**
 parameters
 */
@property(nonatomic , copy , readonly)NSDictionary<NSString * , NSString *> *parameters;
@end

NS_ASSUME_NONNULL_END
