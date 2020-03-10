//
//  EduConfigModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EduConfigModel.h"
#import "HttpManager.h"

@implementation EduConfigModel

- (void)setHttpBaseUrl:(NSString *)url {
    if(url != nil && url.length > 0) {
        _httpBaseURL = url;
        NSString *lastString = [url substringFromIndex:url.length-1];
        if([lastString isEqualToString:@"/"]) {
            _httpBaseURL = [url substringWithRange:NSMakeRange(0, [url length] - 1)];
        }
    }
}

- (NSString *)getHttpBaseUrl {
    if(_httpBaseURL == nil || _httpBaseURL.length == 0) {
        _httpBaseURL = HTTP_BASE_URL;
    }
    return _httpBaseURL;
}

@end
