
//
//  BigClassViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BCViewController.h"
#import "BCSegmentedView.h"
#import "EEChatTextFiled.h"
#import "BCStudentVideoView.h"
#import "EETeacherVideoView.h"
#import "BCNavigationView.h"
#import "EEMessageView.h"
#import "UIView+Toast.h"

#define kLandscapeViewWidth    223

@interface BCViewController ()<BCSegmentedDelegate, UITextFieldDelegate, RoomProtocol, SignalDelegate, RTCDelegate, WhitePlayDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledRelativeTeacherViewLeftCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomConstraint;

@property (weak, nonatomic) IBOutlet EETeacherVideoView *teactherVideoView;
@property (weak, nonatomic) IBOutlet BCStudentVideoView *studentVideoView;
@property (weak, nonatomic) IBOutlet BCSegmentedView *segmentedView;
@property (weak, nonatomic) IBOutlet BCNavigationView *navigationView;
@property (weak, nonatomic) IBOutlet UIButton *handUpButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;

// white
@property (weak, nonatomic) IBOutlet UIView *whiteboardView;
@property (nonatomic, weak) WhiteBoardView *boardView;
@property (nonatomic, assign) NSInteger segmentedIndex;
@property (nonatomic, assign) NSInteger unreadMessageCount;
@property (nonatomic, assign) StudentLinkState linkState;
@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, assign) BOOL isRenderShare;

@property (nonatomic, assign) BOOL hasSignalReconnect;
@end

@implementation BCViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addNotification];
}

-(void)initData {
    
    self.isRenderShare = NO;
    self.hasSignalReconnect = NO;
    
    self.segmentedView.delegate = self;
    self.studentVideoView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    
    EduConfigModel *configModel = self.educationManager.eduConfigModel;
    self.messageView.userToken = configModel.userToken;
    self.messageView.roomId = configModel.roomId;
    self.messageView.appId = configModel.appId;
    
    [self.navigationView updateClassName:configModel.className];
    
    WEAK(self);
    // api -> init rtm -> rtc & white
    [self.educationManager getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {

        [weakself setupSignalWithSuccessBolck:^{
            [weakself setupRTC];
            [weakself setupWhiteBoard];

            // link
            if(weakself.educationManager.renderStudentModels.count > 0) {
                UserModel *renderModel = weakself.educationManager.renderStudentModels.firstObject;
                [weakself.educationManager.rtcUids addObject:@(renderModel.uid).stringValue];
            }
            
            [weakself updateChatViews];
        }];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        [weakself showToast:errMessage];
    }];
}

- (void)updateViewOnReconnected{
    WEAK(self);
    
    if(self.educationManager.renderStudentModels.count > 0){
        UserModel *renderStudentModel = [self.educationManager.renderStudentModels firstObject];
        [self removeStudentCanvas:renderStudentModel.uid];
    }
    
    [self.educationManager getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {
        
        [weakself updateChatViews];
        [weakself.educationManager disableCameraTransform:roomInfoModel.room.lockBoard];

        [weakself checkNeedRender];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
 
    }];
}

- (void)setupRTC {
    
    EduConfigModel *configModel = self.educationManager.eduConfigModel;
    
    [self.educationManager initRTCEngineKitWithAppid:configModel.appId clientRole:RTCClientRoleBroadcaster dataSourceDelegate:self];
    
    WEAK(self);
    [self.educationManager joinRTCChannelByToken:configModel.rtcToken channelId:configModel.channelName info:nil uid:configModel.uid joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [weakself.educationManager.rtcUids addObject:uidStr];
        [weakself checkNeedRender];
    }];
}

