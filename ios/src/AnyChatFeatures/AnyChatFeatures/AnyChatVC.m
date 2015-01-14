//
//  VideoVC.m
//  AnyChatFeatures
//
//  Created by alexChen .
//  Copyright (c) 2014年 GuangZhou BaiRui NetWork Technology Co.,Ltd. All rights reserved.
//

#import "AnyChatVC.h"

@interface AnyChatVC ()

@end

@implementation AnyChatVC

@synthesize anyChat;
@synthesize videoVC;
@synthesize theOnLineLoginState;
@synthesize theVersionLab;
@synthesize theStateInfo;
@synthesize theUserName;
@synthesize theServerIP;
@synthesize theServerPort;
@synthesize theLoginBtn;
@synthesize theHideKeyboardBtn;
@synthesize theFeaturesName;
@synthesize theFeaturesNO;
@synthesize theMyUserName;
@synthesize theMyUserID;
@synthesize onlineUserMArray;
@synthesize theTargetUserID;
@synthesize theTargetUserName;
@synthesize theSnapShotAlertView;
@synthesize theVideoRecordAlertView;
@synthesize theVideoRecordMArray;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    return self;
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AnyChatNotifyHandler:) name:@"ANYCHATNOTIFY" object:nil];
    
    [AnyChatPlatform InitSDK:0];
    
    anyChat = [[AnyChatPlatform alloc] init];
    anyChat.notifyMsgDelegate = self;
    anyChat.textMsgDelegate = self;
    anyChat.transDataDelegate = self;
    anyChat.recordSnapShotDelegate = self;
    anyChat.videoCallDelegate = self;
    
    self.theVideoRecordMArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    //创建默认视频参数
    [[SettingVC sharedSettingVC] createObjPlistFileToDocumentsPath];
    
    //传输文件的开发调试模式
    //[AnyChatPlatform UserInfoControl:-1 :BRAC_USERINFO_CTRLCODE_DEBUGLOG :4 :1 :@""];
    
    //获取APP沙盒路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //设置自定义录像储存路径
    NSString  *myRecordDirectory = [documentsDirectory stringByAppendingPathComponent:@"Record_mp4"];
    [AnyChatPlatform SetSDKOptionString:BRAC_SO_RECORD_TMPDIR :myRecordDirectory];
    //设置自定义抓图储存路径
    NSString  *myPhotoDirectory = [documentsDirectory stringByAppendingPathComponent:@"ShotPhoto_jpg"];
    [AnyChatPlatform SetSDKOptionString:BRAC_SO_SNAPSHOT_TMPDIR :myPhotoDirectory];
    //设置自定义接收文件储存路径
    NSString  *myTransFileDirectory = [documentsDirectory stringByAppendingPathComponent:@"TransFile"];
    [AnyChatPlatform SetSDKOptionString:BRAC_SO_CORESDK_TMPDIR :myTransFileDirectory];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self setUI];
}

#pragma mark - Memory Warning Method

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Shared Instance

kGCD_SINGLETON_FOR_CLASS(AnyChatVC);


#pragma mark -
#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}


#pragma mark - AnyChatNotifyMessageDelegate

// 连接服务器消息
- (void) OnAnyChatConnect:(BOOL) bSuccess
{
    if (bSuccess)
    {
        theStateInfo.text = @"• Success connected to server";
    }
}

// 用户登陆消息
- (void) OnAnyChatLogin:(int) dwUserId : (int) dwErrorCode
{
    self.onlineUserMArray = [NSMutableArray arrayWithCapacity:5];
    
    if(dwErrorCode == GV_ERR_SUCCESS)
    {
        //更新系统默认视频参数设置
        //[self updateLocalSettings];
        
        theOnLineLoginState = YES;
        self.theMyUserID = dwUserId;
        self.theMyUserName = self.theUserName.text;
        [self saveSettings];  //登陆信息归档
        theStateInfo.text = [NSString stringWithFormat:@" Login successed. Self UserId: %d", dwUserId];
        [theLoginBtn setBackgroundImage:[UIImage imageNamed:@"btn_logout_01"] forState:UIControlStateNormal];
    }
    else
    {
        theOnLineLoginState = NO;
        theStateInfo.text = [NSString stringWithFormat:@"• Login failed(ErrorCode:%i)",dwErrorCode];
    }
    
}

