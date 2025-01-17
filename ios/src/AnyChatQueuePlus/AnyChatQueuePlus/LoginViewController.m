//
//  LoginViewController.m
//  队列界面
//
//  Created by j-bairui on 2016/11/5.
//  Copyright © 2016年 anychat. All rights reserved.
//

#import "LoginViewController.h"
#import "BusinessHallViewController.h"
#import "MBProgressHUD+JT.h"
#import "BusinessHall.h"
#import "BusinessListController.h"
#import "QueueViewController.h"
#import "VideoViewController.h"
#import "ServerQueueViewController.h"
#import "TextModelTool.h"
#import "TextModel.h"
#import "CustomButton.h"
#define kUserID 1001
#define kAnyChatIP @"demo.anychat.cn"
#define kAnyChatPort @"8906"
#define kAnyChatUserName @"AnyChatQueue"


@interface LoginViewController ()<UITextFieldDelegate,UIActionSheetDelegate,AnyChatNotifyMessageDelegate,AnyChatObjectEventDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UIButton *role;
@property (weak, nonatomic) IBOutlet UIButton *priority;
@property (weak, nonatomic) IBOutlet UITextField *server;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *AppId;
@property (weak, nonatomic) IBOutlet UIButton *userInfoSetting;
@property (weak, nonatomic) IBOutlet UIButton *routePolicy;
@property (weak, nonatomic) IBOutlet UIButton *autoRoute;

@property (weak, nonatomic) IBOutlet CustomButton *queue1;
@property (weak, nonatomic) IBOutlet CustomButton *queue2;
@property (weak, nonatomic) IBOutlet CustomButton *queue3;
@property (weak, nonatomic) IBOutlet CustomButton *queue4;

@property (weak,nonatomic) UIActionSheet *roleActionSheet;
@property (weak,nonatomic) UIActionSheet *priorityActionSheet;
@property (weak,nonatomic) UIActionSheet *userInfoSettingActionSheet;
@property (weak,nonatomic) UIActionSheet *routePolicyActionSheet;
@property (weak,nonatomic) UIActionSheet *autoRouteActionSheet;
@property (weak, nonatomic) IBOutlet UIView *settingAllView;
@property (weak, nonatomic) IBOutlet UIView *userInfoSettingView;
@property (weak, nonatomic) IBOutlet UIView *routeSettingView;

@property(nonatomic, strong)NSMutableArray *businessHallDicArr;     //营业厅字典数组
@property(nonatomic, strong)NSArray *businessHallObjArr;            //营业厅模型数组
@property(nonatomic, weak)UIPickerView *pickerView;
@property(nonatomic, assign)int selfUserId;                         //自己的用户id
@property(nonatomic, assign)int waitingBusinessId;                  //队列id


- (IBAction)setAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)roleAction:(id)sender;
- (IBAction)priorityAction:(id)sender;
- (IBAction)userInfoSettingAction:(id)sender;
- (IBAction)routePolicyAction:(id)sender;
- (IBAction)autoRouteAction:(id)sender;
- (IBAction)queue1Action:(id)sender;
- (IBAction)queue2Action:(id)sender;
- (IBAction)queue3Action:(id)sender;
- (IBAction)queue4Action:(id)sender;

@end

@implementation LoginViewController

- (NSMutableArray *)businessHallDicArr {
    
    if (_businessHallDicArr == nil) {
        NSMutableArray *businessHallDicArray = [NSMutableArray array];
        _businessHallDicArr = businessHallDicArray;
    }
    return _businessHallDicArr;
}

- (NSArray *)businessHallObjArr {
    if (_businessHallObjArr == nil) {
        _businessHallObjArr = [NSMutableArray array];
    }
    //将字典转成模型
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in self.businessHallDicArr) {
        
        BusinessHall *bhall = [BusinessHall businessHallWithDic:dic];
        
        [arr addObject:bhall];
    }
    _businessHallObjArr = arr;
    return _businessHallObjArr;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setup];
    [self setupNav];
    [self setupAnyChat];
    
    TextModel *textModel = [TextModelTool textModel];
    if (textModel.chatIp) {
        [self.role setTitle:textModel.roomId forState:UIControlStateNormal];
        self.username.text = textModel.userName;
        self.server.text = textModel.chatIp;
        self.port.text = textModel.chatPort;
    }else{
        textModel.roomId = self.role.titleLabel.text;
        textModel.userName = self.username.text;
        textModel.chatIp = self.server.text;
        textModel.chatPort = self.port.text;
    }
    
    [TextModelTool saveText:textModel];
    
    [self initAddSubViewWithQueues];
    
    if([self.role.titleLabel.text isEqualToString:@"普通用户"]){
        
        self.settingAllView.hidden = YES;
    }
    
    if([self.routePolicy.titleLabel.text isEqualToString:@"队列组"]){
        
        [self setupQueues];
    }
}