- (void)setupSignalWithSuccessBolck:(void (^)(void))successBlock {

    NSString *appid = self.educationManager.eduConfigModel.appId;
    NSString *appToken = self.educationManager.eduConfigModel.rtmToken;
    NSString *uid = @(self.educationManager.eduConfigModel.uid).stringValue;
    
    WEAK(self);
    [self.educationManager initSignalWithAppid:appid appToken:appToken userId:uid dataSourceDelegate:self completeSuccessBlock:^{
        
        NSString *channelName = weakself.educationManager.eduConfigModel.channelName;
        [weakself.educationManager joinSignalWithChannelName:channelName completeSuccessBlock:^{
            if(successBlock != nil){
                successBlock();
            }
            
        } completeFailBlock:^(NSInteger errorCode) {
            NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"JoinSignalFailedText", nil), (long)errorCode];
            [weakself showToast:errMsg];
        }];
        
    } completeFailBlock:^(NSInteger errorCode) {
        NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"InitSignalFailedText", nil), (long)errorCode];
        [weakself showToast:errMsg];
    }];
}

- (void)muteVideoStream:(BOOL)mute {
    
    if(self.educationManager.renderStudentModels.count == 0) {
        return;
    }
    
    WEAK(self);
    [self.educationManager updateEnableVideoWithValue:!mute completeSuccessBlock:^{
        
        UserModel *renderModel = weakself.educationManager.renderStudentModels.firstObject;
        [weakself updateStudentViews:renderModel remoteVideo:NO];
        
        [weakself sendSignalWithType:NSStringFromSignalValueType(SignalValueTypeVideo) value:mute success:^{
            
        } fail:^(NSInteger errorCode) {
            NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"SendMessageFailedText", nil), (long)errorCode];
            [weakself showToast:errMsg];
        }];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        
        [weakself showToast:errMessage];
        UserModel *renderModel = weakself.educationManager.renderStudentModels.firstObject;
        [weakself updateStudentViews:renderModel remoteVideo:NO];
    }];
}

- (void)sendSignalWithType:(NSString *)type value:(BOOL)mute success:(void (^ _Nullable) (void))successBlock fail:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    SignalMessageInfoModel *model = [SignalMessageInfoModel new];
    model.uid = self.educationManager.eduConfigModel.uid;
    model.account = self.educationManager.eduConfigModel.userName;
    model.resource = type;
    model.value = mute ? 0 : 1;
    [self.educationManager sendSignalWithModel:model completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)muteAudioStream:(BOOL)mute {

   if(self.educationManager.renderStudentModels.count == 0) {
       return;
   }
   
   WEAK(self);
   [self.educationManager updateEnableAudioWithValue:!mute completeSuccessBlock:^{
       
       UserModel *renderModel = weakself.educationManager.renderStudentModels.firstObject;
       [weakself updateStudentViews:renderModel remoteVideo:NO];
      
       [weakself sendSignalWithType:NSStringFromSignalValueType(SignalValueTypeAudio) value:mute success:^{
           
       } fail:^(NSInteger errorCode) {
           NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"SendMessageFailedText", nil), (long)errorCode];
           [weakself showToast:errMsg];
       }];
       
   } completeFailBlock:^(NSString * _Nonnull errMessage) {
       
       [weakself showToast:errMessage];
       UserModel *renderModel = weakself.educationManager.renderStudentModels.firstObject;
       [weakself updateStudentViews:renderModel remoteVideo:NO];
   }];
}

