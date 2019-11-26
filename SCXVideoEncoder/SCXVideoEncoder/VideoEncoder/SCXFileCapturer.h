//
//  SCXFileCapturer.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/26.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXFileVideoCapturer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCXFileCapturer : NSObject
- (instancetype)initWithFileVideoCapture:(SCXFileVideoCapturer *)fileCapture;
- (void)startCapture;
- (void)stopCapture;
@end

NS_ASSUME_NONNULL_END