-(void)initAddSubViewWithQueues{
    
    [self.queue1 initTheSubView];
    [self.queue2 initTheSubView];
    [self.queue3 initTheSubView];
    [self.queue4 initTheSubView];
}

-(void)setupQueues{
    
    [self.queue1 setCustomUI:@"队列组1" withisChecked:YES];
    [self.queue2 setCustomUI:@"队列组2" withisChecked:YES];
    [self.queue3 setCustomUI:@"队列组3" withisChecked:YES];
    [self.queue4 setCustomUI:@"队列组4" withisChecked:YES];
    
}

-(void)setupSkills{
    
    [self.queue1 setCustomUI:@"现金" withisChecked:YES];
    [self.queue2 setCustomUI:@"支票" withisChecked:YES];
    [self.queue3 setCustomUI:@"存款" withisChecked:YES];
    [self.queue4 setCustomUI:@"贷款" withisChecked:YES];
    
}

- (IBAction)setAction:(id)sender {
}

- (IBAction)loginAction:(id)sender {
    
    if (self.server.text.length == 0 ) self.server.text = kAnyChatIP;
    if (self.port.text.length == 0 ) self.port.text = kAnyChatPort;
    if (self.username.text.length == 0) self.username.text = kAnyChatUserName;
    
    //连接服务器，准备回调连接服务器方法 OnAnyChatConnect
    [MBProgressHUD showMessage:@"正在连接中，请稍等..."];
    /*
     * AnyChat可以连接自主部署的服务器、也可以连接AnyChat视频云平台；
     * 连接自主部署服务器的地址为自设的服务器IP地址或域名、端口；
     * 连接AnyChat视频云平台的服务器地址为：cloud.anychat.cn；端口为：8906
     */
    
    [AnyChatPlatform Connect:self.server.text : [self.port.text intValue]];
    
    /*
     * AnyChat支持多种用户身份验证方式，包括更安全的签名登录，详情请参考：http://bbs.anychat.cn/forum.php?mod=viewthread&tid=2211&highlight=%C7%A9%C3%FB
     */
    [AnyChatPlatform Login:self.username.text :nil];
}

- (IBAction)roleAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"普通用户",@"坐席", nil];
    
    [actionSheet showInView:self.view];
    self.roleActionSheet = actionSheet;
}

- (IBAction)priorityAction:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"1",@"2",@"3",@"4",@"5", nil];
    
    [actionSheet showInView:self.view];
    self.priorityActionSheet = actionSheet;
}

- (IBAction)userInfoSettingAction:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"客户端设置",@"服务器设置", nil];
    
    [actionSheet showInView:self.view];
    self.userInfoSettingActionSheet = actionSheet;
}

- (IBAction)routePolicyAction:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"队列组",@"技能组", nil];
    
    [actionSheet showInView:self.view];
    self.routePolicyActionSheet = actionSheet;
}

- (IBAction)autoRouteAction:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"开启",@"关闭", nil];
    
    [actionSheet showInView:self.view];
    self.autoRouteActionSheet = actionSheet;
}

- (IBAction)queue1Action:(id)sender {
    
    CustomButton *btn = (CustomButton *)sender;
    
    if (btn.isChecked==YES) {
        
        if([self.routePolicy.titleLabel.text isEqualToString:@"队列组"]){
            
            [btn setCustomUI:@"队列组1" withisChecked:NO];
        }if([self.routePolicy.titleLabel.text isEqualToString:@"技能组"]){
            
            [btn setCustomUI:@"现金" withisChecked:NO];
        }
    }
    else
    {
        if([self.routePolicy.titleLabel.text isEqualToString:@"队列组"]){
            
            [btn setCustomUI:@"队列组1" withisChecked:YES];
        }if([self.routePolicy.titleLabel.text isEqualToString:@"技能组"]){
            
            [btn setCustomUI:@"现金" withisChecked:YES];
        }
    }
}

- (IBAction)queue2Action:(id)sender {
    
    CustomButton *btn = (CustomButton *)sender;
    
    if (btn.isChecked==YES) {
        
        if([self.routePolicy.titleLabel.text isEqualToString:@"队列组"]){
            
            [btn setCustomUI:@"队列组2" withisChecked:NO];
        }if([self.routePolicy.titleLabel.text isEqualToString:@"技能组"]){
            
            [btn setCustomUI:@"支票" withisChecked:NO];
        }
    }
    else
    {
        if([self.routePolicy.titleLabel.text isEqualToString:@"队列组"]){
            
            [btn setCustomUI:@"队列组2" withisChecked:YES];
        }if([self.routePolicy.titleLabel.text isEqualToString:@"技能组"]){
            
            [btn setCustomUI:@"支票" withisChecked:YES];
        }
    }
}

