//
//  RoomAllModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) NSInteger role;
@property (nonatomic, assign) NSInteger enableChat;
@property (nonatomic, assign) NSInteger enableVideo;
@property (nonatomic, assign) NSInteger enableAudio;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger grantBoard;// 1=granted 0=no grant
@property (nonatomic, assign) NSInteger coVideo;// 1=linked 0=no link

@property (nonatomic, assign) NSInteger screenId;
@property (nonatomic, strong) NSString *rtcToken;
@property (nonatomic, strong) NSString *rtmToken;
@property (nonatomic, strong) NSString *screenToken;

@end

@interface RoomModel : NSObject
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger courseState;// 1=inclass 2=outclass
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger muteAllChat;
@property (nonatomic, assign) NSInteger isRecording;
@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, assign) NSInteger recordingTime;
@property (nonatomic, strong) NSString *boardId;
@property (nonatomic, strong) NSString *boardToken;
@property (nonatomic, assign) NSInteger lockBoard; //1=locked 0=no lock
@property (nonatomic, strong) NSArray<UserModel*> *coVideoUsers;
@end

@interface RoomInfoModel : NSObject
@property (nonatomic, strong) RoomModel *room;
@property (nonatomic, strong) UserModel *localUser;
@end

@interface RoomAllModel : NSObject
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) RoomInfoModel *data;
@end

NS_ASSUME_NONNULL_END
