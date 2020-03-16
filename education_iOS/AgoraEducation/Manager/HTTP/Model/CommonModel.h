//
//  CommonModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonModel : NSObject
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, assign) BOOL *data;
@end

NS_ASSUME_NONNULL_END
