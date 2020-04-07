//
//  CYXHttpRequest.h
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EnvType) {
    EnvTypeTest = 1,
    EnvTypePre = 2,
    EnvTypeFormal = 3,
};

extern EnvType env;

#define HTTP_BASE_URL (env == EnvTypeTest ? \
                            @"http://115.231.168.26:8080" : \
                            (env == EnvTypePre ? \
                                @"https://solutions-api-pre.sh.agoralab.co" : \
                                @"https://solutions-api.sh.agoralab.co") \
                       )

#define HTTP_GET_LANGUAGE @"%@/edu/v1/multi/language"

#define HTTP_ENTER_ROOM @"%@/edu/v1/apps/%@/room/entry"

#define HTTP_LEFT_ROOM @"%@/edu/v1/apps/%@/room/%@/exit"

// http: get or update global state
#define HTTP_ROOM_INFO @"%@/edu/v1/apps/%@/room/%@"

// http: update user info
#define HTTP_UPDATE_USER_INFO @"%@/edu/v1/apps/%@/room/%@/user/%@"

// http: get replay info
#define HTTP_GET_REPLAY_INFO @"%@/edu/v1/apps/%@/room/%@/record/%@"

@interface HttpManager : NSObject
// common
+ (void)get:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id))success failure:(void (^)(NSError *))failure;
+ (void)post:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;

// service
+ (void)getAppConfigWithSuccess:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;
+ (void)getReplayInfoWithBaseURL:(NSString *)baseURL userToken:(NSString *)userToken appId:(NSString *)appId roomId:(NSString *)roomId recordId:(NSString *)recordId success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;

@end
