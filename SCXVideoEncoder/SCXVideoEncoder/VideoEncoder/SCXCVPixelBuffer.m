//
//  SCXCVPixelBuffer.m
//  SCXMediaService
//
//  Created by 孙承秀 on 2019/11/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXCVPixelBuffer.h"

@implementation SCXCVPixelBuffer{
  int _width;
  int _height;
  int _bufferWidth;
  int _bufferHeight;

}
@synthesize pixelBuffer = _pixelBuffer;
-(instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer{
    return [self initWithPixelBuffer:pixelBuffer adaptedWidth:CVPixelBufferGetWidth(pixelBuffer) adaptedHeight:CVPixelBufferGetHeight(pixelBuffer)];
}
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
 adaptedWidth:(int)adaptedWidth
adaptedHeight:(int)adaptedHeight
   
{
    if (self = [super init]) {
        _pixelBuffer = pixelBuffer;
        _width = adaptedWidth;
        _height = adaptedHeight;
        _bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
        _bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
        CVBufferRetain(_pixelBuffer);
    }
    return self;
    
}
-(void)dealloc{
    CVBufferRelease(_pixelBuffer);
}
-(int)width{
    return _width;
}
-(int)height{
    return _height;
}
+(NSSet<NSNumber *> *)supportedPixelFormats{
    return [NSSet setWithObjects:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
                                  @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
                                  @(kCVPixelFormatType_32BGRA),
                                  @(kCVPixelFormatType_32ARGB),
                                  nil];
}
@end
