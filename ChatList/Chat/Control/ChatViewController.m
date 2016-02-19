//
//  ChatViewControl.m
//  IMReasonable
//
//  Created by apple on 15/6/12.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "PJImageDetailController.h"
#import "SpreadMailModel.h"
#import "MailTableViewCell.h"
#import "MessageModel.h"
#import "ChatViewController.h"
#import "WeChatKeyBoard.h"
#import "WeChatTableViewCell.h"
#import "MessageModel.h"
#import "WeChat.h"
#import "TitleView.h"
#import "GroupSetViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MainViewController.h"
#import "MJRefresh.h"
#import "ASIFormDataRequest.h"
#import "SDWebImageManager.h"
#import <MessageUI/MessageUI.h>
#import "UUImageAvatarBrowser.h"
#import "SelectUserViewController.h"



#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "UIImageView+WebCache.h"

#define ALLUSERFILE @"AllUserFile"
#define SMALLIMAGE @"SmallImage"
#define IMAGE @"Image"
#define LINEKEYBOARDHEIGHT 76//键盘的高度

@interface ChatViewController()<PJsendImageDelegate>

//判断键盘是否已经显示
@property(nonatomic,assign)BOOL isKeyBoradVisible;
//当前屏幕的方向
@property(nonatomic,assign)int currentOrientation;
//在开启动画的前提下如果有新消息到来不需要执行动画效果，只当滑动聊天记录时才执行动画
@property(nonatomic,assign)BOOL suspendAnimation;
//配合suspendAnimation使用，当前可见的cell数量
@property(nonatomic,assign)int currentVisibleCellCount;

@end

@implementation ChatViewController {
    
    //页面需要的控件
    WeChatKeyBoard* key;
    UITableView* tableview;

    NSMutableArray* messageList; //用于保存消息数组
    long pagenumber; //用于保存聊天的第几页
    NSString* myjidstr; //保存自己的账号名
    BOOL isNeedexit; //选择图片的时候为防止内存泄露

    MessageModel* oneimgmessage; //保留一条图片消息

    BOOL isRoom;

    NSInteger rommusercount;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    myjidstr = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
    pagenumber = 1;

    //注册横竖屏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRotateAction:) name:UIDeviceOrientationDidChangeNotification object:nil];
    //    //初始化界面需要的控件
    [self initViewControl];
    //是否是通过转发信息跳转进来的
    if (self.isforward) {
        if(self.forwardMessageModel.type==MESSAGE_TYPE_TEXT){
            
            [self sendMessage:self.forwardmssage type:@"chat" voicelenth:@"0" voicepath:@""];

        }else{
            
            UIImage *image;
            NSString *imageURL=self.forwardMessageModel.content;
            NSFileManager *fileManager=[NSFileManager defaultManager];
            //转发自己的图片
            if([fileManager fileExistsAtPath:FULLPATHTOFILE(imageURL) isDirectory:false]){
                
                //从本地加载图片
                image=[UIImage imageWithContentsOfFile:FULLPATHTOFILE(imageURL)];
                [self didSendImage:image AndIsOriginal:true];
            }else if([imageURL rangeOfString:ALLUSERFILE].length>0){
                
                //转发别人的图片
                UIImageView *imageView=[[UIImageView alloc] initWithImage:image];
                [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMReasonableAPPImagePath,[imageURL stringByReplacingOccurrencesOfString:SMALLIMAGE withString:IMAGE]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if(image!=nil){
                        
                        [self didSendImage:image AndIsOriginal:true];
                    }
                }];
            }
        }
    }

    [self initData:YES];
    [self setDelegate]; //获取页面代理
    [self GetRoomList]; // 当是房间账号的时候，就下载房间成员
    [self setMessageReaded]; //设置消息已读
    [self initNav];
    [self initNavMyPhoto];

    //从数据库获取上一次在输入框中输入的文字但未发送
    [key setText:self.from.tempText];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadtableview)
                                                 name:@"NETCHANGE"
                                               object:nil];
}

- (void)reloadtableview
{
    [self initNav];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setDelegate];
//    [tableview reloadData];
}



//设置聊天页面需要的代理事件
- (void)setDelegate
{
    [XMPPDao sharedXMPPManager].authloginDelegate = self;
    [XMPPDao sharedXMPPManager].chatHelerpDelegate = self;
    [XMPPDao sharedXMPPManager].friendreceivemsgDelegate = self;
    key.delegate = self;
    tableview.delegate = self;
    tableview.dataSource = self;
}
// 获取聊天消息
- (void)initData:(BOOL)isgo
{

    if (!isgo) {
        pagenumber += 1;
    }

    NSString* fromjidstr = self.from.jidstr;
    NSString* tojidstr = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
    if (!fromjidstr) {
        fromjidstr = self.from.messagebody.from;
        if ([fromjidstr isEqualToString:tojidstr]) {
            fromjidstr = self.from.messagebody.to;
        }
    }

    NSString* rowcount = [NSString stringWithFormat:@"%ld", pagenumber * 15];
    messageList = nil;
    if ([self.from.isRoom isEqualToString:@"0"]) {
        isRoom = false;
        //获取聊天记录（单聊）
        messageList = [IMReasonableDao getMessageByFormAndToJidstr2:fromjidstr Tojidstr:tojidstr withRowCount:rowcount];
    }
    else {
        //获取群聊聊天记录
        messageList = [IMReasonableDao getChatRoomMessage2:fromjidstr rowCount:rowcount];
        rommusercount = [IMReasonableDao getRoomUserCount:fromjidstr];
        isRoom = true;
        //缓存房间的头像

        NSString* ImageURL1 = [self.from.faceurl stringByReplacingOccurrencesOfString:@"Small" withString:@""];
        NSString* path = [Tool Append:IMReasonableAPPImagePath witnstring:ImageURL1]; //self.from.faceurl];
        NSURL* url = [NSURL URLWithString:path];
        SDWebImageManager* manage = [SDWebImageManager sharedManager];
        if (![manage cachedImageExistsForURL:url]) {
            [self GetRoomUrl:self.from.jidstr];
        }
    }

    if (isgo) {
        [self tableviewReload];
    }
    else {

        dispatch_async(dispatch_get_main_queue(), ^{
            [tableview reloadData];
        });
    }

    [tableview.header endRefreshing];
}