- (IBAction)queue3Action:(id)sender {
    CustomButton *btn = (CustomButton *)sender;
    
    if (btn.isChecked==YES) {
        
        if([self.routePolicy.titleLabel.text isEqualToString:@"队列组"]){
            
            [btn setCustomUI:@"队列组3" withisChecked:NO];
        }if([self.routePolicy.titleLabel.text isEqualToString:@"技能组"]){
            
            [btn setCustomUI:@"存款" withisChecked:NO];
        }
    }
    else
    {
        if([self.routePolicy.titleLabel.text isEqualToString:@"队列组"]){
            
            [btn setCustomUI:@"队列组3" withisChecked:YES];
        }if([self.routePolicy.titleLabel.text isEqualToString:@"技能组"]){
            
            [btn setCustomUI:@"存款" withisChecked:YES];
        }
    }
    
}

- (IBAction)queue4Action:(id)sender {
    CustomButton *btn = (CustomButton *)sender;
    
    if (btn.isChecked==YES) {
        
        if([self.routePolicy.titleLabel.text isEqualToString:@"队列组"]){
            
            [btn setCustomUI:@"队列组4" withisChecked:NO];
        }if([self.routePolicy.titleLabel.text isEqualToString:@"技能组"]){
            
            [btn setCustomUI:@"贷款" withisChecked:NO];
        }
    }
    else
    {
        if([self.routePolicy.titleLabel.text isEqualToString:@"队列组"]){
            
            [btn setCustomUI:@"队列组4" withisChecked:YES];
        }if([self.routePolicy.titleLabel.text isEqualToString:@"技能组"]){
            
            [btn setCustomUI:@"贷款" withisChecked:YES];
        }
    }
}

#pragma mark -UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet == self.roleActionSheet){
        
        if(buttonIndex == 0){
            
            [self.role setTitle:@"普通用户" forState:UIControlStateNormal];
            
            self.settingAllView.hidden = YES;
            
        }else if (buttonIndex == 1){
            
            [self.role setTitle:@"坐席" forState:UIControlStateNormal];
            
            self.settingAllView.hidden = NO;
        }
        
    }else if(actionSheet == self.priorityActionSheet){
        
        if(buttonIndex == 0){
            
            [self.priority setTitle:@"1" forState:UIControlStateNormal];
            
        }else if (buttonIndex == 1){
            
            [self.priority setTitle:@"2" forState:UIControlStateNormal];
        }else if (buttonIndex == 2){
            
            [self.priority setTitle:@"3" forState:UIControlStateNormal];
        }else if (buttonIndex == 3){
            
            [self.priority setTitle:@"4" forState:UIControlStateNormal];
        }else if (buttonIndex == 4){
            
            [self.priority setTitle:@"5" forState:UIControlStateNormal];
        }
        
    }else if(actionSheet == self.userInfoSettingActionSheet){
        
        if(buttonIndex == 0){
            
            [self.userInfoSetting setTitle:@"客户端设置" forState:UIControlStateNormal];
            
            self.routeSettingView.hidden = NO;
            
        }else if (buttonIndex == 1){
            
            [self.userInfoSetting setTitle:@"服务器设置" forState:UIControlStateNormal];
            
            self.routeSettingView.hidden = YES;
        }
        
    }else if(actionSheet == self.routePolicyActionSheet){
        
        if(buttonIndex == 0){
            
            [self.routePolicy setTitle:@"队列组" forState:UIControlStateNormal];
            
            [self setupQueues];
            
        }else if (buttonIndex == 1){
            
            [self.routePolicy setTitle:@"技能组" forState:UIControlStateNormal];
            
            [self setupSkills];
        }
        
    }else if(actionSheet == self.autoRouteActionSheet){
        
        if(buttonIndex == 0){
            
            [self.autoRoute setTitle:@"开启" forState:UIControlStateNormal];
            
        }else if (buttonIndex == 1){
            
            [self.autoRoute setTitle:@"关闭" forState:UIControlStateNormal];
        }
    }
}

