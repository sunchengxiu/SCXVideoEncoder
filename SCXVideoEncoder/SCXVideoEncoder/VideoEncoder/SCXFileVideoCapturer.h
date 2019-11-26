//
//  SCXFileVideoCapturer.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/26.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXVideoCapturer.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^SCXFileVideoCapturerErrorBlock)(NSError *error);
@interface SCXFileVideoCapturer : SCXVideoCapturer
- (void)startCapturingWithFileName:(NSString *)fileName
                           onError:(_Nullable SCXFileVideoCapturerErrorBlock)errorBlock;
- (void)stopCapture;
@end

NS_ASSUME_NONNULL_END