//初始化界面控件
- (void)initViewControl
{
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-LINEKEYBOARDHEIGHT)];
    tableview.dataSource = self;
    tableview.delegate = self;

    tableview.backgroundColor = [UIColor whiteColor];
    tableview.separatorStyle = UITableViewCellSelectionStyleNone;
    tableview.tableFooterView = [[UIView alloc] init];
    //    NSString* chatwallpaper = [NSString stringWithFormat:@"wp_%@.jpg", [[NSUserDefaults standardUserDefaults] stringForKey:CHATWALLPAPER]];
    //    tableview.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:chatwallpaper]];

    tableview.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableview];

    
    __block __weak typeof(self) tmpSelf = self;
    [tableview addLegendHeaderWithRefreshingBlock:^() {
        [tmpSelf initData:NO];
    }];

    // 设置文字
    [tableview.header setTitle:@"Pull down to refresh" forState:MJRefreshHeaderStateIdle];
    [tableview.header setTitle:@"Release to refresh" forState:MJRefreshHeaderStatePulling];
    [tableview.header setTitle:@"Loading ..." forState:MJRefreshHeaderStateRefreshing];
    tableview.header.updatedTimeHidden = YES;

    // 设置字体
    tableview.header.font = [UIFont systemFontOfSize:15];

    // 设置颜色
    tableview.header.textColor = [UIColor grayColor];

    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = (id)self;
    [tableview addGestureRecognizer:gesture];

    if ([self.from.isRoom isEqualToString:@"1"]) {
        if ([self.from.isimrea isEqualToString:@"1"]) {
            [self initNotinGroupMsg];
        }
        else {
            [self initKeyboard];
        }
    }
    else {
        [self initKeyboard];
    }
}

//初始化化键盘
- (void)initKeyboard
{
    key = [[WeChatKeyBoard alloc] init:self];
    key.backgroundColor = [UIColor whiteColor];
    key.delegate = self;
    [self.view addSubview:key];
}

//手势操作回收键盘
- (void)hidenKeyboard
{

    [key hideKeyboard];

    [self goLastMessage];
}

//获取房间的成员
- (void)GetRoomList
{

    if ([self.from.isRoom isEqualToString:@"1"] && [self.from.isimrea isEqualToString:@"0"]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            [IMReasonableDao clearRoomUser:self.from.jidstr];
            [[XMPPDao sharedXMPPManager] GetRoomUserList:self.from.jidstr];

        });
    }
}
//设置消息为已读
- (void)setMessageReaded
{
    NSString* fromjidstr = self.from.jidstr;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [IMReasonableDao setMessageRead:fromjidstr needactive:YES];

    });
}
//初始化导航栏的头像
- (void)initNavMyPhoto
{
    UIImage* tempimg;
    tempimg = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:self.from.faceurl]];

    NSString* defaultphoto = @"default";
    if ([self.from.isRoom isEqualToString:@"1"]) {
        defaultphoto = @"GroupChatRound";
        NSString* ImageURL1 = [self.from.faceurl stringByReplacingOccurrencesOfString:@"Small" withString:@""];
        NSString* path = [Tool Append:IMReasonableAPPImagePath witnstring:ImageURL1];
        SDImageCache* cache = [SDImageCache sharedImageCache];
        UIImage* cachedImage = [cache imageFromDiskCacheForKey:path];
        if (cachedImage) {
            tempimg = cachedImage;
        }
    }

    tempimg = tempimg ? tempimg : [UIImage imageNamed:defaultphoto];
    UIView* btnview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    UIImageView* userinterface = [[UIImageView alloc] initWithImage:tempimg];
    userinterface.frame = CGRectMake(0, 0, 32, 32);
    userinterface.layer.masksToBounds = YES;
    userinterface.layer.cornerRadius = 16;

    UIButton* leftbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftbtn.frame = CGRectMake(0, 0, 32, 32);
    leftbtn.backgroundColor = [UIColor clearColor];
    [leftbtn addTarget:self action:@selector(userinterface:) forControlEvents:UIControlEventTouchUpInside];

    [btnview addSubview:userinterface];
    [btnview addSubview:leftbtn];
    UIBarButtonItem* right = [[UIBarButtonItem alloc] initWithCustomView:btnview];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)userinterface:(UIButton*)btn
{

    UIImage* tempimg;
    tempimg = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:self.from.faceurl]];

    NSString* defaultphoto = @"default";
    if ([self.from.isRoom isEqualToString:@"1"]) {
        defaultphoto = @"GroupChatRound";
        NSString* ImageURL1 = [self.from.faceurl stringByReplacingOccurrencesOfString:@"Small" withString:@""];
        NSString* path = [Tool Append:IMReasonableAPPImagePath witnstring:ImageURL1];
        SDImageCache* cache = [SDImageCache sharedImageCache];
        UIImage* cachedImage = [cache imageFromDiskCacheForKey:path];
        if (cachedImage) {
            tempimg = cachedImage;
        }
    }

    tempimg = tempimg ? tempimg : [UIImage imageNamed:defaultphoto];
    UIImageView* userinterface = [[UIImageView alloc] initWithImage:tempimg];
    [UUImageAvatarBrowser showImage:userinterface data:nil];
}