- (void)checkNeedRender {
    
    if(self.educationManager.teacherModel != nil) {
        NSInteger teacherUid = self.educationManager.teacherModel.uid;
        if([self.educationManager.rtcUids containsObject:@(teacherUid).stringValue]){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", teacherUid];
            NSArray<RTCVideoSessionModel *> *filteredArray = [self.educationManager.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
            if(filteredArray.count == 0){
                [self renderTeacherCanvas:teacherUid];
            }
            [self updateTeacherViews:self.educationManager.teacherModel];
        } else {
            [self removeTeacherCanvas];
        }
    } else {
        [self removeTeacherCanvas];
    }
    
    if(self.educationManager.renderStudentModels.count > 0) {
        UserModel *renderModel = self.educationManager.renderStudentModels.firstObject;
        NSInteger studentUid = renderModel.uid;
        if([self.educationManager.rtcUids containsObject:@(studentUid).stringValue]){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", studentUid];
            NSArray<RTCVideoSessionModel *> *filteredArray = [self.educationManager.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
            
            BOOL remote = NO;
            if(filteredArray.count == 0){
                if (studentUid == self.educationManager.eduConfigModel.uid) {
                    [self renderStudentCanvas:studentUid remoteVideo:remote];
                } else {
                    remote = YES;
                    [self renderStudentCanvas:studentUid remoteVideo:remote];
                }
            }
            [self updateStudentViews:renderModel remoteVideo:remote];
        }
    }
}

- (void)renderTeacherCanvas:(NSUInteger)uid {
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.teactherVideoView.teacherRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setupRTCVideoCanvas: model completeBlock:nil];
}

- (void)removeTeacherCanvas {

    if (self.segmentedIndex == 0) {
        self.handUpButton.hidden = YES;
    }
    [self.teactherVideoView updateSpeakerImageWithMuted:YES];
    self.teactherVideoView.defaultImageView.hidden = NO;
    [self.teactherVideoView updateAndsetTeacherName:@""];
}

- (void)renderShareCanvas:(NSUInteger)uid {
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.shareScreenView;
    model.renderMode = RTCVideoRenderModeFit;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setupRTCVideoCanvas:model completeBlock:nil];
    
    self.shareScreenView.hidden = NO;
    self.isRenderShare = YES;
}

- (void)removeShareCanvas:(NSUInteger)uid {
    self.shareScreenView.hidden = YES;
    self.isRenderShare = NO;
}

- (void)renderStudentCanvas:(NSUInteger)uid remoteVideo:(BOOL)remote {
    
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.studentVideoView.studentRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = remote ? RTCVideoCanvasTypeRemote : RTCVideoCanvasTypeLocal;
    [self.educationManager setupRTCVideoCanvas:model completeBlock:nil];

    [self.educationManager setRTCClientRole:RTCClientRoleBroadcaster];
}

- (void)removeStudentCanvas:(NSUInteger)uid {
    
    NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
    [self.educationManager.rtcUids removeObject: uidStr];
    
    [self.educationManager setRTCClientRole:RTCClientRoleAudience];
    [self.educationManager removeRTCVideoCanvas: uid];
    self.studentVideoView.defaultImageView.hidden = NO;
    self.studentVideoView.hidden = YES;
    [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
}

- (void)updateTeacherViews:(UserModel*)teacherModel {
    
    if(teacherModel == nil){
        return;
    }
    
    // update teacher views
    if (self.segmentedIndex == 0) {
        self.handUpButton.hidden = NO;
    }
    [self.teactherVideoView updateSpeakerImageWithMuted:!teacherModel.enableAudio];
    self.teactherVideoView.defaultImageView.hidden = teacherModel.enableVideo ? YES : NO;
    [self.teactherVideoView updateAndsetTeacherName: teacherModel.userName];
}

- (void)updateChatViews {

    RoomModel *roomModel = self.educationManager.roomModel;
     BOOL muteChat = roomModel != nil ? roomModel.muteAllChat : NO;
     if(!muteChat) {
         UserModel *studentModel = self.educationManager.studentModel;
         muteChat = studentModel.enableChat == 0 ? YES : NO;
     }
     self.chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
     self.chatTextFiled.contentTextFiled.placeholder = muteChat ? NSLocalizedString(@"ProhibitedPostText", nil) : NSLocalizedString(@"InputMessageText", nil);
}

- (void)updateStudentViews:(UserModel *)studentModel remoteVideo:(BOOL)remote {
    
    if(studentModel == nil){
        return;
    }
    
    self.studentVideoView.hidden = NO;
    
    [self.studentVideoView setButtonEnabled:!remote];
    [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup-x"] forState:(UIControlStateNormal)];

    [self.studentVideoView updateVideoImageWithMuted:studentModel.enableVideo == 0 ? YES : NO];
    [self.studentVideoView updateAudioImageWithMuted:studentModel.enableAudio == 0 ? YES : NO];

    [self.educationManager muteRTCLocalVideo:studentModel.enableVideo == 0 ? YES : NO];
    [self.educationManager muteRTCLocalAudio:studentModel.enableAudio == 0 ? YES : NO];
}

- (void)showToast:(NSString *)title {
    [self.navigationController.view makeToast:title];
}

- (void)setupView {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (@available(iOS 11, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
        
    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    [self.whiteboardView addSubview:boardView];
    self.boardView = boardView;
    boardView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];

    self.handUpButton.layer.borderWidth = 1.f;
    self.handUpButton.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    self.handUpButton.layer.backgroundColor = [UIColor colorWithHexString:@"FFFFFF"].CGColor;
    self.handUpButton.layer.cornerRadius = 6;

    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
}

- (void)handleDeviceOrientationChange:(NSNotification *)notification{

    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        {
            [self verticalScreenConstraints];
            [self.view layoutIfNeeded];
            [self.educationManager refreshWhiteViewSize];
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            [self landscapeScreenConstraints];
            [self.view layoutIfNeeded];
            [self.educationManager refreshWhiteViewSize];
        }
            break;
        default:
            break;
    }
}

- (void)stateBarHidden:(BOOL)hidden {
    [self setNeedsStatusBarAppearanceUpdate];
    self.isLandscape = hidden;
}

- (IBAction)handUpEvent:(UIButton *)sender {
    if(self.educationManager.renderStudentModels != nil) {
        UserModel *renderModel = self.educationManager.renderStudentModels.firstObject;
        if(renderModel.uid != self.educationManager.eduConfigModel.uid) {
            return;
        }
    }
    
    switch (self.linkState) {
        case StudentLinkStateIdle:
            [self studentApplyLink];
            break;
        case StudentLinkStateAccept:
            [self studentCancelLink];
            break;
        case StudentLinkStateApply:
            [self studentApplyLink];
            break;
        case StudentLinkStateReject:
            [self studentApplyLink];
            break;
        default:
            break;
    }
}

- (void)studentApplyLink {
    WEAK(self);
    [self.educationManager sendPeerSignalWithModel:SignalP2PTypeApply completeSuccessBlock:^{
        weakself.linkState = StudentLinkStateApply;
    } completeFailBlock:^(NSInteger errorCode) {
        NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"SendPeerMessageFailedText", nil), (long)errorCode];
        [weakself showToast:errMsg];
    }];
}

