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
#import "SCXVideoEncoderH264.h"
@interface ViewController ()<SCXVideoCaptureDelegate , SCXVideoEncoderProtocol>{
    SCXFileCapturer *_fileCapture;
    SCXVideoEncoderH264 *_encoder;
    NSFileHandle *_handle;
    NSString *_path;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"h264test.h264"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:_path]) {
        if ([manager removeItemAtPath:_path error:nil]) {
            if ([manager createFileAtPath:_path contents:nil attributes:nil]) {
                NSLog(@"创建文件");
            }
        }
    }else {
        if ([manager createFileAtPath:_path contents:nil attributes:nil]) {
            NSLog(@"创建文件");
        }
    }
    
    NSLog(@"%@", _path);
    _handle = [NSFileHandle fileHandleForWritingAtPath:_path];
    
    SCXFileVideoCapturer *fileVideoCapture = [[SCXFileVideoCapturer alloc] initWithDelegate:self];
    _fileCapture = [[SCXFileCapturer alloc] initWithFileVideoCapture:fileVideoCapture];
    [_fileCapture startCapture];
    
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
    _encoder = encoder;
    _encoder.delegate = self;
    [encoder startEncoderWithSettings:settings numberOfCores:2];
}

-(void)capture:(SCXVideoCapturer *)capture didCaptureVideoFrame:(SCXVideoFrame *)frame{
    [_encoder encode:frame
        codecSpecificInfo:nil
          frameTypes:@[ @(SCXFrameTypeVideoFrameDelta) ]];
}
-(void)spsData:(NSData *)spsData ppsData:(NSData *)ppsData{
    [_handle seekToEndOfFile];
    [_handle writeData:spsData];
    [_handle writeData:ppsData];
}
-(void)naluData:(NSData *)naluData{
    [_handle seekToEndOfFile];
    [_handle writeData:naluData];
}
@end