- (void)setup {
    self.server.delegate = self;
    self.port.delegate = self;
    self.username.delegate = self;
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"AnyChatUserName"];
    NSString *server = [[NSUserDefaults standardUserDefaults] valueForKey:@"AnyChatServer"];
    NSString *port = [[NSUserDefaults standardUserDefaults] valueForKey:@"AnyChatPort"];
    self.server.text = server ? server : kAnyChatIP;
    self.port.text = port ? port : kAnyChatPort;
    self.username.text = username ? username : kAnyChatUserName;
    
    //设置底部Label文本SDK的版本信息
    //self.version.text = [AnyChatPlatform GetSDKVersion];
    
    //空白区取消键盘（添加手势响应）
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
}
- (void)setupNav {
    //set NavigationBar 背景颜色&title 颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:16/255.0 green:45/255.0 blue:59/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
- (void)setupAnyChat {
    // 1.初始化系统 功能：加载资源,应用程序中只需要执行一次,其他的功能接口都必须在初始化之 后才能正常使用
    [AnyChatPlatform InitSDK:0];
    
    // 2.设置AnyChat的通知监听
    // 功能:运用通知中心机制,实现监听“连接服务器、用户登录、进入房间、与服务器网络连接”等事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AnyChatNotifyHandler:) name:@"ANYCHATNOTIFY" object:nil];
    
    //3.初始化sdk的核心类对象 AnyChatPlatform
    self.anyChat = [AnyChatPlatform getInstance];
    
    //4.设置通知代理
    self.anyChat.notifyMsgDelegate = self;
    self.anyChat.objectDelegate = self;
}


#pragma mark - AnyChat Delegate
// 连接服务器消息
- (void) OnAnyChatConnect:(BOOL) bSuccess {
    if (bSuccess) {
        
    }else {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"连接服务器失败"];
    }
}

// 用户登陆消息
- (void) OnAnyChatLogin:(int) dwUserId : (int) dwErrorCode {
    if (dwErrorCode == 0) {
        self.businessHallDicArr = nil;
        self.selfUserId = dwUserId;
        // 初始化本地对象信息
        if ([self.role.titleLabel.text isEqualToString:@"普通用户"]) {
            [self InitClientObjectInfo:dwUserId :0];
        }else if([self.role.titleLabel.text isEqualToString:@"坐席"]) {
            
            //自动路由开启
            if ([self.userInfoSetting.titleLabel.text isEqualToString:@"客户端设置"]&&[self.autoRoute.titleLabel.text isEqualToString:@"开启"]) {
                [self InitClientObjectInfo:dwUserId :ANYCHAT_OBJECT_FLAGS_AUTOMODE+ANYCHAT_OBJECT_FLAGS_AGENT];
                
            }
            else
            {
                [self InitClientObjectInfo:dwUserId :ANYCHAT_OBJECT_FLAGS_AGENT];
            }
        }
        [self storeLoginInfo];
    }else {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"登录失败"];
    }
}

// 用户进入房间消息
- (void) OnAnyChatEnterRoom:(int) dwRoomId : (int) dwErrorCode {
    NSLog(@"用户进入房间");
    
    if (dwErrorCode == 0) {
        VideoViewController *videoVC = [[VideoViewController alloc] init];
        if ([self.role.titleLabel.text isEqualToString:@"普通用户"]) {
            videoVC.remoteUserId = self.remoteUserId;
        }else if([self.role.titleLabel.text isEqualToString:@"坐席"]) {
            videoVC.remoteUserId = self.customerId;
        }
        [self.navigationController pushViewController:videoVC animated:YES];
        _videoViewController = videoVC;
    }
}

// 房间在线用户消息
- (void) OnAnyChatOnlineUser:(int) dwUserNum : (int) dwRoomId {
    [self.videoViewController openRemoteView];
}
// 用户进入房间消息
- (void) OnAnyChatUserEnterRoom:(int) dwUserId {
    if (dwUserId == self.videoViewController.remoteUserId) {
        [self.videoViewController openRemoteView];
    }
}
// 用户退出房间消息
- (void) OnAnyChatUserLeaveRoom:(int) dwUserId {}
// 网络断开消息
- (void) OnAnyChatLinkClose:(int) dwErrorCode {
    NSLog(@"网络断开");
    // 注销系统
    [AnyChatPlatform Logout];
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"网络断线，请稍后再试"];
    self.businessHallDicArr = nil;
    self.selfUserId = -1;
    self.customerId = 0;
    self.remoteUserId = 0;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - AnyChatObjectEventDelegate
