//
//  URL.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/16.
//  Copyright © 2020 yangmoumou. All rights reserved.
//


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

#define HTTP_GET_LANGUAGE @"%@/edu/v1/multi/language"

#define HTTP_ENTER_ROOM @"%@/edu/v1/apps/%@/room/entry"

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
