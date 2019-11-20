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
    if (self = [super init]) {
        _name = name;
    }
    return self;
}
@end
