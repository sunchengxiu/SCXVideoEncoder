//
//  SCXVideoCodecInfo.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCXVideoCodecInfo : NSObject
-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name;

/**
 name
 */
@property(nonatomic , copy , readonly)NSString *name;
@end

NS_ASSUME_NONNULL_END
