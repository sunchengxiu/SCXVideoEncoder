//
//  SCXVideoEncoderQpThresholds.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCXVideoEncoderQpThresholds : NSObject
- (instancetype)initWithThresholdsLow:(NSInteger)low high:(NSInteger)high;

/**
 low
 */
@property(nonatomic , assign , readonly)NSInteger low;

/**
 high
 */
@property(nonatomic , assign , readonly)NSInteger high;


@end

NS_ASSUME_NONNULL_END