// 用户进入房间消息
- (void) OnAnyChatEnterRoom:(int) dwRoomId : (int) dwErrorCode
{
    //更新用户自定义视频参数设置
    [[SettingVC sharedSettingVC] updateUserVideoSettings];
    
    if (dwErrorCode != 0)
    {
        theStateInfo.text = [NSString stringWithFormat:@"• Enter room failed(ErrorCode:%i)",dwErrorCode];
    }
    
    [[UserListVC sharedUserListVC].onLineUserTableView reloadData];
}

// 房间在线用户消息
- (void) OnAnyChatOnlineUser:(int) dwUserNum : (int) dwRoomId
{
    self.onlineUserMArray = [self getOnlineUserArray];
    [[UserListVC sharedUserListVC].onLineUserTableView reloadData];
}

// 用户进入房间消息
- (void) OnAnyChatUserEnterRoom:(int) dwUserId
{
    self.onlineUserMArray = [self getOnlineUserArray];
    [[UserListVC sharedUserListVC].onLineUserTableView reloadData];
}

// 用户退出房间消息
- (void) OnAnyChatUserLeaveRoom:(int) dwUserId
{
    if (self.theTargetUserID == dwUserId)
    {
        VideoVC *theVideoVC = [[VideoVC alloc] init];
        [theVideoVC FinishVideoChat];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        NSString *theLeaveRoomName = [[NSString alloc] initWithFormat:@"\"%@\"已离开房间!",self.theTargetUserName];
        NSString *theLeaveRoomID = [[NSString alloc] initWithFormat:@"\"%i\"Leave Room!",self.theTargetUserID];
        [self showInfoAlertView:theLeaveRoomName :theLeaveRoomID];
        
        self.theTargetUserID = -1;
    }
    
    self.onlineUserMArray = [self getOnlineUserArray];
    [[UserListVC sharedUserListVC].onLineUserTableView reloadData];
}

// 网络断开消息
- (void) OnAnyChatLinkClose:(int) dwErrorCode
{
    [videoVC FinishVideoChat];
    [AnyChatPlatform LeaveRoom:-1];
    [AnyChatPlatform Logout];
    
    [[UserListVC sharedUserListVC].onlineUserMArray removeAllObjects];
    [[UserListVC sharedUserListVC].onLineUserTableView reloadData];
    
    theStateInfo.text = [NSString stringWithFormat:@"• OnLinkClose(ErrorCode:%i)",dwErrorCode];
    theOnLineLoginState = NO;
    [theLoginBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_01"] forState:UIControlStateNormal];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    UIAlertView *networkAlertView = [[UIAlertView alloc] initWithTitle:@"网络断开,请重新登录."
                                                        message:@"Network disconnection."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定",nil];
    [networkAlertView show];
}


#pragma mark - AnyChatTextMsgDelegate
// 发送文字的回调函数
- (void) OnAnyChatTextMsgCallBack:(int) dwFromUserid : (int) dwToUserid : (BOOL) bSecret : (NSString*) lpMsgBuf
{
    NSString *s_targetUserIDStr = [[NSString alloc] initWithFormat:@"%i",dwFromUserid];
    NSString *s_targetUserNameStr = [AnyChatPlatform GetUserName:dwFromUserid];
    
    if (lpMsgBuf != nil)
    {
        [[TextMsg_TransBufferVC sharedTextMsg_TransBufferVC].theMsgMArray
         addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                    s_targetUserIDStr,@"targetUserIDStr",
                    s_targetUserNameStr,@"targetUserNameStr",
                    lpMsgBuf,@"contentStr",
                    @"receive",@"ACTStatus", nil]];
        
        [[TextMsg_TransBufferVC sharedTextMsg_TransBufferVC] TableViewReload];
    }
}


