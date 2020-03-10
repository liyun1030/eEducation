//
//  EduConfigModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiLanguageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduConfigModel : NSObject

+ (instancetype)shareInstance;

// HTTP Config
@property (nonatomic, strong) NSString *httpBaseURL;
@property (nonatomic, strong) MultiLanguageModel *multiLanguage;

// user & room info
@property (nonatomic, assign) NSInteger uid;//rtm&rtc
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* userToken;
@property (nonatomic, strong) NSString* roomId;
@property (nonatomic, strong) NSString* channelName;

// key
@property (nonatomic, strong) NSString* appId;
@property (nonatomic, strong) NSString* rtcToken;
@property (nonatomic, strong) NSString* rtmToken;
@property (nonatomic, strong) NSString* boardId;
@property (nonatomic, strong) NSString* boardToken;

// api account limit
@property (nonatomic, assign) NSInteger oneToOneStudentLimit;
@property (nonatomic, assign) NSInteger smallClassStudentLimit;
@property (nonatomic, assign) NSInteger largeClassStudentLimit;

// local data
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* className;
@property (nonatomic, assign) NSInteger sceneType;

@end

NS_ASSUME_NONNULL_END
