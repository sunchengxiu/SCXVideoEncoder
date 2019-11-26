//
//  SCXVideoCapturer.h
//  SCXMediaService
//
//  Created by 孙承秀 on 2019/11/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCXVideoFrame.h"
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "SCXVideoCaptureDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface SCXVideoCapturer : NSObject

/**
 delegate
 */
@property(nonatomic , weak)id<SCXVideoCaptureDelegate> delegate;
- (instancetype)initWithDelegate:(id<SCXVideoCaptureDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
