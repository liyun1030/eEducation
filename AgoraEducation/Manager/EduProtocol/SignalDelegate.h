//
//  SignalDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageModel.h"
#import "SignalMessageModel.h"
#import "SignalP2PModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SignalDelegate <NSObject>

@optional

- (void)didReceivedMessage:(MessageInfoModel * _Nonnull)model;
- (void)didReceivedReplaySignal:(MessageInfoModel * _Nonnull)model;
- (void)didReceivedPeerSignal:(SignalP2PModel * _Nonnull)model;
- (void)didReceivedSignal:(SignalMessageInfoModel * _Nonnull)model;
- (void)didReceivedConnectionStateChanged:(AgoraRtmConnectionState)state;

@end

NS_ASSUME_NONNULL_END