- (void)studentCancelLink {
    
    WEAK(self);
    [self.educationManager updateLinkStateWithValue:NO completeSuccessBlock:^{
        
        weakself.linkState = StudentLinkStateIdle;
        if(weakself.educationManager.renderStudentModels != nil) {
            UserModel *renderModel = weakself.educationManager.renderStudentModels.firstObject;
            [weakself removeStudentCanvas: renderModel.uid];
        }
        
        [weakself sendSignalWithType:NSStringFromSignalValueType(SignalValueTypeCoVideo) value:NO success:^{
            
        } fail:^(NSInteger errorCode) {
            NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"SendMessageFailedText", nil), (long)errorCode];
            [weakself showToast:errMsg];
        }];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        [weakself showToast:errMessage];
    }];
}

- (void)teacherAcceptLink {
    WEAK(self);
    [self.educationManager getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {
        
        weakself.linkState = StudentLinkStateAccept;
        weakself.tipLabel.hidden = NO;
        [weakself.tipLabel setText: NSLocalizedString(@"AcceptRequestText", nil)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           weakself.tipLabel.hidden = YES;
        });
        
        // link
        if(weakself.educationManager.renderStudentModels.count > 0) {
            UserModel *renderModel = weakself.educationManager.renderStudentModels.firstObject;
            [weakself.educationManager.rtcUids addObject:@(renderModel.uid).stringValue];
            
            [weakself renderStudentCanvas:renderModel.uid remoteVideo:NO];
            [weakself updateStudentViews:renderModel remoteVideo:NO];
        }
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        [weakself showToast:errMessage];
    }];
}

- (void)landscapeScreenConstraints {
    [self stateBarHidden:YES];

    self.handUpButton.hidden = self.educationManager.teacherModel ? NO: YES;
    self.chatTextFiled.hidden = NO;
    self.messageView.hidden = NO;
}

