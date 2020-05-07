//
//  EduConfigModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EduConfigModel.h"
#import "URL.h"

static EduConfigModel *manager = nil;

@implementation EduConfigModel

+ (instancetype)shareInstance {
    if(!manager){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [EduConfigModel new];
        });
    }
    return manager;
}

// 防止使用alloc开辟空间
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if(!manager){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [super allocWithZone:zone];
        });
    }
    return manager;
}

#pragma mark Private
+ (NSString *)generateHttpErrorMessageWithDescribe:(NSString *)des errorCode:(NSInteger)errorCode {
    
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

+ (NSDictionary *)generateHttpAuthHeader {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    if(EduConfigModel.shareInstance.rtmToken != nil && EduConfigModel.shareInstance.rtmToken.length > 0 && EduConfigModel.shareInstance.uid > 0) {
        headers[@"x-agora-token"] = EduConfigModel.shareInstance.rtmToken;
        headers[@"x-agora-uid"] = @(EduConfigModel.shareInstance.uid).stringValue;
    }
    return headers;
}
@end
