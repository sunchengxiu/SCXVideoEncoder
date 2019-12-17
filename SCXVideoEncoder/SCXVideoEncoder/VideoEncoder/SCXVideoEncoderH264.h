//
//  SCXVideoEncoderH264.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCXVideoEncoder.h"
#import "SCXVideoCodecInfo.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SCXVideoEncoderProtocol;
@interface SCXVideoEncoderH264 : NSObject<SCXVideoEncoder>
- (instancetype)initWithVideoCodecInfo:(SCXVideoCodecInfo *)info ;

/**
 delegate
 */
@property(nonatomic , assign)id <SCXVideoEncoderProtocol> delegate;

@end
@protocol SCXVideoEncoderProtocol <NSObject>

- (void)spsData:(NSData *)spsData ppsData:(NSData *)ppsData;

- (void)naluData:(NSData *)naluData;

@end
NS_ASSUME_NONNULL_END
