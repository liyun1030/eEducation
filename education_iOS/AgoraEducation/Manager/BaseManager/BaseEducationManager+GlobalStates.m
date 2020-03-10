//
//  BaseEducationManager+GlobalStates.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager+GlobalStates.h"
#import "HttpManager.h"
#import "ConfigModel.h"
#import "EnterRoomAllModel.h"
#import "CommonModel.h"

@implementation BaseEducationManager (GlobalStates)

- (void)getConfigWithSuccessBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [HttpManager getAppConfigWithSuccess:^(id responseObj) {
        
        ConfigModel *model = [ConfigModel yy_modelWithDictionary:responseObj];
        if(model.code == 0) {
            
            EduConfigModel.shareInstance.appId = model.data.configInfoModel.appId;
            EduConfigModel.shareInstance.oneToOneStudentLimit = model.data.configInfoModel.oneToOneStudentLimit.integerValue;
            EduConfigModel.shareInstance.smallClassStudentLimit = model.data.configInfoModel.smallClassStudentLimit.integerValue;
            EduConfigModel.shareInstance.largeClassStudentLimit = model.data.configInfoModel.largeClassStudentLimit.integerValue;
            
            EduConfigModel.shareInstance.httpBaseURL = model.data.apiHost;
            EduConfigModel.shareInstance.multiLanguage = model.data.configInfoModel.multiLanguage;
            
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [weakself generateHttpErrorMessageWithDescribe:NSLocalizedString(@"RequestFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

- (void)enterRoomWithUserName:(NSString *)userName roomName:(NSString *)roomName sceneType:(SceneType)sceneType successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_ENTER_ROOM, EduConfigModel.shareInstance.httpBaseURL, EduConfigModel.shareInstance.appId];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userName"] = userName;
    params[@"roomName"] = roomName;
    params[@"type"] = @(sceneType);
    // student
    params[@"role"] = @(2);
    params[@"uuid"] = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    WEAK(self);
    [HttpManager post:url params:params headers:nil success:^(id responseObj) {
        
        EnterRoomAllModel *model = [EnterRoomAllModel yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            
            EduConfigModel.shareInstance.userToken = model.data.userToken;
            EduConfigModel.shareInstance.roomId = model.data.roomId;
                    
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [weakself generateHttpErrorMessageWithDescribe:NSLocalizedString(@"EnterRoomFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

- (void)updateEnableChatWithValue:(BOOL)enableChat completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enableChat"] = @(enableChat ? 1 : 0);
    
    [self updateUserInfoWithParams:params completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)updateEnableVideoWithValue:(BOOL)enableVideo completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enableVideo"] = @(enableVideo ? 1 : 0);
    
    [self updateUserInfoWithParams:params completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)updateEnableAudioWithValue:(BOOL)enableAudio completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enableAudio"] = @(enableAudio ? 1 : 0);
    [self updateUserInfoWithParams:params completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)getRoomInfoCompleteSuccessBlock:(void (^ _Nullable) (RoomInfoModel * roomInfoModel))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
 
    NSString *url = [NSString stringWithFormat:HTTP_ROOM_INFO, EduConfigModel.shareInstance.httpBaseURL, EduConfigModel.shareInstance.appId, EduConfigModel.shareInstance.roomId];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = EduConfigModel.shareInstance.userToken;
    WEAK(self);
    [HttpManager get:url params:nil headers:headers success:^(id responseObj) {
        
        RoomAllModel *model = [RoomAllModel yy_modelWithDictionary:responseObj];
        if(model.code == 0) {
            
            EduConfigModel.shareInstance.uid = model.data.localUser.uid;
            EduConfigModel.shareInstance.userId = model.data.localUser.userId;
            EduConfigModel.shareInstance.channelName = model.data.room.channelName;
            
            EduConfigModel.shareInstance.rtcToken = model.data.localUser.rtcToken;
            EduConfigModel.shareInstance.rtmToken = model.data.localUser.rtmToken;
            EduConfigModel.shareInstance.boardId = model.data.room.boardId;
            EduConfigModel.shareInstance.boardToken = model.data.room.boardToken;
            
            if(successBlock != nil) {
                successBlock(model.data);
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [weakself generateHttpErrorMessageWithDescribe:NSLocalizedString(@"GetRoomInfoFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

- (void)updateUserInfoWithParams:(NSDictionary*)params completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_UPDATE_USER_INFO, EduConfigModel.shareInstance.httpBaseURL, EduConfigModel.shareInstance.appId, EduConfigModel.shareInstance.roomId, EduConfigModel.shareInstance.userId];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = EduConfigModel.shareInstance.userToken;
    
    WEAK(self);
    [HttpManager post:url params:params headers:headers success:^(id responseObj) {
        
        CommonModel *model = [CommonModel yy_modelWithDictionary:responseObj];
        if(model.code == 0) {
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [weakself generateHttpErrorMessageWithDescribe:NSLocalizedString(@"UpdateRoomInfoFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

#pragma mark Private
- (NSString *)generateHttpErrorMessageWithDescribe:(NSString *)des errorCode:(NSInteger)errorCode {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray<NSString*> *allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [allLanguages objectAtIndex:0];
    NSString *msg = @"";
    if([preferredLang containsString:@"zh-Hans"]) {
        msg = [EduConfigModel.shareInstance.multiLanguage.cn valueForKey:@(errorCode).stringValue];
    } else {
        msg = [EduConfigModel.shareInstance.multiLanguage.en valueForKey:@(errorCode).stringValue];
    }
    
    if(msg == nil || msg.length == 0) {
        msg = [NSString stringWithFormat:@"%@：%ld", des, (long)errorCode];
    }
    return msg;
}


@end
