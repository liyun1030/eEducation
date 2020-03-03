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
        for(UserModel *userModel in roomInfoModel.users) {
            if(userModel.role == UserRoleTypeTeacher) {
                weakself.teacherModel = userModel;
            } else if(userModel.role == UserRoleTypeStudent) {
                weakself.studentModel = userModel;
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
    
    WEAK(self);
    [super setupRTCVideoCanvas:model completeBlock:^(AgoraRtcVideoCanvas *videoCanvas) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", model.uid];
        NSArray<RTCVideoSessionModel *> *filteredArray = [weakself.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
        NSAssert(filteredArray.count == 0, @"uid already exist");

        if(filteredArray.count == 0) {
           RTCVideoSessionModel *videoSessionModel = [RTCVideoSessionModel new];
           videoSessionModel.uid = model.uid;
           videoSessionModel.videoCanvas = videoCanvas;
           [weakself.rtcVideoSessionModels addObject:videoSessionModel];
        }
        
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
        if(uid == self.eduConfigModel.uid) {
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
}

@end

