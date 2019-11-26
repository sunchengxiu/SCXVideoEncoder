//
//  SCXVideoCapturer.m
//  SCXMediaService
//
//  Created by 孙承秀 on 2019/11/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXVideoCapturer.h"

@implementation SCXVideoCapturer
@synthesize delegate = _delegate;
-(instancetype)initWithDelegate:(id<SCXVideoCaptureDelegate>)delegate{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}
@end