// 初始化导航栏
- (void)initNav
{
    self.currentOrientation=[[UIDevice currentDevice] orientation];
    NSString* fromjidstr = self.from.localname ? self.from.localname : [[self.from.jidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
    NSString* temptitle;
    if (isRoom && rommusercount > 1) {
        temptitle = [NSString stringWithFormat:@"%@(%ld)", fromjidstr, (long)rommusercount];
    }
    else {
        temptitle = fromjidstr;
    }

    NSString* title = [NSString stringWithFormat:NSLocalizedString(@"lbtalkwith", nil), temptitle]; //lbtalkwith

    TitleView* titleview = [[TitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleview.title.text = title;
    NSString* subtitle;
    if ([XMPPDao sharedXMPPManager].isConnectInternet) { //判断是否有网络连接

        if ([self.from.isRoom isEqualToString:@"0"] && [self.from.state isEqualToString:@"available"]) { //判断是否连接到聊天服务器
            subtitle = NSLocalizedString(@"lbonline", nil);
        }
        else {

            if (![XMPPDao sharedXMPPManager].isLogin) {
                subtitle = NSLocalizedString(@"lbTconnect", nil);
            }
            else {

                if ([self.from.isRoom isEqualToString:@"0"]) {
                    switch ([Tool getDateDictiance:self.from.update]) { //显示最后上线时间
                    case 0: {

                        //subtitle=[NSString stringWithFormat:@"最后上线 今天%@",[Tool getHHMM:self.from.update]];
                        subtitle = [NSString stringWithFormat:NSLocalizedString(@"lbtodyonline", nil), [Tool getHHMM:self.from.update]];

                    } break;
                    case 1: {
                        // subtitle=[NSString stringWithFormat:@"最后上线 昨天%@",[Tool getHHMM:self.from.update]];
                        subtitle = [NSString stringWithFormat:NSLocalizedString(@"lbyesterdayonline", nil), [Tool getHHMM:self.from.update]];

                    } break;

                    default:
                        subtitle = self.from.update;
                        break;
                    }
                }
                else {

                    subtitle = self.from.nick;
                }
            }
        }
    }
    else {

        subtitle = NSLocalizedString(@"msgInternet", nil); //@"无网络连接";
    }
    titleview.subtitle.text = subtitle;
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2 - 100, 0, 200, 44)];
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(clickSegmentButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:titleview];
    [view addSubview:btn];

    self.navigationItem.titleView = view;

    if(self.isforward){
        
        
        UIButton* backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        backButton.frame = CGRectMake(0, 0, 36, 30.0f);
        backButton.titleLabel.font=[UIFont systemFontOfSize:18.0];
        [backButton setTitle:NSLocalizedString(@"lbchats", nil) forState:normal];
        [backButton addTarget:self action:@selector(goRootView:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        backButtonItem.style=UIBarButtonItemStyleBordered;
        self.navigationItem.leftBarButtonItem = backButtonItem;
    }
    if (self.isNeedCustom) {
        UIButton* releaseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        releaseButton.frame = CGRectMake(0, 0, 44, 30.0f);
        [releaseButton setTitle:NSLocalizedString(@"lbchats", nil) forState:normal];
        [releaseButton addTarget:self action:@selector(goRootView:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* releaseButtonItem = [[UIBarButtonItem alloc] initWithCustomView:releaseButton];
        self.navigationItem.leftBarButtonItem = releaseButtonItem;
    }
}
// 当不是群成员的时候操作
- (void)initNotinGroupMsg
{
    UILabel* notingroup = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 49, self.view.bounds.size.width, 49)];
    notingroup.contentMode = UIViewContentModeScaleAspectFit;
    //    "lbcvcGroupchat"="";
    notingroup.text = NSLocalizedString(@"lbcvcGroupchat", nil); //@"您已经不是该群成员，不能在该群发啊实打实大的飒飒大消息";
    notingroup.textColor = [UIColor grayColor];
    notingroup.font = [UIFont systemFontOfSize:12];
    notingroup.textAlignment = NSTextAlignmentCenter;
    notingroup.lineBreakMode = NSLineBreakByWordWrapping;
    notingroup.numberOfLines = 0;
    notingroup.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:notingroup];
}

//获取房间的头像
- (void)GetRoomUrl:(NSString*)roomjidstr
{

    NSURL* url = [NSURL URLWithString:[Tool Append:IMReasonableAPP witnstring:@"GetRoomFaceurl"]];
    NSString* Apikey = IMReasonableAPPKey;
    NSDictionary* sendsms = [[NSDictionary alloc] initWithObjectsAndKeys:Apikey, @"apikey", roomjidstr, @"roomjidstr", nil];
    NSDictionary* sendsmsD = [[NSDictionary alloc] initWithObjectsAndKeys:sendsms, @"geturl", nil];
    if ([NSJSONSerialization isValidJSONObject:sendsmsD]) {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:sendsmsD options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableData* tempJsonData = [NSMutableData dataWithData:jsonData];
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempJsonData];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(GetRoomUrlSuc:)];
        [request setDidFailSelector:@selector(GetRoomUrlFaied:)];
        [request startAsynchronous];
    }
}
- (void)GetRoomUrlSuc:(ASIHTTPRequest*)request
{
    NSData* responsedata = [request responseData];
    NSDictionary* dict = [Tool jsontodate:responsedata];
    NSDictionary* code = [dict objectForKey:@"GetRoomFaceurlResult"];
    NSString* state = [code objectForKey:@"state"];
    if ([state isEqualToString:@"1"]) {
        NSString* faceurl = [code objectForKey:@"faceurl"];
        [IMReasonableDao updateRoomFaceurl:faceurl roomjidstr:self.from.jidstr];

        NSString* ImageURL1 = [faceurl stringByReplacingOccurrencesOfString:@"Small" withString:@""];
        NSString* path = [Tool Append:IMReasonableAPPImagePath witnstring:ImageURL1]; //self.from.faceurl];
        //  NSString *path=[Tool Append:IMReasonableAPPImagePath witnstring:faceurl];
        NSURL* url = [NSURL URLWithString:path];
        SDWebImageManager* manage = [SDWebImageManager sharedManager];
        [manage downloadImageWithURL:url
                             options:SDWebImageContinueInBackground
                            progress:nil
                           completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished, NSURL* imageURL){
                           }];
    }
}
- (void)GetRoomUrlFaied:(ASIHTTPRequest*)request
{
}

