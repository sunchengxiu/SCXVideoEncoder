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

@interface SCXVideoEncoderH264 : NSObject<SCXVideoEncoder>
- (instancetype)initWithVideoCodecInfo:(SCXVideoCodecInfo *)info;
@end

NS_ASSUME_NONNULL_END
