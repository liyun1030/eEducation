//
//  RoomAllModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomModel : NSObject
@property (nonatomic, assign) NSInteger roomId;
@property (nonatomic, copy)   NSString *roomName;
@property (nonatomic, copy)   NSString *channelName;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger courseState;// 1=inclass 2=outclass
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger muteAllChat;
@property (nonatomic, assign) NSInteger isRecording;
@property (nonatomic, assign) NSInteger recordingTime;
@property (nonatomic, copy)   NSString *boardId;
@property (nonatomic, copy)   NSString *boardToken;
@property (nonatomic, assign) NSInteger lockBoard; //1=locked 0=no lock
@end

@interface UserModel : NSObject
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy)   NSString *userName;
@property (nonatomic, assign) NSInteger role;
@property (nonatomic, assign) NSInteger enableChat;
@property (nonatomic, assign) NSInteger enableVideo;
@property (nonatomic, assign) NSInteger enableAudio;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger screenId;
@property (nonatomic, assign) NSInteger grantBoard;// 1=granted 0=no grant
@property (nonatomic, assign) NSInteger coVideo;// 1=linked 0=no link

@end

@interface RoomInfoModel : NSObject
@property (nonatomic, strong) RoomModel *room;
@property (nonatomic, copy)   NSArray<UserModel *> *users;
@end

@interface RoomAllModel : NSObject
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) RoomInfoModel *data;
@end

NS_ASSUME_NONNULL_END