#pragma mark--下拉刷新事件
- (void)RefreshViewControlEventValueChanged:(UIRefreshControl*)ref
{
    if (ref.refreshing) {
        // [timeKiller setFireDate:[NSDate distantFuture]];
        ref.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"msgRefing", nil)];
        pagenumber += 1;
        [self initData:NO];
        [self performSelector:@selector(RefTableview:) withObject:ref afterDelay:1];
    }
}

- (void)RefTableview:(UIRefreshControl*)ref
{
    [ref endRefreshing];
    ref.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"msgRef", nil)];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{

    if (key.frame.origin.y < SCREENWIHEIGHT - 49) {
        return YES;
    }
    else {
        return NO;
    }
}
#pragma mark--导航栏触发的事件
//点击进入联系人页面
- (void)clickSegmentButton:(UIButton*)btn
{

    if ([self.from.isRoom isEqualToString:@"1"]) {
        if ([self.from.isimrea isEqualToString:@"0"]) {
            GroupSetViewController* personViewController = [[GroupSetViewController alloc] init];
            UIBarButtonItem* backItem = [[UIBarButtonItem alloc] init];
            backItem.title = self.from.localname;
            self.navigationItem.backBarButtonItem = backItem;
            personViewController.from = self.from;
            [self.navigationController pushViewController:personViewController animated:NO];
        }
    }
    else {

        if (self.from.localname.length > 0) {

            NSString* locaname = self.from.localname;
            ABAddressBookRef tmpAddressBook = nil;
            //根据系统版本不同，调用不同方法获取通讯录
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
                tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error) {
                    dispatch_semaphore_signal(sema);
                });
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            }

            if (tmpAddressBook == nil) {
                return;
            };

            ABRecordRef person = NULL;

            NSArray* arrayByName = (NSArray*)CFBridgingRelease(ABAddressBookCopyPeopleWithName(tmpAddressBook, CFBridgingRetain(locaname)));
            if (arrayByName.count > 0 && arrayByName.count == 1) {
                person = CFBridgingRetain([arrayByName objectAtIndex:0]);
            }
            else {

                NSArray* tmpPeoples = (NSArray*)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(tmpAddressBook));
                for (id tmpPerson in tmpPeoples) {

                    ABMultiValueRef tmpPhones = ABRecordCopyValue(CFBridgingRetain(tmpPerson), kABPersonPhoneProperty);

                    for (NSInteger j = 0; j < ABMultiValueGetCount(tmpPhones); j++) {

                        NSString* tmpPhoneIndex = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(tmpPhones, j));

                        NSString* unknowphone = [tmpPhoneIndex substringWithRange:NSMakeRange(0, 1)];
                        tmpPhoneIndex = [Tool getPhoneNumber:tmpPhoneIndex];
                        if (![unknowphone isEqualToString:@"+"]) { //需要当前用户的国家代码
                            NSString* countrycode = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPUSERCOUNTRYCODE];
                            tmpPhoneIndex = [NSString stringWithFormat:@"%@%@", countrycode, tmpPhoneIndex];
                        }

                        if ([tmpPhoneIndex isEqualToString:self.from.phonenumber]) {
                            person = CFBridgingRetain(tmpPerson);
                            break;
                        }
                    }
                }
            }

            if (person != NULL) {
                ABPersonViewController* personViewController = [[ABPersonViewController alloc] init];
                [personViewController setDisplayedPerson:person];
                personViewController.allowsEditing = NO;
                //[self.view addSubview:personViewController.view];
                [self.navigationController pushViewController:personViewController animated:YES];
            }
        }
    }
}
//进入主界面
- (void)goRootView:(UIButton*)btn
{

    MainViewController* main = [[MainViewController alloc] init];
    [self presentViewController:main animated:YES completion:nil];
}
//表格刷新
- (void)tableviewReload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [tableview reloadData];
        [self goLastMessage];
    });
}



