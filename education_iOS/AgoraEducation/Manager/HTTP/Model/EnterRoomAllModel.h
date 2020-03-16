//
//  EnterRoomAllModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/7.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EnterRoomModel :NSObject
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, assign) NSInteger courseState;
@property (nonatomic, assign) NSInteger startTIme;

@property (nonatomic, assign) NSInteger muteAllChat;
@property (nonatomic, assign) NSInteger isRecording;
@property (nonatomic, assign) NSInteger recordingTime;
@property (nonatomic, copy) NSString *boardId;
@property (nonatomic, copy) NSString *boardToken;
@property (nonatomic, assign) NSInteger lockBoard;

@end

@interface EnterUserModel :NSObject
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) NSInteger role;
@property (nonatomic, assign) NSInteger enableChat;
@property (nonatomic, assign) NSInteger enableVideo;
@property (nonatomic, assign) NSInteger enableAudio;

@property (nonatomic, assign) NSInteger uid;


@property (nonatomic, assign) NSInteger screenId;
@property (nonatomic, copy) NSString *rtcToken;
@property (nonatomic, copy) NSString *rtmToken;
@property (nonatomic, copy) NSString *screenToken;

@property (nonatomic, assign) NSInteger grantBoard;
@property (nonatomic, assign) NSInteger coVideo;
@end


@interface EnterRoomInfoModel :NSObject
@property (nonatomic, strong) EnterRoomModel *room;
@property (nonatomic, strong) EnterUserModel *user;

@end


@interface EnterRoomAllModel :NSObject
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) EnterRoomInfoModel *data;

@end


NS_ASSUME_NONNULL_END
