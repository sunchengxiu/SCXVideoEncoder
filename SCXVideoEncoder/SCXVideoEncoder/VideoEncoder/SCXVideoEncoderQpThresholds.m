//
//  SCXVideoEncoderQpThresholds.m
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXVideoEncoderQpThresholds.h"

@implementation SCXVideoEncoderQpThresholds
- (instancetype)initWithThresholdsLow:(NSInteger)low high:(NSInteger)high{
    if (self = [super init]) {
        _low = low;
        _high = high;
    }
    return self;
}
@end