//滚动到最后一行消息
- (void)goLastMessage
{

//    PJLog(@"%@", NSStringFromCGRect(key.frame));

    double offset = self.view.frame.size.height - (tableview.frame.origin.y + tableview.contentSize.height + (self.view.frame.size.height - key.frame.origin.y));
    if (offset < 0) {

        [UIView animateWithDuration:0.5
                         animations:^{
                             tableview.contentOffset = CGPointMake(0, -offset);
                         }];
    }
    else {
        tableview.contentOffset = CGPointMake(0, -64);
    }
}

#pragma mark-- 表格的代理事件
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{

    return messageList.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{

    static NSString* Idetify = @"WECHATCELL";
    MessageModel* mode = [messageList objectAtIndex:[indexPath row]];
        WeChatTableViewCell* cell = [tableview dequeueReusableCellWithIdentifier:Idetify];
        if (!cell) {
            
            cell = [[WeChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Idetify];
            cell.delegate = self;
        }
        else {
            for (UIView* subView in cell.contentView.subviews) {
                [subView removeFromSuperview];
            }
        }
    
        [cell setMessagemode:mode isNeedName:isRoom];
        return cell;
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{

    CGFloat height = [WeChatTableViewCell getCellHeight:[messageList objectAtIndex:[indexPath row]] isNeedName:isRoom];
    return height;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark -键盘的代理事件

- (void)sendTextContent:(NSString*)txtvalue
{
    [self sendMessage:txtvalue type:@"chat" voicelenth:@"0" voicepath:@""];
}
- (void)sendVoiceContent:(NSString*)voicePath voicedata:(NSData*)data voicelenth:(double)voicelenth
{

    [self sendMessage:[Tool NSdatatoBSString:data] type:@"voice" voicelenth:[NSString stringWithFormat:@"%0.1f", ceil(voicelenth)] voicepath:voicePath];
}
- (void)choiceFuction:(NSUInteger)functionid
{

    if ([XMPPDao sharedXMPPManager].isConnectInternet) {
        switch (functionid) {
        case 900:
            //相册
            [self SelectImage:UIImagePickerControllerSourceTypePhotoLibrary];

            break;
        case 910:
            // 相机
            [self SelectImage:UIImagePickerControllerSourceTypeCamera];

            break;
        case 901:
            // 取消
            return;
        default:
            break;
        }
    }
    else {

        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.removeFromSuperViewOnHide = YES;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"msgInternet", nil);
        hud.minSize = CGSizeMake(132.f, 108.0f);
        [hud hide:YES afterDelay:3];
    }
}

- (void)sendMessage:(NSString*)body type:(NSString*)type voicelenth:(NSString*)lenth voicepath:(NSString*)path
{

    if ([XMPPDao sharedXMPPManager].isConnectInternet) {

        if ([XMPPDao sharedXMPPManager].isLogin) {
            NSCharacterSet* whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString* str = [[NSString alloc] initWithString:[body stringByTrimmingCharactersInSet:whiteSpace]];

            if (![str isEqualToString:@""]) {
                NSString* msgID = [Tool GetOnlyString];

                if ([type isEqualToString:@"img"]) {
                    msgID = oneimgmessage.ID;
                }

                //把消息发出去
                if ([self.from.isRoom isEqualToString:@"0"]) {
                    [[XMPPDao sharedXMPPManager] sendChatMessage:self.from.jidstr type:type body:str voicelenth:lenth msgID:msgID];
                }
                else {
                    [[XMPPDao sharedXMPPManager] sendChatRoomMessage:self.from.jidstr type:type body:str voicelenth:lenth msgID:msgID];
                }
                NSString* time = [Tool GetDate:@"yyyy-MM-dd HH:mm:ss"];

                if ([type isEqualToString:@"voice"]) {
                    str = path;
                }

                if (![type isEqualToString:@"img"]) { //是图片就不需要再次保存到数据库

                    [IMReasonableDao saveMessage2:myjidstr to:self.from.jidstr body:str type:type date:time voicelenth:lenth msgID:msgID]; //纯入本地数据库

                    //dispatch_async(dispatch_get_main_queue(), ^{
                    self.suspendAnimation=true;
                    [self initData:YES];
                    //});
                    //[self initData:YES];
                }
            }
        }
        else {

            [self showTipsMessage:NSLocalizedString(@"lbctvnotconnect", nil) withShowTime:2]; //显示提示信息
            [self setKeyboardVaule:body withType:type];
        }
    }
    else {

        [self showTipsMessage:NSLocalizedString(@"msgInternet", nil) withShowTime:2]; //显示提示信息
        [self setKeyboardVaule:body withType:type];
    }
}

- (void)SelectImage:(NSUInteger)type
{
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = (id)self;
    imagePickerController.allowsEditing = NO;

    if (type == UIImagePickerControllerSourceTypePhotoLibrary) {

        imagePickerController.sourceType = type;
        isNeedexit = true;

        [self presentViewController:imagePickerController
                           animated:YES
                         completion:^{
                         }];
    }
    else {
        isNeedexit = true;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerController.sourceType = type;

            [self presentViewController:imagePickerController
                               animated:YES
                             completion:^{
                             }];
        }
        else {
            [Tool alert:NSLocalizedString(@"msgNoCam", nil)];
        }
    }
}

//发送图片
-(void)didSendImage:(UIImage *)image AndIsOriginal:(BOOL)isOriginal{
    NSData* dataimg;
    if(isOriginal){
        
        //发送原图
        dataimg=UIImageJPEGRepresentation(image, 1);
    }else{
        
        //发送压缩图
        dataimg=UIImageJPEGRepresentation(image, 0.01);
    }
    
    //缓存到本地  针对图片这一块设计的
    NSString* filename = [Tool GetOnlyString];
    [Tool saveFileToDoc:filename fileData:dataimg];
    
    MessageModel* tempmeseage = [[MessageModel alloc] init];
    tempmeseage.ID = [Tool GetOnlyString];
    //    tempmeseage.from=[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
    //    tempmeseage.to=self.from.jidstr;
    tempmeseage.content = [filename stringByAppendingString:@".png"];
    //    tempmeseage.type=@"locimg";
    tempmeseage.time = [Tool GetDate:@"yyyy-MM-dd HH:mm:ss"];
    //    [messageList addObject:tempmeseage];//保存到当前对话列表中
    //    [self reftableviewandgoend];
    //
    //
    oneimgmessage = tempmeseage; //保存这一条图片消息的ID
    
    [IMReasonableDao saveMessage2:myjidstr to:self.from.jidstr body:tempmeseage.content type:@"img" date:tempmeseage.time voicelenth:@"0" msgID:tempmeseage.ID]; //纯入本地数据库
    [self initData:YES];
    
    NSString* datastring1 = [Tool NSdatatoBSString:dataimg]; //压缩编码发送
    NSURL* url = [NSURL URLWithString:[Tool Append:IMReasonableAPP witnstring:@"Upload"]];
    
    NSString* jidstr = MJID;
    NSString* appendfilename = [Tool GetOnlyString];
    
    NSDictionary* usert = [[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"type", jidstr, @"username", datastring1, @"base64Content", appendfilename, @"filename", nil];
    NSDictionary* user = [[NSDictionary alloc] initWithObjectsAndKeys:usert, @"file", nil];
    if ([NSJSONSerialization isValidJSONObject:user]) {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableData* tempJsonData = [NSMutableData dataWithData:jsonData];
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempJsonData];
        request.tag = [tempmeseage.ID integerValue];
        
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(sendImageSuc:)];
        [request setDidFailSelector:@selector(sendImageFaied:)];
        [request startAsynchronous];
    }
}

#pragma mark -把选择的图片发送到服务器
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    [key hideKeyboard];
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                               }];
    UIImage* image = [Tool fixOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];
    PJImageDetailController *pjimageDetailController=[[PJImageDetailController alloc] initWithImage:image AndImageDic:info];
