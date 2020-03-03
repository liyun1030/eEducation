//
//  BaseEducationManager+WhiteBoard.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager+WhiteBoard.h"

@implementation BaseEducationManager (WhiteBoard)

- (void)initWhiteSDK:(WhiteBoardView *)boardView dataSourceDelegate:(id<WhitePlayDelegate> _Nullable)whitePlayerDelegate {
    
    self.whitePlayerDelegate = whitePlayerDelegate;
    
    self.whiteManager = [[WhiteManager alloc] init];
    self.whiteManager.whiteManagerDelegate = self;
    [self.whiteManager initWhiteSDKWithBoardView:boardView config:[WhiteSdkConfiguration defaultConfig]];
}

- (void)joinWhiteRoomWithBoardId:(NSString*)boardId boardToken:(NSString*)boardToken  completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock {
    
    WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:boardId roomToken:boardToken];
    [self.whiteManager joinWhiteRoomWithWhiteRoomConfig:roomConfig completeSuccessBlock:^(WhiteRoom * _Nullable room) {
        
        if(successBlock != nil){
            successBlock(room);
        }
        
    } completeFailBlock:^(NSError * _Nullable error) {
        
        if(failBlock != nil){
            failBlock(error);
        }
    }];
}

- (void)createWhiteReplayerWithModel:(ReplayerModel *)model completeSuccessBlock:(void (^) (WhitePlayer * _Nullable whitePlayer, AVPlayer * _Nullable avPlayer))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock {

    NSAssert(model.startTime && model.startTime.length == 13, @"startTime should be millisecond unit");
    NSAssert(model.endTime && model.endTime.length == 13, @"endTime should be millisecond unit");
    
//    WEAK(self);
//    [HttpManager POSTWhiteBoardRoomWithUuid:model.uuid token:^(NSString * _Nonnull token) {
//
//        WhitePlayerConfig *playerConfig = [[WhitePlayerConfig alloc] initWithRoom:model.uuid roomToken:token];
//
//        // make up
//        NSInteger iStartTime = [model.startTime substringToIndex:10].integerValue;
//        NSInteger iDuration = labs(model.endTime.integerValue - model.startTime.integerValue) * 0.001;
//
//        playerConfig.beginTimestamp = @(iStartTime);
//        playerConfig.duration = @(iDuration);
//
//        [weakself.whiteManager createReplayerWithConfig:playerConfig completeSuccessBlock:^(WhitePlayer * _Nullable player) {
//
//            AVPlayer *avPlayer;
//            if(model.videoPath != nil && model.videoPath.length > 0){
//                avPlayer = [weakself.whiteManager createCombinePlayerWithVideoPath: model.videoPath];
//            }
//            if(successBlock != nil){
//                successBlock(player, avPlayer);
//            }
//
//        } completeFailBlock:^(NSError * _Nullable error) {
//
//            if(failBlock != nil){
//                failBlock(error);
//            }
//        }];
//
//    } failure:^(NSString * _Nonnull msg) {
//        if(failBlock != nil){
//            failBlock(nil);
//        }
//        NSLog(@"EducationManager CreateReplayer Err:%@", msg);
//    }];
}

- (void)disableCameraTransform:(BOOL)disableCameraTransform {
    [self.whiteManager disableCameraTransform:disableCameraTransform];
}

- (void)disableWhiteDeviceInputs:(BOOL)disable {
    [self.whiteManager disableDeviceInputs:disable];
}

- (void)setWhiteStrokeColor:(NSArray<NSNumber *>*)strokeColor {
    self.whiteManager.whiteMemberState.strokeColor = strokeColor;
    [self.whiteManager setMemberState:self.whiteManager.whiteMemberState];
}

- (void)setWhiteApplianceName:(NSString *)applianceName {
    self.whiteManager.whiteMemberState.currentApplianceName = applianceName;
    [self.whiteManager setMemberState:self.whiteManager.whiteMemberState];
}

- (void)setWhiteMemberInput:(nonnull WhiteMemberState *)memberState {
    [self.whiteManager setMemberState:memberState];
}
- (void)refreshWhiteViewSize {
    [self.whiteManager refreshViewSize];
}
- (void)moveWhiteToContainer:(NSInteger)sceneIndex {
    WhiteSceneState *sceneState = self.whiteManager.room.sceneState;
    NSArray<WhiteScene *> *scenes = sceneState.scenes;
    WhiteScene *scene = scenes[sceneIndex];
    if (scene.ppt) {
        CGSize size = CGSizeMake(scene.ppt.width, scene.ppt.height);
        [self.whiteManager moveCameraToContainer:size];
    }
}

