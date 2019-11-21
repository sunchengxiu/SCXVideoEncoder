//
//  SCXRtpFragmentationHeader.m
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXRtpFragmentationHeader.h"

@implementation SCXRtpFragmentationHeader

@synthesize fragmentationOffset = _fragmentationOffset;
@synthesize fragmentationLength = _fragmentationLength;
@synthesize fragmentationTimeDiff = _fragmentationTimeDiff;
@synthesize fragmentationPlType = _fragmentationPlType;
@end
