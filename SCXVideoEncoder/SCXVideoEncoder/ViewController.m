//
//  ViewController.m
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ViewController.h"
#import "SCXFileCapturer.h"
#import "SCXFileVideoCapturer.h"
@interface ViewController ()<SCXVideoCaptureDelegate>{
    SCXFileCapturer *_fileCapture;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SCXFileVideoCapturer *fileVideoCapture = [[SCXFileVideoCapturer alloc] initWithDelegate:self];
    _fileCapture = [[SCXFileCapturer alloc] initWithFileVideoCapture:fileVideoCapture];
    [_fileCapture startCapture];
}

-(void)capture:(SCXVideoCapturer *)capture didCaptureVideoFrame:(SCXVideoFrame *)frame{
    
}
@end
