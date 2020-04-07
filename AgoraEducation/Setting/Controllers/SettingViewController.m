//
//  SettingViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/16.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingViewCell.h"
#import "EyeCareModeUtil.h"
#import "HttpManager.h"
#import "SettingUploadViewCell.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource,SettingCellDelegate>
@property (nonatomic, weak) UITableView *settingTableView;
@property (nonatomic, weak) SettingUploadViewCell *uploadViewCell;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.title = NSLocalizedString(@"SettingText", nil);
    [self setUpView];
    [self setupGestureRecognizer];
}

- (void)setupGestureRecognizer {
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    gr.numberOfTapsRequired = 5;
    [self.view addGestureRecognizer:gr];
}

- (void)onTap:(UITapGestureRecognizer *)gr {
    
    NSString *currentEnv = @"当前测试环境";
    if(env == EnvTypeTest) {
        currentEnv = @"当前测试环境";
    } else if(env == EnvTypePre) {
        currentEnv = @"当前预发布环境";
    } else if(env == EnvTypeFormal) {
        currentEnv = @"当前正式环境";
    }
    
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:currentEnv style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *test = [UIAlertAction actionWithTitle:@"测试环境" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        env = EnvTypeTest;
        AgoraLogInfo(@"切换 测试环境");
    }];
    UIAlertAction *pre = [UIAlertAction actionWithTitle:@"预发布环境" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        env = EnvTypePre;
        AgoraLogInfo(@"切换 预发布环境");
    }];
    UIAlertAction *formal = [UIAlertAction actionWithTitle:@"正式环境" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        env = EnvTypeFormal;
        AgoraLogInfo(@"切换 正式环境");
    }];
    
    [alertController addAction:cancle];
    [alertController addAction:test];
    [alertController addAction:pre];
    [alertController addAction:formal];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)setUpView {
    UITableView *settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:(UITableViewStylePlain)];
    settingTableView.dataSource = self;
    settingTableView.delegate = self;
    [self.view addSubview:settingTableView];
    self.settingTableView = settingTableView;
    settingTableView.tableFooterView = [[UIView alloc] init];
    
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    CGRect rectNav = self.navigationController.navigationBar.frame;
    
    UILabel *footView = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - rectStatus.size.height - rectNav.size.height - 50, kScreenWidth, 20)];
    footView.textAlignment = NSTextAlignmentCenter;

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    footView.text = [NSString stringWithFormat:@"v%@",app_Version];
    
    footView.font = [UIFont systemFontOfSize:16];
    [settingTableView addSubview:footView];

    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"page-prev"] forState:(UIControlStateNormal)];
    [backButton addTarget:self action:@selector(backBarButton:) forControlEvents:(UIControlEventTouchUpInside)];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =item;
}

- (void)backBarButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
        if (!cell) {
            cell = [[SettingViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"SettingCell"];
        }
        cell.delegate = self;
        [cell switchOn:[[EyeCareModeUtil sharedUtil] queryEyeCareModeStatus]];
        return cell;
    } else {
        SettingUploadViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingUploadCell"];
        if (!cell) {
            cell = [[SettingUploadViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"SettingUploadCell"];
        }
        self.uploadViewCell = cell;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 1){
        [self.uploadViewCell uploadLog];
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.f;
}

- (void)settingSwitchCallBack:(UISwitch *)sender {
    [[EyeCareModeUtil sharedUtil] switchEyeCareMode:sender.on];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