//    UINavigationController *na=[[UINavigationController alloc] init];
//    [na addChildViewController:pjimageDetailController];
    [self.navigationController pushViewController:pjimageDetailController animated:YES];
    pjimageDetailController.pjsendImageDelegate=self;
//    [self didSendImage:image];
}



- (void)sendImageSuc:(ASIHTTPRequest*)req
{

    NSData* responsedata = [req responseData];
    NSDictionary* dict = [Tool jsontodate:responsedata];
    NSString* path = [dict objectForKey:@"UploadFileResult"];
    [self sendMessage:path type:@"img" voicelenth:@"0" voicepath:@""];
}



- (void)sendImageFaied:(ASIHTTPRequest*)req
{
    PJLog(@"请求图片出错");
    //失败了，就跟新消息发送失败
    NSString* msgID = [NSString stringWithFormat:@"%ld", (long)req.tag];
    [IMReasonableDao updatesendstate:msgID isNeedSend:@"0"];

    [self initData:YES]; //当出现失败的时候就初始化列表数据
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = NSLocalizedString(@"lbimgfaied", nil); //NSLocalizedString(@"msgInternet", nil);
    hud.minSize = CGSizeMake(132.f, 108.0f);
    [hud hide:YES afterDelay:2];
}

- (void)WeChatKeyBoardY:(CGFloat)y
{
    if(y==0){
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             tableview.contentOffset = CGPointMake(0, 0);
                         }];
    }else{
        
        [self goLastMessage];
    }
}

