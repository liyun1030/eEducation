//
//  EduConfigModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EduConfigModel.h"
#import "HttpManager.h"

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

- (instancetype)init{
    @synchronized(self) {
        if(self = [super init]) {
            self.httpBaseURL = HTTP_BASE_URL;
        }
    }
    return self;
}

- (void)setHttpBaseURL:(NSString *)url {
    if(url != nil && url.length > 0) {
        _httpBaseURL = url;
        NSString *lastString = [url substringFromIndex:url.length-1];
        if([lastString isEqualToString:@"/"]) {
            _httpBaseURL = [url substringWithRange:NSMakeRange(0, [url length] - 1)];
        }
    }
}

@end
