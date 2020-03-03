//
//  BigEducationManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/31.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager+GlobalStates.h"
#import "BaseEducationManager+Signal.h"
#import "BaseEducationManager+WhiteBoard.h"
#import "BaseEducationManager+RTC.h"

NS_ASSUME_NONNULL_BEGIN

@interface BigEducationManager : BaseEducationManager

/* ==================================>Session Model<================================ */
@property (nonatomic, strong) RoomModel * _Nullable roomModel;
@property (nonatomic, strong) UserModel * _Nullable teacherModel;
@property (nonatomic, strong) UserModel * _Nullable studentModel;
@property (nonatomic, strong) NSMutableArray<UserModel *> *renderStudentModels;
@property (nonatomic, strong) NSMutableSet<NSString*> *rtcUids;
@property (nonatomic, strong) NSMutableArray<RTCVideoSessionModel*> *rtcVideoSessionModels;

/* ==================================>HTTPManager<================================ */
- (void)updateLinkStateWithValue:(BOOL)coVideo completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock;

/* ==================================>SignalManager<================================ */
- (void)sendPeerSignalWithModel:(SignalP2PType)type completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;

- (void)releaseResources;

@end

NS_ASSUME_NONNULL_END

