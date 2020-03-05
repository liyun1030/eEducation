//
//  SignalP2PModel.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/22.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SignalP2PType) {
    SignalP2PTypeApply          = 105,
    SignalP2PTypeReject         = 107,
};

NS_ASSUME_NONNULL_BEGIN

@interface SignalP2PModel : NSObject
@property (nonatomic, assign) SignalP2PType cmd;
@property (nonatomic, copy) NSString *text;
@end

NS_ASSUME_NONNULL_END
