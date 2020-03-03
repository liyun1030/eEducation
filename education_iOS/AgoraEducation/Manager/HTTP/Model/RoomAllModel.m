//
//  RoomAllModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "RoomAllModel.h"

@implementation RoomModel

@end

@implementation UserModel

@end

@implementation RoomInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"users" : [UserModel class]};
}
@end

@implementation RoomAllModel

@end
