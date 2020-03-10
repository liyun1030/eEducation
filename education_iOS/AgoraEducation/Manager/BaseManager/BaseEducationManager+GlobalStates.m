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

static char kAssociatedConfig;

@implementation BaseEducationManager (GlobalStates)

- (void)getConfigWithSuccessBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [HttpManager getAppConfigWithSuccess:^(id responseObj) {
        
        ConfigModel *model = [ConfigModel yy_modelWithDictionary:responseObj];
        if(model.code == 0) {
            
            weakself.eduConfigModel.appId = model.data.configInfoModel.appId;
            weakself.eduConfigModel.oneToOneStudentLimit = model.data.configInfoModel.oneToOneStudentLimit.integerValue;
            weakself.eduConfigModel.smallClassStudentLimit = model.data.configInfoModel.smallClassStudentLimit.integerValue;
            weakself.eduConfigModel.largeClassStudentLimit = model.data.configInfoModel.largeClassStudentLimit.integerValue;
            
            weakself.eduConfigModel.httpBaseURL = model.data.apiHost;
            weakself.eduConfigModel.multiLanguage = model.data.configInfoModel.multiLanguage;
            
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
    
    NSString *url = [NSString stringWithFormat:HTTP_ENTER_ROOM, self.eduConfigModel.httpBaseURL, self.eduConfigModel.appId];
    
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
            
            weakself.eduConfigModel.userToken = model.data.userToken;
            weakself.eduConfigModel.roomId = model.data.roomId;
                    
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
 
    NSString *url = [NSString stringWithFormat:HTTP_ROOM_INFO, self.eduConfigModel.httpBaseURL, self.eduConfigModel.appId, self.eduConfigModel.roomId];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = self.eduConfigModel.userToken;
    WEAK(self);
    [HttpManager get:url params:nil headers:headers success:^(id responseObj) {
        
        RoomAllModel *model = [RoomAllModel yy_modelWithDictionary:responseObj];
        if(model.code == 0) {
            
            weakself.eduConfigModel.uid = model.data.localUser.uid;
            weakself.eduConfigModel.userId = model.data.localUser.userId;
            weakself.eduConfigModel.channelName = model.data.room.channelName;
            
            weakself.eduConfigModel.rtcToken = model.data.localUser.rtcToken;
            weakself.eduConfigModel.rtmToken = model.data.localUser.rtmToken;
            weakself.eduConfigModel.boardId = model.data.room.boardId;
            weakself.eduConfigModel.boardToken = model.data.room.boardToken;
            
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
    
    NSString *url = [NSString stringWithFormat:HTTP_UPDATE_USER_INFO, self.eduConfigModel.httpBaseURL, self.eduConfigModel.appId, self.eduConfigModel.roomId, self.eduConfigModel.userId];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = self.eduConfigModel.userToken;
    
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
    
    if(self.eduConfigModel == nil) {
        return des;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray<NSString*> *allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [allLanguages objectAtIndex:0];
    NSString *msg = @"";
    if([preferredLang containsString:@"zh-Hans"]) {
        msg = [self.eduConfigModel.multiLanguage.cn valueForKey:@(errorCode).stringValue];
    } else {
        msg = [self.eduConfigModel.multiLanguage.en valueForKey:@(errorCode).stringValue];
    }
    
    if(msg == nil || msg.length == 0) {
        msg = [NSString stringWithFormat:@"%@：%ld", des, (long)errorCode];
    }
    return msg;
}

- (void)setEduConfigModel:(EduConfigModel *)eduConfigModel {
    objc_setAssociatedObject(self, &kAssociatedConfig, eduConfigModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (EduConfigModel *)eduConfigModel {
    EduConfigModel *model = objc_getAssociatedObject(self, &kAssociatedConfig);
    if(model == nil) {
        model = [EduConfigModel new];
        [self setEduConfigModel:model];
    }
    return model;
}

@end
