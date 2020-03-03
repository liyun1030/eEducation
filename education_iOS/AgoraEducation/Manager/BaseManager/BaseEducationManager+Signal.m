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

- (void)initSignalWithAppid:(NSString *)appid appToken:(NSString *)token userId:(NSString *)uid dataSourceDelegate:(id<SignalDelegate> _Nullable)signalDelegate completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock {
    
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

- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock {
    
    [self.signalManager joinChannelWithName:channelName completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)sendSignalWithModel:(SignalMessageInfoModel *)model completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock {
    
    NSMutableDictionary *dataParams = [NSMutableDictionary dictionary];
    dataParams[@"uid"] = @(model.uid);
    dataParams[@"account"] = model.account;
    dataParams[@"resource"] = model.resource;
    dataParams[@"value"] = @(model.value);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"cmd"] = @(MessageCmdTypeUpdate);
    params[@"data"] = dataParams;
    
    NSString *messageBody = [JsonParseUtil dictionaryToJson:params];
    [self.signalManager sendMessage:messageBody completeSuccessBlock:^{
      
        if(successBlock != nil){
            successBlock();
        }
        
    } completeFailBlock:^{
        if(failBlock != nil){
            failBlock();
        }
    }];
}

- (void)sendMessageWithModel:(MessageInfoModel *)model completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock {
    
    NSMutableDictionary *dataParams = [NSMutableDictionary dictionary];
    dataParams[@"account"] = model.account;
    dataParams[@"content"] = model.content;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"cmd"] = @(MessageCmdTypeChat);
    params[@"data"] = dataParams;
    
    NSString *messageBody = [JsonParseUtil dictionaryToJson:params];
    [self.signalManager sendMessage:messageBody completeSuccessBlock:^{

        if(successBlock != nil){
            successBlock();
        }

    } completeFailBlock:^{
        if(failBlock != nil){
            failBlock();
        }
    }];
}

- (void)releaseSignalResources {
    [self.signalManager releaseResources];
}

#pragma mark SignalManagerDelegate
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    
    if(state == AgoraRtmConnectionStateDisconnected) {
        [NSNotificationCenter.defaultCenter postNotificationName:NOTICE_KEY_ON_MESSAGE_DISCONNECT object:nil];
    }
}

- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    
    NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:message.text];
    SignalP2PModel *model = [SignalP2PModel yy_modelWithDictionary:dict];

    if([self.signalDelegate respondsToSelector:@selector(didReceivedPeerSignal:)]) {
        [self.signalDelegate didReceivedPeerSignal:model];
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {

    NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:message.text];
    
    if([dict[@"cmd"] integerValue] == MessageCmdTypeChat) {
        
        if([self.signalDelegate respondsToSelector:@selector(didReceivedMessage:)]) {
            
            MessageModel *model = [MessageModel yy_modelWithDictionary:dict];
            model.data.isSelfSend = NO;
            [self.signalDelegate didReceivedMessage:model.data];
        }
        
    } else if([dict[@"cmd"] integerValue] == MessageCmdTypeUpdate) {
        
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