- (void) OnAnyChatObjectEventCallBack: (int) dwObjectType : (int) dwObjectId : (int) dwEventType : (int) dwParam1 : (int) dwParam2 : (int) dwParam3 : (int) dwParam4 : (NSString*) lpStrParam {
    switch (dwEventType) {
        case ANYCHAT_OBJECT_EVENT_UPDATE:// 1.对象数据更新
            [self AnyChatObjectUpdate:dwObjectType :dwObjectId];
            break;
        case ANYCHAT_OBJECT_EVENT_SYNCDATAFINISH:// 2.对象数据同步结束
            [self AnyChatObjectSynDataFinish:dwObjectType];
            break;
            
        case ANYCHAT_AREA_EVENT_USERENTER:// 3.用户进入服务区域
            [self AnyChatUserEnterArea:dwObjectType :dwObjectId :dwParam1 :dwParam2 :dwParam3 :dwParam4];
            break;
        case ANYCHAT_AREA_EVENT_ENTERRESULT:// 4.进入服务区域结果
            [self AnyChatEnterAreaResult:dwObjectType :dwObjectId :dwParam1];
            break;
        case ANYCHAT_AREA_EVENT_USERLEAVE:// 5.用户离开服务区域
            [self AnyChatUserLeaveArea:dwObjectType :dwObjectId :dwParam1 :dwParam2];
            break;
        case ANYCHAT_AREA_EVENT_LEAVERESULT:// 6.离开服务区域结果
            [self AnyChatLeaveAreaResult:dwObjectType :dwObjectId :dwParam1];
            break;
        case ANYCHAT_AREA_EVENT_STATUSCHANGE:// 7.服务区域状态变化
            [self AnyChatAreaStatusChanged:dwObjectType :dwObjectId];
            break;
            
        case ANYCHAT_QUEUE_EVENT_USERENTER:// 8.进入队列
            [self AnyChatUserEnterQueue:dwObjectType :dwObjectId :dwParam1];
            break;
        case ANYCHAT_QUEUE_EVENT_ENTERRESULT:// 9.用户进入队列结果
            [self AnyChatEnterQueueResult:dwObjectType :dwObjectId :dwParam1];
            break;
        case ANYCHAT_QUEUE_EVENT_USERLEAVE:// 10.用户离开队列
            [self AnyChatUserLeaveQueue:dwObjectType :dwObjectId :dwParam1];
            break;
        case ANYCHAT_QUEUE_EVENT_LEAVERESULT:// 11.用户离开队列结果
            [self AnyChatLeaveQueueResult:dwObjectType :dwObjectId :dwParam1];
            break;
        case ANYCHAT_QUEUE_EVENT_STATUSCHANGE:// 12.队列状态变化
            [self AnyChatQueueStatusChanged:dwObjectType :dwObjectId];
            break;
            
        case ANYCHAT_AGENT_EVENT_STATUSCHANGE:// 13.坐席状态变化
            [self AnyChatAgentStatusChanged:dwObjectType :dwObjectId];
            break;
        case ANYCHAT_AGENT_EVENT_SERVICENOTIFY:// 14.坐席服务通知（哪个用户到哪个客服办理业务）
            [self AnyChatAgentServiceNotify:dwParam1 :dwParam2];
            break;
        case ANYCHAT_AGENT_EVENT_WAITINGUSER:// 15.暂时没有客户，请等待
            [self AnyChatAgentWaitingUser:dwObjectType];
            break;
            
        default:
            break;
    }
}

// 1.对象数据更新(进和出都会触发)
-(void) AnyChatObjectUpdate:(int)dwObjectType :(int)dwObjectId {
    NSLog(@"对象数据更新事件");
    if(dwObjectType == ANYCHAT_OBJECT_TYPE_AREA) {
        // 获取营业厅名称
        NSString *areaName = [AnyChatPlatform ObjectGetStringValue:dwObjectType :dwObjectId :ANYCHAT_OBJECT_INFO_NAME];
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:areaName,@"areaName",[NSString stringWithFormat:@"%d",dwObjectId],@"areaId", nil];
        
        [self.businessHallDicArr addObject:dic];
        
        NSLog(@"服务区域");
    }else if(dwObjectType == ANYCHAT_OBJECT_TYPE_QUEUE) {
        NSLog(@"队列");
    }
    
}

// 2.对象数据同步结束
-(void)AnyChatObjectSynDataFinish:(int)dwObjectType {
    NSLog(@"对象数据同步结束");
    if(dwObjectType == ANYCHAT_OBJECT_TYPE_AREA) { //营业厅
        [MBProgressHUD hideHUD];
        // 跳转到营业厅
        BusinessHallViewController *businessHallVC = [[BusinessHallViewController alloc] init];
        businessHallVC.businessHallObjectArr = self.businessHallObjArr;
        self.businessHallDicArr = nil;
        [self.navigationController pushViewController:businessHallVC animated:YES];
        
        NSLog(@"服务区域");
    }
}

