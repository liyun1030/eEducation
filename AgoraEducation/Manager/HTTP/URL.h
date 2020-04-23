//
//  URL.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/17.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EnvType) {
    EnvTypeTest = 1,
    EnvTypePre = 2,
    EnvTypeFormal = 3,
};

extern EnvType env;

#define HTTP_BASE_URL (env == EnvTypeTest ? \
                            @"http://115.231.168.26:8088" : \
                            (env == EnvTypePre ? \
                                @"https://solutions-api-pre.sh.agoralab.co" : \
                                @"https://solutions-api.sh.agoralab.co") \
                       )

// http: get app config
#define HTTP_GET_CONFIG @"%@/edu/v1/app/version"

// http: get app config
#define HTTP_LOG_PARAMS @"%@/edu/v1/apps/%@/log/params"
// http: get app config
#define HTTP_OSS_STS @"%@/edu/v1/log/sts"
// http: get app config
#define HTTP_OSS_STS_CALLBACK @"%@/edu/v1/log/sts/callback"

// http: get global state when enter room
#define HTTP_ENTER_ROOM @"%@/edu/v2/room/entry"

#define HTTP_LEFT_ROOM @"%@/edu/v1/apps/%@/room/%@/exit"

// http: get or update global state
#define HTTP_ROOM_INFO @"%@/edu/v1/apps/%@/room/%@"

#warning You need to use your own backend service API
// http: get white board keys in room
#define HTTP_WHITE_ROOM_INFO @"%@/edu/v1/apps/%@/room/%@/board"

// http: update user info
#define HTTP_UPDATE_USER_INFO @"%@/edu/v1/apps/%@/room/%@/user/%@"

// http: get replay info
#define HTTP_GET_REPLAY_INFO @"%@/edu/v1/apps/%@/room/%@/record/%@"