#pragma mark - AnyChatTransDataDelegate
// 透明通道回调函数
- (void) OnAnyChatTransBufferCallBack:(int) dwUserid : (NSData*) lpBuf
{
    NSString *s_targetUserIDStr = [[NSString alloc] initWithFormat:@"%i",dwUserid];
    NSString *s_targetUserNameStr = [AnyChatPlatform GetUserName:dwUserid];
    
    if (lpBuf != nil)
    {
        NSString *s_contentStr = [[NSString alloc] initWithData:lpBuf encoding:NSUTF8StringEncoding];
        [[TextMsg_TransBufferVC sharedTextMsg_TransBufferVC].theMsgMArray
         addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                    s_targetUserIDStr,@"targetUserIDStr",
                    s_targetUserNameStr,@"targetUserNameStr",
                    s_contentStr,@"contentStr",
                    @"receive",@"ACTStatus", nil]];
    
        [[TextMsg_TransBufferVC sharedTextMsg_TransBufferVC] TableViewReload];
    }
}

// 透明通道数据扩展回调函数
- (void) OnAnyChatTransBufferExCallBack:(int) dwUserid : (NSData*) lpBuf : (int) wParam : (int) lParam : (int) dwTaskId{
}

// 文件传输回调函数
- (void) OnAnyChatTransFileCallBack:(int) dwUserid : (NSString*) lpFileName : (NSString*) lpTempFilePath : (int) dwFileLength : (int) wParam : (int) lParam : (int) dwTaskId
{
    NSString *s_targetUserNameStr = [AnyChatPlatform GetUserName:dwUserid];
    NSMutableDictionary *s_theTableViewRowDataMDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [s_theTableViewRowDataMDict setValue:[[NSNumber alloc] initWithInt:dwUserid] forKey:@"targetUserIDNum"];
    [s_theTableViewRowDataMDict setValue:s_targetUserNameStr forKey:@"targetUserNameStr"];

    [s_theTableViewRowDataMDict setValue:@"image" forKey:@"fileTypeStr"];
    [s_theTableViewRowDataMDict setValue:@"receive" forKey:@"ACTStatusStr"];
    [s_theTableViewRowDataMDict setValue:lpTempFilePath forKey:@"contentPathStr"];
    
    [[TransFileVC sharedTransFileVC].theTableViewDataMArray addObject:s_theTableViewRowDataMDict];
    [[TransFileVC sharedTransFileVC] TableViewReload];
    
    UIAlertView *s_filePathAlert = [[UIAlertView alloc] initWithTitle:@"文件保存地址!"
                                                               message:lpFileName
                                                              delegate:nil
                                                     cancelButtonTitle:@"确定"
                                                     otherButtonTitles: nil];
    [s_filePathAlert show];
}

// 通信数据回调函数
- (void) OnAnyChatSDKFilterDataCallBack:(NSData*) lpBuf{
//  SDK Filter
}


#pragma mark - AnyChatRecordSnapShotDelegate
// 录像完成事件
- (void) OnAnyChatRecordCallBack:(int) dwUserid : (NSString*) lpFileName : (int) dwElapse : (int) dwFlags : (int) dwParam : (NSString*) lpUserStr
{
    theVideoRecordAlertView = [[UIAlertView alloc] initWithTitle:@"视频保存:"
                                                         message:lpFileName
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"预览录制",@"取消",nil];
    [theVideoRecordAlertView show];
    
    NSMutableDictionary *theVideoRecordCellMDict = [NSMutableDictionary dictionaryWithCapacity:4];
    [theVideoRecordCellMDict setValue:[[NSNumber alloc] initWithInt:dwUserid] forKey:@"targetUserIDNum"];
    [theVideoRecordCellMDict setValue:[TransFileVC sharedTransFileVC].getTimeNow forKey:@"productTimeStr"];
    [theVideoRecordCellMDict setValue:@"mp4" forKey:@"fileTypeStr"];
    [theVideoRecordCellMDict setValue:lpFileName forKey:@"contentPathStr"];
    //Save the record
    [self.theVideoRecordMArray addObject:theVideoRecordCellMDict];
}

