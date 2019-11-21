//
//  SCXVideoFrame.m
//  SCXMediaService
//
//  Created by 孙承秀 on 2019/11/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXVideoFrame.h"

@implementation SCXVideoFrame
@synthesize buffer = _pixelBuffer;

- (instancetype)initWithPixelBuffer:(id<SCXVideoFrameBuffer>)pixelBuffer timeStampNs:(int64_t)timeStampns{
    if (self = [super init]) {
        _pixelBuffer = pixelBuffer;
        _timeStampNs = timeStampns;
    }
    return self;
}
-(int)width{
    return _pixelBuffer.width;
}
-(int)height{
    return _pixelBuffer.height;
}
@end
