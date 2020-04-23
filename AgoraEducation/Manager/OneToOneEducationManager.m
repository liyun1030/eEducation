//
//  OneToOneEducationManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/31.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "OneToOneEducationManager.h"

@interface OneToOneEducationManager()

@end

@implementation OneToOneEducationManager

- (instancetype)init {
    if(self = [super init]) {
        self.rtcUids = [NSMutableSet set];
        self.rtcVideoSessionModels = [NSMutableArray array];
    }
    return self;
}

#pragma mark GlobalStates
- (void)getRoomInfoCompleteSuccessBlock:(void (^ _Nullable) (RoomInfoModel * roomInfoModel))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {
        
        weakself.roomModel = roomInfoModel.room;
        weakself.studentModel = roomInfoModel.localUser;
        
        if(weakself.roomModel != nil && weakself.roomModel.coVideoUsers != nil) {
            for(UserModel *userModel in weakself.roomModel.coVideoUsers) {
                if(userModel.role == UserRoleTypeTeacher) {
                    weakself.teacherModel = userModel;
                    break;
                }
            }
        }
        if(successBlock != nil) {
            successBlock(roomInfoModel);
        }
    } completeFailBlock:failBlock];
}
- (void)updateEnableChatWithValue:(BOOL)enableChat completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super updateEnableChatWithValue:enableChat completeSuccessBlock:^{
        weakself.studentModel.enableChat = enableChat;
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}
- (void)updateEnableVideoWithValue:(BOOL)enableVideo completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super updateEnableVideoWithValue:enableVideo completeSuccessBlock:^{
        weakself.studentModel.enableVideo = enableVideo;
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}
- (void)updateEnableAudioWithValue:(BOOL)enableAudio completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super updateEnableAudioWithValue:enableAudio completeSuccessBlock:^{
        weakself.studentModel.enableAudio = enableAudio;
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}

#pragma mark RTC
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
        
        if (removeSessionModel != nil) {
            AgoraLogInfo(@"VideoSessionModels remove repeat view uid:%lu", (unsigned long)removeSessionModel.uid);
            [weakself.rtcVideoSessionModels removeObject:removeSessionModel];
        }
        if (currentSessionModel != nil) {
            AgoraLogInfo(@"VideoSessionModels remove repeat uid:%lu", (unsigned long)currentSessionModel.uid);
            [weakself.rtcVideoSessionModels removeObject:currentSessionModel];
        }
        
        AgoraLogInfo(@"VideoSessionModels add:%lu", (unsigned long)model.uid);
        
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
        if(uid == EduConfigModel.shareInstance.uid) {
            [self.rtcManager setupLocalVideo:model.videoCanvas];
        } else {
            [self.rtcManager setupRemoteVideo:model.videoCanvas];
        }
        [self.rtcVideoSessionModels removeObject:model];
        AgoraLogInfo(@"VideoSessionModels remove given uid:%lu", (unsigned long)model.uid);
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

