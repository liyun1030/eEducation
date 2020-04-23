//
//  SignalEnum.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/29.
//  Copyright © 2019 Agora. All rights reserved.
//

typedef NS_ENUM(NSInteger, MessageCmdType) {
    MessageCmdTypeChat          = 1,
    MessageCmdTypeUpdate        = 2, // user notice
    MessageCmdTypeReplay        = 3,
    MessageCmdTypeCourse        = 4, // class notice
};

typedef NS_ENUM(NSInteger, SignalValueType) {
    SignalValueCancelCoVideo = 108,  // 下麦
    SignalValueAcceptCoVideo = 106,  // 授权连麦
    SignalValueMuteAudio = 101,   // 禁音频
    SignalValueUnmuteAudio = 102, // 解禁音频
    SignalValueMuteVideo = 103,   // 禁视频
    SignalValueUnmuteVideo = 104, // 解禁视频
    SignalValueMuteChat = 109,    // 禁聊天
    SignalValueUnmuteChat = 110,  // 解禁聊天
    SignalValueMuteBoard = 200,   // 禁白板
    SignalValueUnmuteBoard = 201, // 解禁白板
    SignalValueLockBoard = 301,   // 锁定白板
    SignalValueUnlockBoard = 302, // 解锁白板
    SignalValueStartCourse = 401, // 开始上课
    SignalValueEndCourse = 402, //结束上课
    SignalValueMuteAllChat = 501, //全员禁言
    SignalValueUnmuteAllChat = 502, //全员解除禁言
};

typedef NS_ENUM(NSInteger, StudentLinkState) {
    StudentLinkStateIdle,
    StudentLinkStateApply,
    StudentLinkStateAccept,
    StudentLinkStateReject
};
