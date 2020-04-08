//
//  BaseEducationManager+Signal.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/29.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager+Signal.h"
#import "SignalModel.h"
#import "JsonParseUtil.h"

@implementation BaseEducationManager (Signal)

- (void)initSignalWithAppid:(NSString *)appid appToken:(NSString *)token userId:(NSString *)uid dataSourceDelegate:(id<SignalDelegate> _Nullable)signalDelegate completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    AgoraLogInfo(@"init signal appid:%@ token:%@ uid:%@", appid, token, uid);
    
    self.signalDelegate = signalDelegate;
    
    SignalModel *model = [SignalModel new];
    model.appId = appid;
    model.token = token;
    model.uid = uid;

    self.signalManager = [[SignalManager alloc] init];
    self.signalManager.rtmDelegate = self;
    self.signalManager.messageModel = model;
    [self.signalManager initWithMessageModel:model completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    AgoraLogInfo(@"join signal channelName:%@", channelName);
    [self.signalManager joinChannelWithName:channelName completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)sendSignalWithModel:(SignalMessageInfoModel *)model completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    NSMutableDictionary *dataParams = [NSMutableDictionary dictionary];
    dataParams[@"uid"] = @(model.uid);
    dataParams[@"account"] = model.account;
    dataParams[@"operate"] = @(model.signalValueType);
        
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"cmd"] = @(MessageCmdTypeUpdate);
    params[@"data"] = dataParams;
    
    AgoraLogInfo(@"send signal params:%@", params);
    
    NSString *messageBody = [JsonParseUtil dictionaryToJson:params];
    [self.signalManager sendMessage:messageBody completeSuccessBlock:^{
      
        AgoraLogInfo(@"send signal success");
        if(successBlock != nil){
            successBlock();
        }
        
    } completeFailBlock:^(NSInteger errorCode) {
        AgoraLogInfo(@"send signal fail errorCode:%ld", (long)errorCode);
        if(failBlock != nil){
            failBlock(errorCode);
        }
    }];
}

- (void)sendMessageWithModel:(MessageInfoModel *)model completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    NSMutableDictionary *dataParams = [NSMutableDictionary dictionary];
    dataParams[@"account"] = model.account;
    dataParams[@"content"] = model.content;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"cmd"] = @(MessageCmdTypeChat);
    params[@"data"] = dataParams;
    
    AgoraLogInfo(@"send message params:%@", params);
    
    NSString *messageBody = [JsonParseUtil dictionaryToJson:params];
    [self.signalManager sendMessage:messageBody completeSuccessBlock:^{
        
        AgoraLogInfo(@"send message success");
        if(successBlock != nil){
            successBlock();
        }

    } completeFailBlock:^(NSInteger errorCode) {
        AgoraLogInfo(@"send message fail errorCode:%ld", (long)errorCode);
        if(failBlock != nil){
            failBlock(errorCode);
        }
    }];
}

- (void)releaseSignalResources {
    AgoraLogInfo(@"releaseSignalResources");
    [self.signalManager releaseResources];
}

#pragma mark SignalManagerDelegate
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    
    AgoraLogInfo(@"connectionStateChanged state:%ld reason:%d", (long)state, reason);
    
    if([self.signalDelegate respondsToSelector:@selector(didReceivedConnectionStateChanged:)]) {
        [self.signalDelegate didReceivedConnectionStateChanged:state];
    }
}

- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    
    AgoraLogInfo(@"messageReceived:%@ fromPeer:%@", message.text, peerId);
    
    NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:message.text];
    SignalP2PModel *model = [SignalP2PModel yy_modelWithDictionary:dict];

    if([self.signalDelegate respondsToSelector:@selector(didReceivedPeerSignal:)]) {
        [self.signalDelegate didReceivedPeerSignal:model];
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {

    AgoraLogInfo(@"messageReceived:%@", message.text);
    
    NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:message.text];
    
    if([dict[@"cmd"] integerValue] == MessageCmdTypeChat) {
        
        if([self.signalDelegate respondsToSelector:@selector(didReceivedMessage:)]) {
            
            MessageModel *model = [MessageModel yy_modelWithDictionary:dict];
            model.data.isSelfSend = NO;
            [self.signalDelegate didReceivedMessage:model.data];
        }
        
    } else if([dict[@"cmd"] integerValue] == MessageCmdTypeUpdate || [dict[@"cmd"] integerValue] == MessageCmdTypeCourse) {
        
        if([self.signalDelegate respondsToSelector:@selector(didReceivedSignal:)]) {
            
            SignalMessageModel *model = [SignalMessageModel yy_modelWithDictionary:dict];
            [self.signalDelegate didReceivedSignal:model.data];
        }
        
    } else if([dict[@"cmd"] integerValue] == MessageCmdTypeReplay) {
        
        if([self.signalDelegate respondsToSelector:@selector(didReceivedReplaySignal:)]) {
            
            MessageModel *model = [MessageModel yy_modelWithDictionary:dict];
            [self.signalDelegate didReceivedReplaySignal:model.data];
        }
    }
}

@end
