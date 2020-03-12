//
//  SignalModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/29.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "SignalMessageModel.h"

@implementation SignalMessageInfoModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"signalValueType": @"operate"};
}
@end

@implementation SignalMessageModel
+ (NSDictionary *)objectClassInArray {
    return @{@"data" : [SignalMessageInfoModel class]};
}

@end
