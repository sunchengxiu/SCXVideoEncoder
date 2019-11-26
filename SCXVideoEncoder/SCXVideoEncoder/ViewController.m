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
#import "RTCMTLVideoView.h"
#import "SCXVideoEncoderH264.h"
@interface ViewController ()<SCXVideoCaptureDelegate>{
    SCXFileCapturer *_fileCapture;
     RTCMTLVideoView* _videoView;
    SCXVideoEncoderH264 *_encoder;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SCXFileVideoCapturer *fileVideoCapture = [[SCXFileVideoCapturer alloc] initWithDelegate:self];
    _fileCapture = [[SCXFileCapturer alloc] initWithFileVideoCapture:fileVideoCapture];
    [_fileCapture startCapture];
    
    _videoView = [[RTCMTLVideoView alloc] initWithFrame:CGRectZero];
       _videoView.frame = self.view.bounds;

       [self.view addSubview:_videoView];
    
    SCXVideoCodecInfo *codecInfo = [[SCXVideoCodecInfo alloc] initWithName:@"H264"];
    SCXVideoEncoderH264 *encoder = [[SCXVideoEncoderH264 alloc] initWithVideoCodecInfo:codecInfo];
    
    SCXVideoEncoderSettings *settings = [[SCXVideoEncoderSettings alloc] init];
    settings.name = @"H264";
    settings.width = 640;
    settings.height = 480;
    settings.startBitrate = 300;
    settings.maxBitrate = 800000;
    settings.minBitrate = 30;
    settings.maxFramerate = 60;
    settings.qpMax = 56;
    settings.mode = SCXVideoCodecModeRealtimeVideo;
    
    [encoder startEncoderWithSettings:settings numberOfCores:2];
}

-(void)capture:(SCXVideoCapturer *)capture didCaptureVideoFrame:(SCXVideoFrame *)frame{
    [_videoView renderFrame:frame];
    [_encoder encode:frame
        codecSpecificInfo:nil
          frameTypes:@[ @(SCXFrameTypeVideoFrameDelta) ]];
}
@end
