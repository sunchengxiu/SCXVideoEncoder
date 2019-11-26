//
//  SCXCodecSpecificInfoH264.h
//  SCXVideoEncoder
//
//  Created by 孙承秀 on 2019/11/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCXCodecSpecificInfo.h"
NS_ASSUME_NONNULL_BEGIN
/** Class for H264 specific config. */
typedef NS_ENUM(NSUInteger, SCXH264PacketizationMode) {
  SCXH264PacketizationModeNonInterleaved = 0,  // Mode 1 - STAP-A, FU-A is allowed
  SCXH264PacketizationModeSingleNalUnit        // Mode 0 - only single NALU allowed
};
@interface SCXCodecSpecificInfoH264 : NSObject<SCXCodecSpecificInfo>

/**
 mode
 */
@property(nonatomic , assign)SCXH264PacketizationMode packetizationMode;

@end

NS_ASSUME_NONNULL_END
