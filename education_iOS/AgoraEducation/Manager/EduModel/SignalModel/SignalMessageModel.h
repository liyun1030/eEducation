//
//  SignalModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/29.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface SignalMessageInfoModel : NSObject
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *resource; //NSStringFromSignalValueType
@property (nonatomic, assign) NSInteger value;
@end

@interface SignalMessageModel : NSObject
@property (nonatomic, assign) MessageCmdType cmd;
@property (nonatomic, strong) SignalMessageInfoModel *data;
@end

NS_ASSUME_NONNULL_END
