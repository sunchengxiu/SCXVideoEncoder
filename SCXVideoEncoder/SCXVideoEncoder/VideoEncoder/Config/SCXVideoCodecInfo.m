//
//  SCXVideoCodecInfo.m
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXVideoCodecInfo.h"

@implementation SCXVideoCodecInfo
@synthesize name = _name;
-(instancetype)initWithName:(NSString *)name{
    return [self initWithName:name parameters:nil];
}
-(instancetype)initWithName:(NSString *)name parameters:(NSDictionary<NSString *,NSString *> *)parameters{
    if (self = [super init]) {
        _name = name;
        _parameters = parameters?parameters:@{};
    }
    return self;
}
@end
