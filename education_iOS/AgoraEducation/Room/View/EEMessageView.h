//
//  EEMessageView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EEMessageView : UIView

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userToken;

- (void)addMessageModel:(MessageInfoModel *)model;
- (void)updateTableView;
@end

NS_ASSUME_NONNULL_END