// 抓拍完成事件
- (void) OnAnyChatSnapShotCallBack:(int) dwUserid : (NSString*) lpFileName : (int) dwFlags : (int) dwParam : (NSString*) lpUserStr
{
    theSnapShotAlertView = [[UIAlertView alloc] initWithTitle:@"照片保存:"
                                                      message:lpFileName
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"抓拍预览",@"取消",nil];
    [theSnapShotAlertView show];
}


// 视频呼叫回调事件协议
#pragma mark - AnyChatCallDelegate

- (void) OnAnyChatVideoCallEventCallBack:(int) dwEventType : (int) dwUserId : (int) dwErrorCode : (int) dwFlags : (int) dwParam : (NSString*) lpUserStr{
    
    self.theTargetUserID = dwUserId;
    NSString *s_theCallbackUserName = [AnyChatPlatform GetUserName:dwUserId];
    self.theTargetUserName = s_theCallbackUserName;
    
    switch (dwEventType)
    {
        case BRAC_VIDEOCALL_EVENT_REQUEST:
        {
            [[UserListVC sharedUserListVC] showReplyAlertViewWithName:s_theCallbackUserName ID:dwUserId];
            break;
        }
            
        case BRAC_VIDEOCALL_EVENT_REPLY:
        {
            switch (dwErrorCode)
            {
                case GV_ERR_VIDEOCALL_CANCEL:
                {
                    [self dimissAlertView:[UserListVC sharedUserListVC].theReplyAlertView];
                    [self showInfoAlertView:@"用户取消会话" :@"CANCEL"];
                    [[UserListVC sharedUserListVC].theAudioPlayer stop];
                    
                    break;
                }
                    
                case GV_ERR_VIDEOCALL_REJECT:
                {
                    if ([UserListVC sharedUserListVC].theWaitingAlertView != nil)
                    {
                        [self dimissAlertView:[UserListVC sharedUserListVC].theWaitingAlertView];
                    }
                    
                    [self showInfoAlertView:@"用户拒绝会话" :@"REJECT"];
                    
                    break;
                }
                    
                case GV_ERR_VIDEOCALL_OFFLINE:
                {
                    if ([UserListVC sharedUserListVC].theWaitingAlertView != nil)
                    {
                        [self dimissAlertView:[UserListVC sharedUserListVC].theWaitingAlertView];
                    }
                    [self showInfoAlertView:@"对方不在线" :@"OFFLINE"];
                    
                    break;
                }
                    
                case GV_ERR_VIDEOCALL_BUSY:
                {
                    if ([UserListVC sharedUserListVC].theWaitingAlertView != nil)
                    {
                        [self dimissAlertView:[UserListVC sharedUserListVC].theWaitingAlertView];
                    }
                    [self showInfoAlertView:@"用户在忙" :@"BUSY"];
                    
                    break;
                }
                    
                case GV_ERR_VIDEOCALL_TIMEOUT:
                {
                    if ([UserListVC sharedUserListVC].theWaitingAlertView != nil)
                    {
                        [self dimissAlertView:[UserListVC sharedUserListVC].theWaitingAlertView];
                    }
                    [self showInfoAlertView:@"会话请求超时" :@"TIMEOUT"];
                    
                    break;
                }
                    
                case GV_ERR_VIDEOCALL_DISCONNECT:
                {
                    if ([UserListVC sharedUserListVC].theWaitingAlertView != nil)
                    {
                        [self dimissAlertView:[UserListVC sharedUserListVC].theWaitingAlertView];
                    }
                    [self showInfoAlertView:@"网络断线" :@"DISCONNECT"];
                    
                    break;
                }
                    
                case GV_ERR_VIDEOCALL_NOTINCALL:
                {
                    if ([UserListVC sharedUserListVC].theWaitingAlertView != nil)
                    {
                        [self dimissAlertView:[UserListVC sharedUserListVC].theWaitingAlertView];
                    }
                    [self showInfoAlertView:@"用户不在呼叫状态" :@"NOTINCALL"];
                    
                    break;
                }
                    
            }
            
            break;
        }

        case BRAC_VIDEOCALL_EVENT_START:
        {
            if ([UserListVC sharedUserListVC].theWaitingAlertView != nil)
            {
                [self dimissAlertView:[UserListVC sharedUserListVC].theWaitingAlertView];
            }
            [[UserListVC sharedUserListVC].theAudioPlayer stop];
            
            //[AnyChatPlatform EnterRoom:dwParam :@""];
            [self.navigationController pushViewController:[[UserListVC sharedUserListVC] pushVC] animated:YES];
            
            break;
        }
            
        case BRAC_VIDEOCALL_EVENT_FINISH:
        {
            VideoVC *s_videoVC = [VideoVC new];
            [s_videoVC FinishVideoChat];
            [self showInfoAlertView:@"会话结束!" :@"Finish"];
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2]
                                                  animated:YES];
            break;
        }
 
    }
    
}