// 3.用户进入服务区域
-(void) AnyChatUserEnterArea:(int)dwObjectType :(int)dwObjectId :(int)dwUserId :(int)dwFlags :(int)dwAttribute :(int)dwPriority {
    NSLog(@"用户进入服务区域");
}

// 4.进入服务区域结果
-(void) AnyChatEnterAreaResult:(int)dwObjectType :(int)dwObjectId :(int)dwErrorCode {
    if(dwErrorCode == 0) {
        NSLog(@"进入服务区域成功");
        [MBProgressHUD hideHUD];
        
        NSMutableArray *queuesArray= [AnyChatPlatform ObjectGetIdList:ANYCHAT_OBJECT_TYPE_QUEUE];
        
        // 界面跳转
        if ([self.role.titleLabel.text isEqualToString:@"普通用户"]) {
            BusinessListController *businessListVC = [[BusinessListController alloc] init];
            businessListVC.businessListIdArray = queuesArray;
            businessListVC.businessHallId = dwObjectId;
            [self.navigationController pushViewController:businessListVC animated:YES];
        }else if([self.role.titleLabel.text isEqualToString:@"坐席"]) {
            ServerQueueViewController *serverQVC = [[ServerQueueViewController alloc] init];
            serverQVC.businessListIdArray = queuesArray;
            serverQVC.businessHallId = dwObjectId;
            serverQVC.selfUserId = self.selfUserId;
            
            //坐席开启了路由模式
            if ([self.role.titleLabel.text isEqualToString:@"坐席"]  && [self.autoRoute.titleLabel.text isEqualToString:@"开启"])
            {
                serverQVC.isCustomerServiceAutoMode = YES;
            }
            [self.navigationController pushViewController:serverQVC animated:YES];
        }
        
    }else {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"进入服务区域失败"];
    }
}

// 5.用户离开服务区域
-(void) AnyChatUserLeaveArea:(int)dwObjectType :(int)dwObjectId :(int)dwUserId :(int)dwErrorCode {
    NSLog(@"用户离开服务区域");
}

// 6.离开服务区域结果
-(void) AnyChatLeaveAreaResult:(int)dwObjectType :(int)dwObjectId :(int)dwErrorCode {
    
    //移除营业厅中的字典
    if (dwErrorCode == 0) {
        NSLog(@"离开服务区域成功");
        for (NSDictionary *dic in self.businessHallDicArr) {
            NSString *areaId = [dic objectForKey:@"areaId"];
            if ([areaId intValue] == dwObjectId) {
                [self.businessHallDicArr removeObject:dic];
            }
        }
    }
}

// 7.服务区域状态变化
- (void) AnyChatAreaStatusChanged:(int)dwObjectType :(int)dwObjectId {
    NSLog(@"服务区域状态变化");
}

// 8.用户进入队列
-(void) AnyChatUserEnterQueue:(int)dwObjectType :(int)dwObjectId :(int)dwUserId {
    NSLog(@"用户进入队列");
    int controllersCount = (int)self.navigationController.viewControllers.count;
    if(controllersCount == 4){
        [self updateQueueUserCountLabel:dwObjectId];
    }
}

// 9.用户进入队列结果
-(void) AnyChatEnterQueueResult:(int)dwObjectType :(int)dwObjectId :(int)dwErrorCode {
    if(dwErrorCode == 0) {
        // 进入队列成功
        NSLog(@"用户进入队列成功");
        [MBProgressHUD hideHUD];
        QueueViewController *queueVC = [[QueueViewController alloc] init];
        queueVC.businessId = dwObjectId;
        self.waitingBusinessId = dwObjectId;
        [self.navigationController pushViewController:queueVC animated:YES];
    }else {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"用户进入队列失败"];
    }
}

// 10.用户离开队列
-(void) AnyChatUserLeaveQueue:(int)dwObjectType :(int)dwObjectId :(int)dwUserId {
    NSLog(@"用户离开队列");
    int controllersCount = (int)self.navigationController.viewControllers.count;
    if(controllersCount == 4){
        [self updateQueueUserCountLabel:dwObjectId];
    }
}

// 11.用户离开队列结果
-(void) AnyChatLeaveQueueResult :(int)dwObjectType :(int)dwObjectId :(int)dwErrorCode {
    if (dwErrorCode == 0) {
        NSLog(@"用户离开队列成功");
    }
}