- (void)setWhiteSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler {
    [self.whiteManager setSceneIndex:index completionHandler:completionHandler];
}
- (void)seekWhiteToTime:(CMTime)time completionHandler:(void (^ _Nonnull)(BOOL finished))completionHandler {
    
    if(self.whiteManager.combinePlayer != nil) {
        [self.whiteManager seekToCombineTime:time completionHandler:completionHandler];
    } else {
        NSTimeInterval seekTime = CMTimeGetSeconds(time);
        [self.whiteManager.player seekToScheduleTime:seekTime];
        completionHandler(YES);
    }
}
- (void)playWhite {
    if(self.whiteManager.combinePlayer != nil) {
        [self.whiteManager combinePlay];
    } else {
        [self.whiteManager play];
    }
}
- (void)pauseWhite {
    if(self.whiteManager.combinePlayer != nil) {
        [self.whiteManager combinePause];
    } else {
        [self.whiteManager pause];
    }
}
- (void)stopWhite {
    [self.whiteManager stop];
}

- (NSTimeInterval)whiteTotleTimeDuration {
    return [self.whiteManager timeDuration];
}

- (void)currentWhiteScene:(void (^)(NSInteger sceneCount, NSInteger sceneIndex))completionBlock {
    
    WhiteSceneState *sceneState = self.whiteManager.room.sceneState;
    NSArray<WhiteScene *> *scenes = sceneState.scenes;
    NSInteger sceneIndex = sceneState.index;
    if(completionBlock != nil){
        completionBlock(scenes.count, sceneIndex);
    }
}

- (void)releaseWhiteResources {
    [self.whiteManager releaseResources];
}

#pragma mark WhiteManagerDelegate
- (void)phaseChanged:(WhitePlayerPhase)phase {
    
    // use nativePlayerDidFinish when videoPath no empty
    if(self.whiteManager.combinePlayer != nil){
        return;
    }
    
    if(phase == WhitePlayerPhaseWaitingFirstFrame || phase == WhitePlayerPhaseBuffering){
        if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerStartBuffering)]) {
            [self.whitePlayerDelegate whitePlayerStartBuffering];
        }
    } else if (phase == WhitePlayerPhasePlaying || phase == WhitePlayerPhasePause) {
        if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerEndBuffering)]) {
            [self.whitePlayerDelegate whitePlayerEndBuffering];
        }
    } else if(phase == WhitePlayerPhaseEnded) {
        if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerDidFinish)]) {
            [self.whitePlayerDelegate whitePlayerDidFinish];
        }
    }
}

- (void)stoppedWithError:(NSError *)error {
    
    // use nativePlayerDidFinish when videoPath no empty
    if(self.whiteManager.combinePlayer != nil){
        return;
    }
    
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerError:)]) {
        [self.whitePlayerDelegate whitePlayerError: error];
    }
}

- (void)scheduleTimeChanged:(NSTimeInterval)time {
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerTimeChanged:)]) {
        [self.whitePlayerDelegate whitePlayerTimeChanged: time];
    }
}

- (void)combinePlayerStartBuffering {
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerStartBuffering)]) {
        [self.whitePlayerDelegate whitePlayerStartBuffering];
    }
}

- (void)combinePlayerEndBuffering {
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerDidFinish)]) {
        [self.whitePlayerDelegate whitePlayerEndBuffering];
    }
}

- (void)nativePlayerDidFinish {
    
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerEndBuffering)]) {
        [self.whitePlayerDelegate whitePlayerDidFinish];
    }
}

- (void)combineVideoPlayerError:(NSError *)error {
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerError:)]) {
        [self.whitePlayerDelegate whitePlayerError: error];
    }
}

/**
The RoomState property in the room will trigger this callback when it changes.
*/
- (void)fireRoomStateChanged:(WhiteRoomState *_Nullable)modifyState {
    if (modifyState.sceneState) {
        if([self.whitePlayerDelegate respondsToSelector:@selector(whiteRoomStateChanged)]) {
            [self.whitePlayerDelegate whiteRoomStateChanged];
        }
    }
}

@end
