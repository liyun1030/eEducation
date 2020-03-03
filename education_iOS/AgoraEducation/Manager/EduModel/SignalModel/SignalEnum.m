//
//  SignalEnum.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/29.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "SignalEnum.h"

NSString * NSStringFromSignalValueType(SignalValueType type) {
  switch (type) {
    case SignalValueTypeVideo:
      return @"video";
    case SignalValueTypeAudio:
      return @"audio";
    case SignalValueTypeChat:
      return @"chat";
    case SignalValueTypeGrantBoard:
          return @"grantBoard";
    case SignalValueTypeCoVideo:
          return @"coVideo";
    case SignalValueTypeLockBoard:
          return @"lockBoard";
    default:
      return nil;
  }
}
