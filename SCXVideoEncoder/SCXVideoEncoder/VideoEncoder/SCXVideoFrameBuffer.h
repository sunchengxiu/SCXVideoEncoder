//
//  SCXVideoFrameBuffer.h
//  SCXMediaService
//
//  Created by 孙承秀 on 2019/11/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCXVideoFrameBuffer <NSObject>
@property(nonatomic, readonly) int width;
@property(nonatomic, readonly) int height;
@end

NS_ASSUME_NONNULL_END
