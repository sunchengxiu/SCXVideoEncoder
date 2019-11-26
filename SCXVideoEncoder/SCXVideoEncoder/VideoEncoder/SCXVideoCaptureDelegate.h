//
//  SCXVideoCaptureDelegate.h
//  SCXMediaService
//
//  Created by 孙承秀 on 2019/11/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class SCXVideoCapturer;
@class SCXVideoFrame;
@protocol SCXVideoCaptureDelegate <NSObject>
- (void)capture:(SCXVideoCapturer *)capture didCaptureVideoFrame:(SCXVideoFrame *)frame;
@end

NS_ASSUME_NONNULL_END
