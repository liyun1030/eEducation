//
//  EduConfigModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EduConfigModel : NSObject

// room info
@property (nonatomic, assign) NSInteger uid;//rtm&rtc
@property (nonatomic, strong) NSString* userToken;
@property (nonatomic, assign) NSInteger roomId;
@property (nonatomic, strong) NSString* channelName;

// account
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

@end

NS_ASSUME_NONNULL_END