#pragma mark -
#pragma mark - Get & Save Settings Method

- (id) GetServerIP
{
    NSString* serverIP;
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:kAnyChatSettingsFileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSMutableArray* array = [[NSMutableArray alloc]initWithContentsOfFile:filePath];
        serverIP =  [array objectAtIndex:0];
        
        if([serverIP length] == 0)
        {
            theServerIP.text = @"demo.anychat.cn";
            serverIP = theServerIP.text;
        }
    }
    else
    {
        theServerIP.text = @"demo.anychat.cn";
        serverIP = theServerIP.text;
    }
    return serverIP;
}

- (id) GetServerPort
{
    NSString* serverPort;
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:kAnyChatSettingsFileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSMutableArray* array = [[NSMutableArray alloc]initWithContentsOfFile:filePath];
        serverPort = [array objectAtIndex:1];
        
        if([serverPort intValue] == 0 || [serverPort length] == 0)
        {
            theServerPort.text = @"8906";
            serverPort = theServerPort.text;
        }
    }
    else
    {
        theServerPort.text = @"8906";
        serverPort = theServerPort.text;
    }
    return serverPort;
}

- (id) GetUserName
{
    NSString* userName;
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:kAnyChatSettingsFileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSMutableArray* array = [[NSMutableArray alloc]initWithContentsOfFile:filePath];
        userName =  [array objectAtIndex:2];
        
        if([userName length] == 0)
        {
            theUserName.text = @"AnyChat";
            userName = theServerIP.text;
        }
    }
    else
    {
        theUserName.text = @"AnyChat";
        userName = theUserName.text;
    }
    return userName;
}

- (void)saveSettings
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:kAnyChatSettingsFileName];
    [[NSArray arrayWithObjects:theServerIP.text,theServerPort.text,theUserName.text, nil] writeToFile:filePath atomically:YES];
}


#pragma mark - Instance Method

- (void)AnyChatNotifyHandler:(NSNotification*)notify
{
    NSDictionary* dict = notify.userInfo;
    [anyChat OnRecvAnyChatNotify:dict];
}

- (NSMutableArray *) getOnlineUserArray
{
    NSMutableArray *onLineUserList = [[NSMutableArray alloc] initWithArray:[AnyChatPlatform GetOnlineUser]];
    [onLineUserList insertObject:[NSString stringWithFormat:@"%i",self.theMyUserID] atIndex:0];
    return onLineUserList;
}

- (IBAction)hideKeyBoard
{
    [theServerIP resignFirstResponder];
    [theServerPort resignFirstResponder];
    [theUserName resignFirstResponder];
}

- (IBAction)OnLoginBtnClicked:(id)sender
{
    if (theOnLineLoginState == YES)
    {
        [self OnLogout];
    }
    else
    {
        [self OnLogin];
    }
}

- (void) OnLogin
{
    if (theOnLineLoginState == NO)
    {
        [self showLoadingAnimated];
        
        if([theServerIP.text length] == 0)
        {
            theServerIP.text = [self GetServerIP];
        }
        if([theServerPort.text length] == 0)
        {
            theServerPort.text = [self GetServerPort];
        }
        if([theUserName.text length] == 0)
        {
            theUserName.text = [self GetUserName];
        }
        [AnyChatPlatform Connect:theServerIP.text : [theServerPort.text intValue]];
        [AnyChatPlatform Login:theUserName.text : @""];
    }
    
    [self hideKeyBoard];
}

