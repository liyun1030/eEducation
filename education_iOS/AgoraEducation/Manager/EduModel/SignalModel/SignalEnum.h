//
//  SignalEnum.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/29.
//  Copyright © 2019 Agora. All rights reserved.
//

typedef NS_ENUM(NSInteger, MessageCmdType) {
    MessageCmdTypeChat          = 1,
    MessageCmdTypeUpdate        = 2, // notice
    MessageCmdTypeReplay        = 3,
};

typedef NS_ENUM(NSInteger, SignalValueType) {
    SignalValueTypeVideo,
    SignalValueTypeAudio,
    SignalValueTypeChat,
    SignalValueTypeGrantBoard,
    SignalValueTypeCoVideo,
    SignalValueTypeLockBoard,
};
extern NSString * NSStringFromSignalValueType(SignalValueType type);

typedef NS_ENUM(NSInteger, StudentLinkState) {
    StudentLinkStateIdle,
    StudentLinkStateApply,
    StudentLinkStateAccept,
    StudentLinkStateReject
};
