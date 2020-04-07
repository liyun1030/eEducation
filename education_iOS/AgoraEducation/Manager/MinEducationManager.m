//
//  MinEducationManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/31.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MinEducationManager.h"

@interface MinEducationManager()

@end

@implementation MinEducationManager

- (instancetype)init {
    if(self = [super init]) {
        self.rtcUids = [NSMutableSet set];
        self.rtcVideoSessionModels = [NSMutableArray array];
        self.studentTotleListArray = [NSArray array];
        self.studentListArray = [NSMutableArray array];
    }
    return self;
}

- (void)refreshStudentModelArray {
    self.studentListArray = [NSMutableArray array];
    for (UserModel *studentInfoModel in self.studentTotleListArray) {
        if([self.rtcUids containsObject:@(studentInfoModel.uid).stringValue]){
            [self.studentListArray addObject:[studentInfoModel yy_modelCopy]];
        }
    }
}

#pragma mark GlobalStates
- (void)getRoomInfoCompleteSuccessBlock:(void (^ _Nullable) (RoomInfoModel * roomInfoModel))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {
        
        NSMutableArray<UserModel*> *studentTotleListArray = [NSMutableArray array];
        
        weakself.roomModel = roomInfoModel.room;
        weakself.studentModel = roomInfoModel.localUser;
        
        if(weakself.roomModel != nil && weakself.roomModel.coVideoUsers != nil) {
            for(UserModel *userModel in weakself.roomModel.coVideoUsers) {
                if(userModel.role == UserRoleTypeTeacher) {
                    weakself.teacherModel = userModel;
                } else if(userModel.role == UserRoleTypeStudent) {
                    [studentTotleListArray addObject:userModel];
                }
            }
        }
        weakself.studentTotleListArray = [NSArray arrayWithArray:studentTotleListArray];
        
        if(successBlock != nil) {
            successBlock(roomInfoModel);
        }
    } completeFailBlock:failBlock];
}
- (void)updateEnableChatWithValue:(BOOL)enableChat completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super updateEnableChatWithValue:enableChat completeSuccessBlock:^{
        weakself.studentModel.enableChat = enableChat;
        for (UserModel *model in weakself.studentTotleListArray) {
            if(model.uid == weakself.studentModel.uid){
                model.enableChat = enableChat;
                break;
            }
        }
        
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}
- (void)updateEnableVideoWithValue:(BOOL)enableVideo completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super updateEnableVideoWithValue:enableVideo completeSuccessBlock:^{
        weakself.studentModel.enableVideo = enableVideo;
        for (UserModel *model in weakself.studentTotleListArray) {
            if(model.uid == weakself.studentModel.uid){
                model.enableVideo = enableVideo;
                break;
            }
        }
        
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}
- (void)updateEnableAudioWithValue:(BOOL)enableAudio completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super updateEnableAudioWithValue:enableAudio completeSuccessBlock:^{
        weakself.studentModel.enableAudio = enableAudio;
        for (UserModel *model in weakself.studentTotleListArray) {
            if(model.uid == weakself.studentModel.uid){
                model.enableAudio = enableAudio;
                break;
            }
        }
        
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}

#pragma mark RTCManager
- (int)setRTCRemoteStreamWithUid:(NSUInteger)uid type:(RTCVideoStreamType)streamType {
    if(streamType == RTCVideoStreamTypeLow){
        return [self.rtcManager setRemoteVideoStream:uid type:AgoraVideoStreamTypeLow];
    } else if(streamType == RTCVideoStreamTypeHigh){
        return [self.rtcManager setRemoteVideoStream:uid type:AgoraVideoStreamTypeHigh];
    }
    return -1;
}

- (void)setupRTCVideoCanvas:(RTCVideoCanvasModel *)model completeBlock:(void(^ _Nullable)(AgoraRtcVideoCanvas *videoCanvas))block {

    RTCVideoSessionModel *currentSessionModel;
    RTCVideoSessionModel *removeSessionModel;
    for (RTCVideoSessionModel *videoSessionModel in self.rtcVideoSessionModels) {
        // view rerender
        if(videoSessionModel.videoCanvas.view == model.videoView){
            videoSessionModel.videoCanvas.view = nil;
            if(videoSessionModel.uid == self.signalManager.messageModel.uid.integerValue) {
                [self.rtcManager setupLocalVideo:videoSessionModel.videoCanvas];
            } else {
                [self.rtcManager setupRemoteVideo:videoSessionModel.videoCanvas];
            }
            removeSessionModel = videoSessionModel;

        } else if(videoSessionModel.uid == model.uid){
            videoSessionModel.videoCanvas.view = nil;
            if(videoSessionModel.uid == self.signalManager.messageModel.uid.integerValue) {
                [self.rtcManager setupLocalVideo:videoSessionModel.videoCanvas];
            } else {
                [self.rtcManager setupRemoteVideo:videoSessionModel.videoCanvas];
            }
            currentSessionModel = videoSessionModel;
        }
    }

    WEAK(self);
    [super setupRTCVideoCanvas:model completeBlock:^(AgoraRtcVideoCanvas *videoCanvas) {
        
        if(removeSessionModel != nil){
            [weakself.rtcVideoSessionModels removeObject:removeSessionModel];
        }
        if(currentSessionModel != nil){
            [weakself.rtcVideoSessionModels removeObject:currentSessionModel];
        }
        
        RTCVideoSessionModel *videoSessionModel = [RTCVideoSessionModel new];
        videoSessionModel.uid = model.uid;
        videoSessionModel.videoCanvas = videoCanvas;
        [weakself.rtcVideoSessionModels addObject:videoSessionModel];
        
        if(block != nil){
            block(videoCanvas);
        }
    }];
}

- (void)removeRTCVideoCanvas:(NSUInteger) uid {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", uid];
    NSArray<RTCVideoSessionModel *> *filteredArray = [self.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
    if(filteredArray > 0) {
        RTCVideoSessionModel *model = filteredArray.firstObject;
        model.videoCanvas.view = nil;
        if(uid == self.signalManager.messageModel.uid.integerValue) {
            [self.rtcManager setupLocalVideo:model.videoCanvas];
        } else {
            [self.rtcManager setupRemoteVideo:model.videoCanvas];
        }
        [self.rtcVideoSessionModels removeObject:model];
    }
}

- (void)releaseResources {

    for (RTCVideoSessionModel *model in self.rtcVideoSessionModels){
        model.videoCanvas.view = nil;
        
        if(model.uid == self.signalManager.messageModel.uid.integerValue) {
            [self.rtcManager setupLocalVideo:model.videoCanvas];
        } else {
            [self.rtcManager setupRemoteVideo:model.videoCanvas];
        }
    }
    [self.rtcVideoSessionModels removeAllObjects];

    // release rtc
    [self releaseRTCResources];
    
    // release white
    [self releaseWhiteResources];
    
    // release signal
    [self releaseSignalResources];
    
    [BaseEducationManager leftRoomWithSuccessBolck:nil completeFailBlock:nil];
}

@end