- (void) OnLogout
{
    if (theOnLineLoginState == YES)
    {
        [AnyChatPlatform Logout];
        
        theOnLineLoginState = NO;
        
        theStateInfo.text = @"• Logout Server.";
        [theLoginBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_01"] forState:UIControlStateNormal];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)showSnapShotPhoto:(NSString *)theFilePath transform:(NSString *)transformParam
{   //Read the photo
    NSString *s_filesName = [theFilePath lastPathComponent];
    UIImage *s_Image = [UIImage imageWithContentsOfFile:theFilePath];

    UIImageView *theSnapShotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44,kSelfView_Width,kSelfView_Height-44)];
    theSnapShotImageView.image = s_Image;
    theSnapShotImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([transformParam isEqualToString:@"Portrait"])
    {
        theSnapShotImageView.layer.transform = kLayer_Z_Axis_3DRotation(90.0);
    }
    
    ShowVC *theShowPhotoVC = [ShowVC new];
    [theShowPhotoVC.view addSubview:theSnapShotImageView];
    theShowPhotoVC.theShowVCNItem.title = s_filesName;
    theShowPhotoVC.theVideoRecordTableView.hidden = YES;
    theShowPhotoVC.theShowVCNItem.hidesBackButton = YES;
    theShowPhotoVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:theShowPhotoVC animated:YES completion:nil];
}

#pragma mark - AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == theSnapShotAlertView)
    {
        if (buttonIndex == 0)
        {
            [self showSnapShotPhoto:theSnapShotAlertView.message transform:@""];
        }
    }
    if (alertView == theVideoRecordAlertView)
    {
        if (buttonIndex == 0)
        {
            ShowVC *theShowVC = [ShowVC new];
            theShowVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self.navigationController presentViewController:theShowVC animated:YES completion:nil];
        }
    }
}


#pragma mark - AlertView method

- (NSString *)showInfoAlertView:(NSString *)Title : (NSString *)subTitle
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Title
                                                        message:subTitle
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil,nil];
    [alertView show];
    
    [self performSelector:@selector(dimissAlertView:) withObject:alertView afterDelay:1.5];
    
    return subTitle;
}

- (void) dimissAlertView:(UIAlertView *)alert {
    if(alert){
        [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
    }
}


#pragma mark - Loading Animation Method

- (void)showLoadingAnimated
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"AnyChatFeatures";
    HUD.detailsLabelText = @"Loading...";
    
    [HUD showWhileExecuting:@selector(onLoginLoadingAnimatedRunTime) onTarget:self withObject:nil animated:YES];
}

- (void)onLoginLoadingAnimatedRunTime
{
    int theTimes = 0;
    while (theOnLineLoginState == NO && theTimes < 6)
    {
        sleep(1);
        theTimes++;
        
        if (theTimes == 5 ) {
            [self timeOutMsg];
        }
    }
    
    if (theOnLineLoginState == YES )
    {
        FeaturesListVC *featuresListVC = [[FeaturesListVC alloc] init];
        [self.navigationController pushViewController:featuresListVC animated:YES];
    }
}

- (void) timeOutMsg
{
    if (theOnLineLoginState == NO)
    {
        theStateInfo.text = @"Login timeout,please check the Network and Setting.";
    }
}


#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return NO;
}


#pragma mark - UI Controls

- (void)setUI
{
    [self.navigationController setNavigationBarHidden:YES];
    
    theUserName.text = [self GetUserName];
    theServerIP.text = [self GetServerIP];
    theServerPort.text = [self GetServerPort];
    
    [theServerIP addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [theServerPort addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [theUserName addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    if (k_sysVersion < 7.0)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }

    theVersionLab.text = [AnyChatPlatform GetSDKVersion];
    
    [self prefersStatusBarHidden];
    
}


@end