// 12.队列状态变化
-(void) AnyChatQueueStatusChanged:(int)dwObjectType :(int)dwObjectId {
    NSLog(@"队列状态变化");
    
    int controllersCount = (int)self.navigationController.viewControllers.count;
    if(controllersCount == 3 || controllersCount == 4){
        if ([self.navigationController.viewControllers[2] isKindOfClass:[BusinessListController class]]) {
            BusinessListController *businessListVC = self.navigationController.viewControllers[2];
            [businessListVC.tableView reloadData];
        }
        if ([self.navigationController.viewControllers[2] isKindOfClass:[ServerQueueViewController class]]) {
            ServerQueueViewController *serverQVC = self.navigationController.viewControllers[2];
            [serverQVC.tableView reloadData];
        }
        
    }
    if (controllersCount == 4) {
        if ([self.navigationController.viewControllers[3] isKindOfClass:[QueueViewController class]]) {
            if (self.waitingBusinessId == dwObjectId) {
                [self updateQueueUserCountLabel:dwObjectId];
            }
        }
    }
}

// 13.坐席状态变化
-(void) AnyChatAgentStatusChanged:(int)dwObjectType :(int)dwObjectId {
    NSLog(@"坐席状态变化");
}

// 14.坐席服务通知(有人排队)
-(void) AnyChatAgentServiceNotify:(int)dwAgentId :(int)clientId {
    NSLog(@"坐席服务通知---AnyChatAgentServiceNotify");
    //关闭了自动路由
    if ([self.role.titleLabel.text isEqualToString:@"坐席"] && self.selfUserId == dwAgentId && [self.autoRoute.titleLabel.text isEqualToString:@"关闭"]) {
        self.customerId = clientId;
        // 呼叫用户
        [AnyChatPlatform VideoCallControl:BRAC_VIDEOCALL_EVENT_REQUEST :clientId :0 :0 :0 :nil];
        ServerQueueViewController *serverQVC = [self.navigationController.viewControllers lastObject];
        serverQVC.waitingAlertView = [[UIAlertView alloc] initWithTitle:@"呼叫请求中，等待客户响应..." message:nil delegate:serverQVC cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [serverQVC.waitingAlertView show];
    }
    //开启了自动路由
    else if ([self.role.titleLabel.text isEqualToString:@"坐席"] && self.selfUserId == dwAgentId && [self.autoRoute.titleLabel.text isEqualToString:@"开启"])
    {
        self.customerId = clientId;
        NSDictionary *dict = @{@"commandType":@"videoCall",@"targetUserId":@(dwAgentId),@"isAutoMode":@(1)};
        NSString* string =  [self DataTOjsonString:dict];
        [AnyChatPlatform TransBuffer:clientId :[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

// 15.坐席等待用户(没人排队)
-(void) AnyChatAgentWaitingUser:(int)dwObjectType {
    NSLog(@"坐席等待用户");
    
    if([self.autoRoute.titleLabel.text isEqualToString:@"开启"]){
        
        [MBProgressHUD showSuccess:@"正在服务"];
        
    }
    else if([self.autoRoute.titleLabel.text isEqualToString:@"关闭"]){
        
        [MBProgressHUD showError:@"暂时还没有顾客排队，请稍后再试"];
    }
    
    
}

#pragma mark - UITextFieldDelegate
//当用户按下return键或者按回车键，keyboard消失
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    CGRect frame = textField.frame;
    NSLog(@"==%@",NSStringFromCGRect(frame));
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}


//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(void)storeLoginInfo{
    [[NSUserDefaults standardUserDefaults] setValue:self.username.text forKey:@"AnyChatUserName"];
    [[NSUserDefaults standardUserDefaults] setValue:self.server.text forKey:@"AnyChatSerVer"];
    [[NSUserDefaults standardUserDefaults] setValue:self.port.text forKey:@"AnyChatPort"];
    [[NSUserDefaults standardUserDefaults] setValue:self.AppId.text forKey:@"AnyChatAppId"];
}
#pragma mark - NSNotification Method
//消息观察者方法
- (void)AnyChatNotifyHandler:(NSNotification*)notify
{
    NSDictionary* dict = notify.userInfo;
    [self.anyChat OnRecvAnyChatNotify:dict];
}

-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


#pragma mark - Custom Method
// 初始化本地对象信息
- (void)InitClientObjectInfo:(int)mSelfUserId :(int)dwAgentFlags {
    // 业务对象身份初始化
    [AnyChatPlatform SetSDKOptionInt:BRAC_SO_OBJECT_INITFLAGS : dwAgentFlags]; // 0 普通用户 2 坐席
    if(dwAgentFlags==0)
    {
        NSLog(@"普通用户");
        // 客户端用户对象优先级
        [AnyChatPlatform ObjectSetIntValue:ANYCHAT_OBJECT_TYPE_CLIENTUSER :mSelfUserId :ANYCHAT_OBJECT_INFO_PRIORITY :10];
        [AnyChatPlatform ObjectSetIntValue:ANYCHAT_OBJECT_TYPE_CLIENTUSER :mSelfUserId :ANYCHAT_OBJECT_INFO_ATTRIBUTE :-1];
        
        [AnyChatPlatform ObjectControl: ANYCHAT_OBJECT_TYPE_AREA :ANYCHAT_INVALID_OBJECT_ID :ANYCHAT_OBJECT_CTRL_SYNCDATA :mSelfUserId :0 :0 :0 :nil];
    }
    else if ([self.userInfoSetting.titleLabel.text isEqualToString:@"客户端设置"])
    {
        NSLog(@"客户端设置");
        NSDictionary* dict;
        
        if ([self.routePolicy.titleLabel.text isEqualToString:@"队列组"]) {
            
            NSMutableArray* array = [NSMutableArray array];
            
            if (self.queue1.isChecked) {
                [array addObject:@2001];
            }
            
            if (self.queue2.isChecked) {
                [array addObject:@2002];
            }
            
            if (self.queue3.isChecked) {
                [array addObject:@2003];
            }
            
            if (self.queue4.isChecked) {
                [array addObject:@2004];
            }
            
            
            dict=@{@"flags":[NSString stringWithFormat:@"%d",dwAgentFlags],@"priority":@"10",@"queuegroups":array};
            
            NSString* string =  [self DataTOjsonString:dict];
            
            [AnyChatPlatform ObjectSetStringValue:ANYCHAT_OBJECT_TYPE_CLIENTUSER :mSelfUserId :ANYCHAT_OBJECT_INFO_STRINGTAG :string];
            
            
        }
        else
        {
            NSMutableArray* array = [NSMutableArray array];
            
            if (self.queue1.isChecked) {
                [array addObject:@1001];
            }
            
            if (self.queue2.isChecked) {
                [array addObject:@1002];
            }
            
            if (self.queue3.isChecked) {
                [array addObject:@1003];
            }
            
            if (self.queue4.isChecked) {
                [array addObject:@1004];
            }
            
            
            dict=@{@"flags":[NSString stringWithFormat:@"%d",dwAgentFlags],@"priority":@"10",@"skillgroups":array};
            
            NSString* string = [self DataTOjsonString:dict];
            
            [AnyChatPlatform ObjectSetStringValue:ANYCHAT_OBJECT_TYPE_CLIENTUSER :mSelfUserId :ANYCHAT_OBJECT_INFO_STRINGTAG :string];
            
        }
        
        [AnyChatPlatform ObjectControl: ANYCHAT_OBJECT_TYPE_AREA :ANYCHAT_INVALID_OBJECT_ID :ANYCHAT_OBJECT_CTRL_SYNCDATA :mSelfUserId :0 :0 :0 :nil];
        
    }
    else if([self.userInfoSetting.titleLabel.text isEqualToString:@"服务器设置"])
    {
        NSLog(@"服务器设置");
        // 客户端用户对象优先级
        [AnyChatPlatform ObjectSetIntValue:ANYCHAT_OBJECT_TYPE_CLIENTUSER :mSelfUserId :ANYCHAT_OBJECT_INFO_PRIORITY :10];
        [AnyChatPlatform ObjectSetIntValue:ANYCHAT_OBJECT_TYPE_CLIENTUSER :mSelfUserId :ANYCHAT_OBJECT_INFO_ATTRIBUTE :-1];
    }
}


// 空白区取消键盘的手势响应
-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [self.view endEditing:YES];
}

// 更新排队人数Label
- (void)updateQueueUserCountLabel:(int)queueId {
    int navNum = (int)self.navigationController.viewControllers.count;
    if (navNum==4) {
        QueueViewController *queueVC = [self.navigationController.viewControllers objectAtIndex:3];
        int queueUserNum = [AnyChatPlatform ObjectGetIntValue:ANYCHAT_OBJECT_TYPE_QUEUE :queueId :ANYCHAT_QUEUE_INFO_QUEUELENGTH];
        queueVC.queueUserCountLabel.text = [NSString stringWithFormat:@"当前排队人数共:%d人",queueUserNum];
        
        int queuUserSite = [AnyChatPlatform ObjectGetIntValue:ANYCHAT_OBJECT_TYPE_QUEUE :queueId :ANYCHAT_QUEUE_INFO_BEFOREUSERNUM] + 1;
        //        if (beforeNum < 0) beforeNum = 0;
        queueVC.queuUserSiteLabel.text = [NSString stringWithFormat:@"你现在排在第%d位",queuUserSite];
        
    }
}


@end
