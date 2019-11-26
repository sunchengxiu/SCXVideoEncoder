//
//  SCXFileCapturer.m
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/26.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SCXFileCapturer.h"
@interface SCXFileCapturer()

/**
 file capture
 */
@property(nonatomic , strong)SCXFileVideoCapturer *fileCapture;
@end
@implementation SCXFileCapturer
-(instancetype)initWithFileVideoCapture:(SCXFileVideoCapturer *)fileCapture{
    if (self = [super init]) {
        _fileCapture = fileCapture;
    }
    return self;
}
-(void)startCapture{
    [self.fileCapture startCapturingWithFileName:@"test.mp4" onError:^(NSError * _Nonnull error) {
        NSLog(@"%@",error.userInfo);
    }];
}
-(void)stopCapture{
    [self.fileCapture stopCapture];
}
@end
