//
//  SCXCVPixelBuffer.h
//  SCXMediaService
//
//  Created by 孙承秀 on 2019/11/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "SCXVideoFrameBuffer.h"
NS_ASSUME_NONNULL_BEGIN

@interface SCXCVPixelBuffer : NSObject<SCXVideoFrameBuffer>
@property(nonatomic, readonly) CVPixelBufferRef pixelBuffer;
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;
+ (NSSet<NSNumber *>*)supportedPixelFormats;
@end

NS_ASSUME_NONNULL_END