- (void)verticalScreenConstraints {
    [self stateBarHidden:NO];
    self.chatTextFiled.hidden = self.segmentedIndex == 0 ? YES : NO;
    self.messageView.hidden = self.segmentedIndex == 0 ? YES : NO;
    self.handUpButton.hidden = self.educationManager.teacherModel ? NO: YES;
    
    if(self.isRenderShare) {
        self.shareScreenView.hidden = NO;
    }
}

#pragma mark Notification
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageReconnecting) name:NOTICE_KEY_ON_MESSAGE_RECONNECTING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageConnected) name:NOTICE_KEY_ON_MESSAGE_CONNECTED object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        self.chatTextFiledRelativeTeacherViewLeftCon.active = NO;
        
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        self.textFiledBottomConstraint.constant = bottom;
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.chatTextFiledRelativeTeacherViewLeftCon.active = YES;
    self.textFiledBottomConstraint.constant = 0;
}

- (void)onMessageReconnecting {
    self.hasSignalReconnect = YES;
}
-(void)onMessageConnected {
    if(self.hasSignalReconnect){
        self.hasSignalReconnect = NO;
        [self updateViewOnReconnected];
    }
}

- (void)setupWhiteBoard {
    
    [self.educationManager initWhiteSDK:self.boardView dataSourceDelegate:self];
    
    RoomModel *roomModel = self.educationManager.roomModel;
    WEAK(self);
    [self.educationManager joinWhiteRoomWithBoardId:roomModel.boardId boardToken:roomModel.boardToken whiteWriteModel:NO  completeSuccessBlock:^(WhiteRoom * _Nullable room) {

        [weakself.educationManager disableCameraTransform:roomModel.lockBoard];
        
    } completeFailBlock:^(NSError * _Nullable error) {
        [weakself showToast:NSLocalizedString(@"JoinWhiteErrorText", nil)];
    }];
}

#pragma mark BCSegmentedDelegate
- (void)selectedItemIndex:(NSInteger)index {

    if (index == 0) {
        self.segmentedIndex = 0;
        self.messageView.hidden = YES;
        self.chatTextFiled.hidden = YES;
        self.handUpButton.hidden = self.educationManager.teacherModel ? NO: YES;
        if(self.isRenderShare) {
            self.shareScreenView.hidden = NO;
        }
    } else {
        self.segmentedIndex = 1;
        self.messageView.hidden = NO;
        self.chatTextFiled.hidden = NO;
        self.handUpButton.hidden = YES;
        self.unreadMessageCount = 0;
        [self.segmentedView hiddeBadge];
        self.shareScreenView.hidden = YES;
    }
}

#pragma mark RoomProtocol
- (void)closeRoom {
    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {
        
        if (weakself.linkState == StudentLinkStateAccept) {
            
            [weakself sendSignalWithType:NSStringFromSignalValueType(SignalValueTypeCoVideo) value:NO success:^{
                
            } fail:^(NSInteger errorCode) {
                NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"SendMessageFailedText", nil), (long)errorCode];
                [weakself showToast:errMsg];
            }];
        }
        [weakself.educationManager releaseResources];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return self.isLandscape;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark SignalDelegate
- (void)didReceivedPeerSignal:(SignalP2PModel *)model {
    
    switch (model.cmd) {
        case SignalP2PTypeApply:
        case SignalP2PTypeReject:
        {
            self.linkState = StudentLinkStateReject;
        }
            break;
        case SignalP2PTypeAccept:
        {
            [self teacherAcceptLink];
        }
            break;
        case SignalP2PTypeCancel:
        {
            self.linkState = StudentLinkStateIdle;
            [self removeStudentCanvas: self.educationManager.eduConfigModel.uid];
            [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
            
            self.tipLabel.hidden = NO;
            [self.tipLabel setText: NSLocalizedString(@"CancelRequestText", nil)];
            WEAK(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakself.tipLabel.hidden = YES;
            });
        }
            break;
        default:
            break;
    }
}

