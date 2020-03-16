//
//  CYXHttpRequest.m
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import "HttpManager.h"
#import <AFNetworking/AFNetworking.h>

@interface HttpManager ()

@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;

@end

static HttpManager *manager = nil;

@implementation HttpManager
+ (instancetype)shareManager{
    @synchronized(self){
        if (!manager) {
            manager = [[self alloc]init];
            [manager initSessionManager];
        }
        return manager;
    }
}

- (void)initSessionManager {
    self.sessionManager = [AFHTTPSessionManager manager];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = 30;
}

+ (void)get:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    if(headers != nil && headers.allKeys.count > 0){
        NSArray<NSString*> *keys = headers.allKeys;
        for(NSString *key in keys){
            [HttpManager.shareManager.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    NSLog(@"\n============>Get HTTP Start<============\n\
          \nurl==>\n%@\n\
          \nheaders==>\n%@\n\
          \nparams==>\n%@\n\
          ", url, headers, params);
    
    [HttpManager.shareManager.sessionManager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"\n============>Get HTTP Success<============\n\
              \nResult==>\n%@\n\
              ", responseObject);
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n============>Get HTTP Error<============\n\
              \nError==>\n%@\n\
              ", error.description);
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)post:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure {

    if(headers != nil && headers.allKeys.count > 0){
        NSArray<NSString*> *keys = headers.allKeys;
        for(NSString *key in keys){
            [HttpManager.shareManager.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }

    NSLog(@"\n============>Post HTTP Start<============\n\
          \nurl==>\n%@\n\
          \nheaders==>\n%@\n\
          \nparams==>\n%@\n\
          ", url, headers, params);
    
    [HttpManager.shareManager.sessionManager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"\n============>Post HTTP Success<============\n\
              \nResult==>\n%@\n\
              ", responseObject);
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSLog(@"\n============>Post HTTP Error<============\n\
              \nError==>\n%@\n\
              ", error.description);
        if (failure) {
          failure(error);
        }
    }];
}

+ (void)getAppConfigWithSuccess:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure {
    
    NSInteger deviceType = 0;
    if (UIUserInterfaceIdiomPhone == [UIDevice currentDevice].userInterfaceIdiom) {
        deviceType = 1;
    } else if(UIUserInterfaceIdiomPad == [UIDevice currentDevice].userInterfaceIdiom) {
        deviceType = 2;
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *params = @{
        @"appCode" : @"edu-demo",//
        @"osType" : @(1),// 1.ios 2.android
        @"terminalType" : @(deviceType),//1.phone 2.pad
        @"appVersion" : app_Version
    };
    
    [HttpManager get:HTTP_GET_CONFIG params:params headers:nil success:^(id responseObj) {
        
        if(success != nil){
            success(responseObj);
        }
    } failure:^(NSError *error) {
        
        if(failure != nil) {
            failure(error);
        }
    }];
}

+ (void)getReplayInfoWithBaseURL:(NSString *)baseURL userToken:(NSString *)userToken appId:(NSString *)appId roomId:(NSString *)roomId recordId:(NSString *)recordId success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = userToken;

    NSString *url = [NSString stringWithFormat:HTTP_GET_REPLAY_INFO, baseURL, appId, roomId, recordId];
    [HttpManager get:url params:nil headers:headers success:^(id responseObj) {
        
        if(success != nil){
            success(responseObj);
        }
    } failure:^(NSError *error) {
        
        if(failure != nil) {
            failure(error);
        }
    }];
}
@end