#pragma mark -视图快移出
- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    NSString* fromjidstr = self.from.jidstr;

    [IMReasonableDao setTempText:fromjidstr text:[key getText]]; //存储最后一条未发送的消息

    PJLog(@"防止内存泄露");
    if (!isNeedexit) {
        [IMReasonableDao setMessageRead:fromjidstr needactive:YES];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDEMESSAGECOUNT" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -ChatHelegate代理实现
- (void)receiveNewMessage:(IMMessage*)message isFwd:(BOOL)isfwd
{
    NSLog(@"message:%@",message);
    if ([message.from isEqualToString:self.from.jidstr]) {
        self.suspendAnimation=true;
        [self initData:YES];
    }
}
- (void)userStatusChange:(XMPPPresence*)presence
{
    if ([presence.from.bare isEqualToString:self.from.jidstr]) {
        self.from.state = presence.type;
        [self initNav];
    }
}
- (void)isSuccSendMessage:(IMMessage*)tempmeseage issuc:(BOOL)flag
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initData:YES];
    });
}

#pragma mark -AuthloginDelegate
- (void)isSuccLogin:(BOOL)flag
{
    [self initNav];
}
//当flag==true的时候表明注册成功，否则注册失败
- (void)isSuccReg:(BOOL)flag
{
}
//当flag==true的时候表明发送成功，否则发送失败

#pragma mark -FriendrecevemsgDelegate实现
- (void)friendreceivemsg
{

    dispatch_async(dispatch_get_main_queue(), ^{
        [self initData:YES];
    });
    //
}

#pragma mark -Cell协议
- (void)touchMessageContent:(NSString*)content withType:(TouchContentType)type
{
    if (type == TouchContentTypeURL) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:content]];
    }
}

//点击图片事件
- (void)touchPictureContent:(MessageModel*)modle tableviewcell:(UITableViewCell*)cell ImageView:(UIImageView *)imageView
{

    [key hideKeyboard];
    NSPredicate* pre = [NSPredicate predicateWithFormat:@"type==1"];

    NSArray* temp = [[NSArray alloc] initWithArray:messageList copyItems:NO];
    //获取到所有的图片
    NSArray* arrayPre = [temp filteredArrayUsingPredicate:pre];
    //被点击的图片的位置
    NSInteger index = [arrayPre indexOfObject:modle];
    [self ImageBrowser:arrayPre WithShowIndex:index ImageView:imageView];
}

//图片浏览器
- (void)ImageBrowser:(NSArray*)messageModelArray WithShowIndex:(NSInteger)index ImageView:(UIImageView *)imageView
{

    NSMutableArray* photoarray = [NSMutableArray array];
    for (MessageModel* photoModel in messageModelArray) {
        NSString* imagePath = [photoModel.content stringByReplacingOccurrencesOfString:@"Small" withString:@""];
        NSLog(@"%@",imagePath);
        NSString* imageURL = [Tool Append:IMReasonableAPPImagePath witnstring:imagePath];
        UIImage* image = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:photoModel.content]];
        NSLog(@"%@",[Tool getFilePathFromDoc:photoModel.content]);
        MJPhoto* photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageURL];
        photo.image = image;
        photo.iscapture=YES;
        photo.srcImageView=imageView;
        [photoarray addObject:photo];
    }
    MJPhotoBrowser* browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = index; // 弹出相册时显示的第一张图片是？
    browser.photos = photoarray; // 设置所有的图片
    [browser show];
}