- (void)didReceivedSignal:(SignalMessageInfoModel *)model {
    
    NSArray<UserModel *> *sourceRenderStudentModels = [NSArray arrayWithArray:self.educationManager.renderStudentModels];
    
    WEAK(self);
    [self.educationManager getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {

        [weakself updateChatViews];
        [weakself.educationManager disableCameraTransform:roomInfoModel.room.lockBoard];
        
        if(model.uid == weakself.educationManager.teacherModel.uid) {
            
            [weakself updateTeacherViews:weakself.educationManager.teacherModel];
            
        } else {
            
            NSInteger selfUid = weakself.educationManager.eduConfigModel.uid;
            
            if(weakself.educationManager.renderStudentModels.count > 0) {
                UserModel *renderModel = weakself.educationManager.renderStudentModels.firstObject;
                BOOL remoteVideo = renderModel.uid != selfUid;
                
                if([model.resource isEqualToString:NSStringFromSignalValueType(SignalValueTypeCoVideo)]) {
                    [weakself renderStudentCanvas:renderModel.uid remoteVideo:remoteVideo];
                }
                [weakself updateStudentViews:renderModel remoteVideo:remoteVideo];
            } else if(sourceRenderStudentModels.count > 0) {
                UserModel *renderModel = sourceRenderStudentModels.firstObject;
                BOOL remoteVideo = renderModel.uid != selfUid;
                if([model.resource isEqualToString:NSStringFromSignalValueType(SignalValueTypeCoVideo)]) {
                    [weakself removeStudentCanvas:renderModel.uid];
                }
                [weakself updateStudentViews:renderModel remoteVideo:remoteVideo];
            }
        }

    } completeFailBlock:^(NSString * _Nonnull errMessage) {

        [weakself showToast:errMessage];

    }];
}
- (void)didReceivedMessage:(MessageInfoModel *)model {
    [self.messageView addMessageModel:model];
    if (self.messageView.hidden == YES) {
        self.unreadMessageCount = self.unreadMessageCount + 1;
        [self.segmentedView showBadgeWithCount:(self.unreadMessageCount)];
    }
}
- (void)didReceivedReplaySignal:(MessageInfoModel *)model {
    [self.messageView addMessageModel:model];
    if (self.messageView.hidden == YES) {
        self.unreadMessageCount = self.unreadMessageCount + 1;
        [self.segmentedView showBadgeWithCount:(self.unreadMessageCount)];
    }
}

#pragma mark RTCDelegate
- (void)rtcDidJoinedOfUid:(NSUInteger)uid {

    if(uid == kShareScreenUid) {
        [self renderShareCanvas: uid];
    } else {
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.educationManager.rtcUids addObject:uidStr];
        [self checkNeedRender];
    }
}

- (void)rtcDidOfflineOfUid:(NSUInteger)uid {
    
    if (uid == kShareScreenUid) {
        [self removeShareCanvas: uid];
    } else if (uid == self.educationManager.teacherModel.uid) {
        
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.educationManager.rtcUids removeObject:uidStr];
        [self removeTeacherCanvas];
    } else {
        [self removeStudentCanvas: uid];
    }
}

- (void)rtcNetworkTypeGrade:(RTCNetworkGrade)grade {
    
    switch (grade) {
        case RTCNetworkGradeHigh:
            [self.navigationView updateSignalImageName:@"icon-signal3"];
            break;
        case RTCNetworkGradeMiddle:
            [self.navigationView updateSignalImageName:@"icon-signal2"];
            break;
        case RTCNetworkGradeLow:
            [self.navigationView updateSignalImageName:@"icon-signal1"];
            break;
        default:
            [self.navigationView updateSignalImageName:@"icon-signal1"];
            break;
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard =  NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *content = textField.text;
    if (content.length > 0) {
        MessageInfoModel *model = [MessageInfoModel new];
        model.account = self.educationManager.eduConfigModel.userName;
        model.content = content;
        WEAK(self);
        [self.educationManager sendMessageWithModel:model completeSuccessBlock:^{
            [weakself.messageView addMessageModel:model];
        } completeFailBlock:^(NSInteger errorCode) {
            NSString *errMsg = [NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"SendMessageFailedText", nil), (long)errorCode];
            [weakself showToast:errMsg];
        }];
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

@end
