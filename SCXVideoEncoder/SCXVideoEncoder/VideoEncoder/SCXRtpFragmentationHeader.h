//
//  SCXRtpFragmentationHeader.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCXRtpFragmentationHeader : NSObject
@property(nonatomic, strong) NSArray<NSNumber *> *fragmentationOffset;
@property(nonatomic, strong) NSArray<NSNumber *> *fragmentationLength;
@property(nonatomic, strong) NSArray<NSNumber *> *fragmentationTimeDiff;
@property(nonatomic, strong) NSArray<NSNumber *> *fragmentationPlType;
@end

NS_ASSUME_NONNULL_END