//处理重发事件代理
- (void)reSendMessage:(MessageModel*)message
{
    switch (message.type) {
    case MessageTypePicture:
        [self reSendPicture:message];
        break;
    case MessageTypeText: {
        [self SendMessage:@"chat" body:message.content voicelenth:@"0" msgID:message.ID];
    } break;
    case MessageTypeVoice: {
        NSData* data = [NSData dataWithContentsOfFile:[Tool getVoicePath:message.voicepath]];
        [self SendMessage:@"voice" body:[Tool NSdatatoBSString:data] voicelenth:@"0" msgID:message.ID];

    } break;
    default:
        break;
    }
}
- (void)reSendPicture:(MessageModel*)message
{

    NSLog(@"reSendPicture");
    NSData* data = [NSData dataWithContentsOfFile:[Tool getFilePathFromDoc:message.content]];
    NSString* datastring1 = [Tool NSdatatoBSString:data]; //压缩编码发送
    NSURL* url = [NSURL URLWithString:[Tool Append:IMReasonableAPP witnstring:@"Upload"]];
    NSString* jidstr = [[[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
    NSString* appendfilename = [Tool GetOnlyString];
    NSDictionary* usert = [[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"type", jidstr, @"username", datastring1, @"base64Content", appendfilename, @"filename", nil];
    NSDictionary* user = [[NSDictionary alloc] initWithObjectsAndKeys:usert, @"file", nil];
    if ([NSJSONSerialization isValidJSONObject:user]) {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableData* tempJsonData = [NSMutableData dataWithData:jsonData];
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
        request.tag = [message.ID integerValue];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempJsonData];

        [request setDelegate:self];
        [request setDidFinishSelector:@selector(reSendImageSuc:)];
        [request setDidFailSelector:@selector(reSendImageFaied:)];
        [request startAsynchronous];
    }
}

- (void)reSendImageSuc:(ASIHTTPRequest*)req
{

    NSData* responsedata = [req responseData];
    NSDictionary* dict = [Tool jsontodate:responsedata];
    NSString* path = [dict objectForKey:@"UploadFileResult"];
    NSString* msgID = [NSString stringWithFormat:@"%ld", (long)req.tag]; //[req.userInfo objectForKey:@"MessageID"];
    if (path && path.length > 0) {

        [self SendMessage:@"img" body:path voicelenth:@"0" msgID:msgID];
    }
}

- (void)SendMessage:(NSString*)type body:(NSString*)body voicelenth:(NSString*)voiceth msgID:(NSString*)msgID
{
    if ([self.from.isRoom isEqualToString:@"0"]) {
        [[XMPPDao sharedXMPPManager] sendChatMessage:self.from.jidstr type:type body:body voicelenth:voiceth msgID:msgID];
    }
    else {
        [[XMPPDao sharedXMPPManager] sendChatRoomMessage:self.from.jidstr type:type body:body voicelenth:voiceth msgID:msgID];
    }
}

- (void)reSendImageFaied:(ASIHTTPRequest*)req
{

    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = NSLocalizedString(@"lbimgfaied", nil);
    hud.minSize = CGSizeMake(132.f, 108.0f);
    [hud hide:YES afterDelay:2];
}



//处理删除代理事件
- (void)acDeteleMessage:(MessageModel*)message
{

    if ([self.from.isRoom isEqualToString:@"1"]) {
        if ([IMReasonableDao markDeleteOneMessageWithID:message.ID]) {
            [self initData:YES];
        }
    }
    else {
        if ([IMReasonableDao deleteOneMessageWithID:message.ID]) {
            [self initData:YES];
        }
    }
}

//处理转发事件
- (void)acForwardMessage:(MessageModel*)message
{
    NSLog(@"转发");
    SelectUserViewController* selectview = [[SelectUserViewController alloc] initWithNibName:@"SelectUserViewController" bundle:nil];
    selectview.messageModel=message;
    selectview.flag = false;
    selectview.isforward = true;
    selectview.forwardmessage = message.content;
    UINavigationController* nvisecond = [[UINavigationController alloc] init];
    [nvisecond addChildViewController:selectview];
    [self presentViewController:nvisecond animated:YES completion:nil];
}

- (void)showTipsMessage:(NSString*)tips withShowTime:(NSInteger)time
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tips;
    hud.minSize = CGSizeMake(132.f, 108.0f);
    [hud hide:YES afterDelay:time];
}

- (void)setKeyboardVaule:(NSString*)str withType:(NSString*)type
{
    if ([type isEqualToString:@"chat"]) {
        [key setText:str];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)doRotateAction:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.allowRotation){
        
        int orientation=[((UIDevice *)notification.object) orientation];
        if (self.currentOrientation!=orientation&&(orientation==UIDeviceOrientationPortrait||orientation==UIDeviceOrientationLandscapeRight||orientation==UIDeviceOrientationLandscapeLeft)
            ) {
            self.currentOrientation=orientation;
            [key hideKeyboard];
            [tableview reloadData];
            [key removeFromSuperview];
            [self initKeyboard];
        }
    }
}

-(void)PJsendImage:(UIImage *)image AndIsOriginal:(BOOL)isOriginal{
    [self didSendImage:image AndIsOriginal:isOriginal];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.openAnimation&&!self.suspendAnimation) {
        
        // 从锚点位置出发，逆时针绕 Y 和 Z 坐标轴旋转90度
        CATransform3D transform3D = CATransform3DMakeRotation(M_PI_2, 0.0, 1.0, 1.0);
        // 定义 cell 的初始状态
        cell.alpha = 0.0;
        cell.layer.transform = transform3D;
        cell.layer.anchorPoint = CGPointMake(0.0, 0.5); // 设置锚点位置；默认为中心点(0.5, 0.5)
        [UIView animateWithDuration:0.6 animations:^{
            cell.alpha = 1.0;
            cell.layer.transform = CATransform3DIdentity;
            CGRect rect = cell.frame;
            rect.origin.x = 0.0;
            cell.frame = rect;
        }];
    }else{
        
        self.currentVisibleCellCount++;
        if(self.currentVisibleCellCount>=[tableView indexPathsForVisibleRows].count){
            
            self.suspendAnimation=false;
            self.currentVisibleCellCount=0;
        }
    }
//    if (appDelegate.openAnimation) {
//        
//        // 从锚点位置出发，逆时针绕 Y 和 Z 坐标轴旋转90度
//        CATransform3D transform3D = CATransform3DMakeRotation(M_PI_2, 0.0, 1.0, 1.0);
//        // 定义 cell 的初始状态
//        cell.alpha = 0.0;
//        cell.layer.transform = transform3D;
//        cell.layer.anchorPoint = CGPointMake(0.0, 0.5); // 设置锚点位置；默认为中心点(0.5, 0.5)
//        [UIView animateWithDuration:0.6 animations:^{
//            cell.alpha = 1.0;
//            cell.layer.transform = CATransform3DIdentity;
//            CGRect rect = cell.frame;
//            rect.origin.x = 0.0;
//            cell.frame = rect;
//        }];
//    }
}

@end
