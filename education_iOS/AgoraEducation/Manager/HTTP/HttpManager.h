//
//  CYXHttpRequest.h
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG

#define HTTP_BASE_URL @"http://115.231.168.26:8080"

#else

#define HTTP_BASE_URL @"https://solutions-api.sh.agoralab.co"

#endif

// http: get app config
#define HTTP_GET_CONFIG @""HTTP_BASE_URL"/edu/v1/app/version"

// http: get global state when enter room
#define HTTP_ENTER_ROOM @"%@/edu/v1/apps/%@/room/entry"

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
