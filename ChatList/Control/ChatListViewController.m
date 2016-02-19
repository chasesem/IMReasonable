//
//  ChatListViewController.m
//  IMReasonable
//
//  Created by apple on 14/11/21.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "RespreadSoapTool.h"
#import "MailTableViewCell.h"
#import "SpreadMailModel.h"
#import "InviteAllFriendsController.h"
#import "PJNetWorkHelper.h"
#import "MJExtension.h"
#import "ChatListViewController.h"
#import "ChatListTableViewCell.h"
#import "ImageHelp.h"
#import "ChatViewController.h"
#import "Tool.h"
#import "MessageModel.h"
#import "TitleView.h"
#import "SelectUserViewController.h"
#import "XMPPRoomDao.h"
#import "UIImageView+WebCache.h"
#import "SpreadMailViewController.h"
#import "AnimationHelper.h"
#import "ContactsTool.h"
#import "SCLAlertView.H"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

@interface ChatListViewController () {
    UITableView* tableview;

    //用户数据
    UIImageView* userinterface;

    //    NSMutableArray * chatuserlist;
    BOOL isConnectInternet;
    //进度旋转轮
    UIActivityIndicatorView* at;

    NSMutableArray* filterData;
    //搜索框
    UISearchDisplayController* searchDisplayController;
}


//在开启动画的前提下如果有新消息到来不需要执行动画效果，只当滑动聊天记录时才执行动画
@property(nonatomic,assign)BOOL suspendAnimation;
//配合suspendAnimation使用，当前可见的cell数量
@property(nonatomic,assign)int currentVisibleCellCount;

//当前屏幕的方向
@property(nonatomic,assign)int currentOrientation;

//邮箱
@property (nonatomic, strong) MailTableViewCell* eMailCell;
//邀请按钮
@property (nonatomic, strong) UIButton* inviteButton;
//提示语
@property (nonatomic, strong) UILabel* backImageView;
@property (nonatomic, strong) NSMutableArray* chatuserlist;

@end

@implementation ChatListViewController

//判断是否弹出邮箱填写提示框
- (void)showFillEmail
{
    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    BOOL enableEmailPrompt = [userdefault boolForKey:ENABLE_FILL_OUT_EMAIL_PROMPT];
    if (enableEmailPrompt) {

        BOOL has_fill_out_email = [userdefault boolForKey:HAS_FILL_OUT_EMAIL];
        if (!has_fill_out_email) {

            NSString* last_date_of_email_prompt = [userdefault stringForKey:LAST_DATE_OF_EMAIL_PROMPT];
            if ([Tool intervalSinceNow:last_date_of_email_prompt] >= INTERVAL_OF_EMAIL_PROMPT) {

                //没有填写邮箱，提示填写邮箱
                [self show];
            }
            else if ([Tool isBlankString:last_date_of_email_prompt]) {

                NSString* currentDate = [Tool GetDate:@"yyyy-hh-dd"];
                [userdefault setObject:currentDate forKey:LAST_DATE_OF_EMAIL_PROMPT];
                [userdefault synchronize];
            }
        }
    }
}

//显示编辑邮箱对话框
- (void)show
{
    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    SCLAlertView* alert = [[SCLAlertView alloc] init];
    __weak typeof(SCLAlertView)* weakAlert = alert;
    alert.hideAlert = NO;
    alert.editing = YES;
    [alert setShouldDismissOnTapOutside:NO];
    alert.shouldDismissOnTapOutside = YES;
    alert.hideAnimationType = SlideOutToBottom;
    alert.showAnimationType = SlideInFromTop;
    UITextField* textField = [alert addTextField:@"edit email"];
    [alert addButton:NSLocalizedString(@"btnDone", nil)
         actionBlock:^{
             NSString* email = textField.text;
             if ([Tool isBlankString:email]) {

                 [AnimationHelper show:NSLocalizedString(@"EMAIL_CANNOT_EMPTY", nil) InView:self.view];
             }
             else if ([Tool isValidateEmail:email]) {

                 [AnimationHelper showHUD:@"load......"];
                 //提交邮箱
                 NSString* phone = [[[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
                 NSString* param = [NSString stringWithFormat:ADD_EMAIL_PARAM, RESPREAD_EMAIL, RESPREAD_PASSWORD, email, phone, [Tool getDateWithFormatString:@"yyyy-MM-ddThh:mm:ss"], [Tool getDateWithFormatString:@"yyyy-MM-ddThh:mm:ss"], CONTACTS];
                 dispatch_async(dispatch_get_global_queue(0, 0), ^{
                     [RespreadSoapTool Soap:WSDL_URL
                         WithParam:param
                         success:^(id success) {

                             [userdefault setBool:YES forKey:HAS_FILL_OUT_EMAIL];
                             //保存用户填写的邮箱
                             [userdefault setObject:email forKey:USER_SPREAD_EMAIL];
                             [userdefault setObject:email forKey:MyEmail];
                             [userdefault setBool:NO forKey:ENABLE_FILL_OUT_EMAIL_PROMPT];
                             [userdefault synchronize];
                             [AnimationHelper removeHUD];
                             [weakAlert hideView];
                         }
                         failure:^(NSError* error) {
                             [userdefault setObject:[Tool GetDate:@"yyyy-hh-dd"] forKey:LAST_DATE_OF_EMAIL_PROMPT];
                             [userdefault setBool:NO forKey:HAS_FILL_OUT_EMAIL];
                             [userdefault synchronize];
                             [AnimationHelper removeHUD];
                             [Tool alert:NSLocalizedString(@"SUBMISSION_FAILURE", nil)];
                         }];
                 });
             }
             else {

                 [AnimationHelper show:NSLocalizedString(@"EMAIL_PROMPT_ERROR", nil) InView:self.view];
             }
         }];
    [alert addButton:NSLocalizedString(@"NO_LONGER_TIPS", nil)
         actionBlock:^{
             [userdefault setBool:NO forKey:ENABLE_FILL_OUT_EMAIL_PROMPT];
             [userdefault synchronize];
             [weakAlert hideView];
         }];
    [alert addButton:NSLocalizedString(@"LATER", nil)
         actionBlock:^{
             NSString* currentDate = [Tool GetDate:@"yyyy-hh-dd"];
             [userdefault setObject:currentDate forKey:LAST_DATE_OF_EMAIL_PROMPT];
             [userdefault synchronize];
             [weakAlert hideView];
         }];
    [alert showEdit:self title:nil subTitle:NSLocalizedString(@"EMAIL_PROMPT", nil) closeButtonTitle:NSLocalizedString(@"lbTCancle", nil) duration:0.0f];
}

- (MailTableViewCell*)eMailCell
{
    if (_eMailCell == nil) {

        _eMailCell = [[MailTableViewCell alloc] init];
    }
    return _eMailCell;
}

- (UIButton*)inviteButton
{
    if (_inviteButton == nil) {

        NSString* inviteText = NSLocalizedString(@"INVITE_FOR_FREE", nil);
        CGSize titleSize = [inviteText sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        _inviteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_inviteButton.layer setMasksToBounds:YES];
        [_inviteButton.layer setCornerRadius:10.0];
        [_inviteButton setTitle:inviteText forState:UIControlStateNormal];
        CGRect inviteButtonRect = CGRectMake(0, 0, titleSize.width + 16.0, titleSize.height + 10);
        _inviteButton.frame = inviteButtonRect;
        [_inviteButton setBackgroundImage:[Tool imageWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
        [_inviteButton setBackgroundImage:[Tool imageWithColor:[UIColor orangeColor]] forState:UIControlStateHighlighted];
        [_inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _inviteButton.frame = inviteButtonRect;
        _inviteButton.center = CGPointMake(self.backImageView.center.x, self.backImageView.center.y + 46);
        [_inviteButton addTarget:self action:@selector(Invite) forControlEvents:UIControlEventTouchUpInside];
    }
    return _inviteButton;
}

- (UILabel*)backImageView
{
    if (_backImageView == nil) {

        CGRect rect = CGRectMake(SCREENWIDTH * 0.1, 0, SCREENWIDTH * 0.8, SCREENWIHEIGHT - 49 - 64);
        _backImageView = [[UILabel alloc] initWithFrame:rect];
        _backImageView.contentMode = UIViewContentModeScaleAspectFit;
        _backImageView.tag = 9999;
        _backImageView.text = NSLocalizedString(@"lbclvNoMan", nil);
        _backImageView.textAlignment = NSTextAlignmentCenter;
        _backImageView.textColor = [UIColor grayColor];
        _backImageView.lineBreakMode = NSLineBreakByWordWrapping;
        _backImageView.numberOfLines = 0;
        _backImageView.hidden = YES;
        _backImageView.userInteractionEnabled = NO;
    }
    return _backImageView;
}

- (NSMutableArray*)chatuserlist
{
    if (_chatuserlist == nil) {

        _chatuserlist = [IMReasonableDao getChatlistModle];
    }
    return _chatuserlist;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //添加聊天代理
    [XMPPDao sharedXMPPManager].chatHelerpDelegate = self;
    [self initNavbutton];
    [self initData];
    [self initControl];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeItem)
                                                 name:@"CHANGEITEM"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localUserChange:)
                                                 name:@"CONNECTSCHANGE"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doRotateAction:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [self showFillEmail];
    //    [self show];
}

- (void)localUserChange:(NSNotification*)nt
{
    NSDictionary* dict = nt.userInfo;
    if ([[dict objectForKey:@"action"] isEqualToString:@"1"]) { // 开启联系人扫描动画

        dispatch_async(dispatch_get_main_queue(), ^{
            [at startAnimating];
            userinterface.hidden = YES;
            self.navigationItem.title = NSLocalizedString(@"lblookforfriend", nil);
        });
    }
    else if ([[dict objectForKey:@"action"] isEqualToString:@"2"]) { //停止动画 刷新数据

        dispatch_async(dispatch_get_main_queue(), ^{
            [at stopAnimating];
            userinterface.hidden = NO;
            self.navigationItem.title = NSLocalizedString(@"lbchats", nil);
        });
    }
}

- (void)changeItem
{
    [self initData];
}

- (void)initData
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{

        self.chatuserlist = [IMReasonableDao getChatlistModle];
        [self getfilterData];

//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIView* tempview = [self.view viewWithTag:9999];
//            if (self.chatuserlist.count) {
//
//                tempview.hidden = YES;
//            }
//            else {
//                tempview.hidden = NO;
//            }
//            [tableview reloadData];
//        });

    });
//    UIView* tempview = [self.view viewWithTag:9999];
//    if (self.chatuserlist.count) {
//
//        tempview.hidden = YES;
//    }
//    else {
//        tempview.hidden = NO;
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [XMPPDao sharedXMPPManager].chatHelerpDelegate = self;
    [self initNavbutton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self initData];
//        dispatch_async(dispatch_get_main_queue(),^{
//            [tableview reloadData];
//        });
//    });
}

//图片浏览器
- (void)ImageBrowser:(NSArray*)messageModelArray WithShowIndex:(NSInteger)index
{

    NSMutableArray* photoarray = [NSMutableArray array];
    for (MessageModel* photoModel in messageModelArray) {
        NSString* imagePath = [photoModel.content stringByReplacingOccurrencesOfString:@"Small" withString:@""];
        NSLog(@"%@", imagePath);
        NSString* imageURL = [Tool Append:IMReasonableAPPImagePath witnstring:imagePath];
        UIImage* image = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:photoModel.content]];
        NSLog(@"%@", [Tool getFilePathFromDoc:photoModel.content]);
        MJPhoto* photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageURL];
        photo.image = image;
        [photoarray addObject:photo];
    }
    MJPhotoBrowser* browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = index; // 弹出相册时显示的第一张图片是？
    browser.photos = photoarray; // 设置所有的图片
    [browser show];
}

//联系人点击
- (void)userinterface:(UIButton*)btn
{
    NSLog(@"用户头像被点击");
    NSString* imagename = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPMYFACE];
    UIImage* tempimg = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:imagename]];
    NSMutableArray* photoarray = [NSMutableArray array];
    MJPhoto* photo = [[MJPhoto alloc] init];
    photo.image = tempimg;
    [photoarray addObject:photo];
    MJPhotoBrowser* browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = photoarray; // 设置所有的图片
    [browser show];
}

#pragma mark -创建导航栏上得按钮
- (void)initNavbutton
{

    self.navigationItem.title = NSLocalizedString(@"lbchats", nil);
    ;
    NSString* imagename = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPMYFACE];
    UIView* btnview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    UIImage* tempimg = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:imagename]];
    userinterface = [[UIImageView alloc] initWithImage:tempimg ? tempimg : [UIImage imageNamed:@"default"]];
    userinterface.frame = CGRectMake(0, 0, 32, 32);
    //隐藏圆角半径以外的内容
    userinterface.layer.masksToBounds = YES;
    //设置圆角半径
    userinterface.layer.cornerRadius = 16;
    at = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    at.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    //用户头像按钮
    UIButton* leftbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftbtn.frame = CGRectMake(0, 0, 32, 32);
    leftbtn.backgroundColor = [UIColor clearColor];
    [leftbtn addTarget:self action:@selector(userinterface:) forControlEvents:UIControlEventTouchUpInside];
    [btnview addSubview:userinterface];
    [btnview addSubview:at];
    [btnview addSubview:leftbtn];
    UIBarButtonItem* leftitem = [[UIBarButtonItem alloc] initWithCustomView:btnview];
    self.navigationItem.leftBarButtonItem = leftitem;
    //右侧按钮，选择联系人
    UIBarButtonItem* right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(Selectfriend:)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)Selectfriend:(UIBarButtonItem*)btn
{
    NSLog(@"Selectfriend");
    SelectUserViewController* selectview = [[SelectUserViewController alloc] initWithNibName:@"SelectUserViewController" bundle:nil];
    selectview.flag = false;
    UINavigationController* nvisecond = [[UINavigationController alloc] init];
    [nvisecond addChildViewController:selectview];
    [self presentViewController:nvisecond animated:YES completion:nil];
}

#pragma mark -初始化Control
- (void)initControl
{

    self.currentOrientation=[[UIDevice currentDevice] orientation];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIHEIGHT)];
    tableview.delegate = self;
    tableview.dataSource = self;
    // 添加搜索栏
    UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.barTintColor = [UIColor whiteColor];
    searchBar.placeholder = NSLocalizedString(@"lbfsearch", nil);
    searchBar.delegate = self;
    tableview.tableHeaderView = searchBar;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    UIRefreshControl* ref = [[UIRefreshControl alloc] init];
    ref.tintColor = [UIColor grayColor];
    ref.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"msgRef", nil)];
    [ref addTarget:self action:@selector(RefreshViewControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    tableview.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [tableview addSubview:ref];

    tableview.tableFooterView = [[UIView alloc] init]; //设置不要显示多余的行;

    [self.view addSubview:tableview];
    [self initPrompt];
}

- (void)initPrompt
{
    if (self.chatuserlist.count <= 0) {

        [self.view addSubview:self.backImageView];
        [self.view addSubview:self.inviteButton];
        tableview.backgroundColor = [UIColor clearColor];
    }
    else {
        [self.inviteButton removeFromSuperview];
        [self.backImageView removeFromSuperview];
    }
}

/**
 *  邀请开始
 *
 *  @param ref <#ref description#>
 */

//免费邀请好友按钮点击事件
- (void)Invite
{
    if (![PJNetWorkHelper isNetWorkAvailable]) {

        [PJNetWorkHelper NoNetWork];
    }
    else {

        [AnimationHelper showHUD:LOADING];
        InviteAllFriendsController* inviteAllFriendsController = [[InviteAllFriendsController alloc] init];
        UINavigationController* nvisecond = [[UINavigationController alloc] init];
        [nvisecond addChildViewController:inviteAllFriendsController];
        [self presentViewController:nvisecond animated:YES completion:nil];
    }
}

/**
 *  邀请结束
 *
 *  @param ref <#ref description#>
 */

- (void)RefreshViewControlEventValueChanged:(UIRefreshControl*)ref
{
    if (ref.refreshing) {
        ref.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"msgRefing", nil)];
        [self initData];
        [self performSelector:@selector(RefTableview:) withObject:ref afterDelay:1];
    }
}

- (void)RefTableview:(UIRefreshControl*)ref
{
    [ref endRefreshing];
    ref.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"msgRef", nil)];
    [tableview reloadData];
}

//#pragma mark-收到新消息
//#pragma mark-登陆成功
- (void)isSuccLogin:(BOOL)flag
{
    NSLog(@"登陆成功");
}

#pragma mark - 表格代理是需要实现的方法

- (void)tableView:(UITableView*)tableView didEndDisplayingCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self initPrompt];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatuserlist.count;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    IMChatListModle* temp = [self.chatuserlist objectAtIndex:[indexPath row]];
    static NSString* CellIdentifier = @"ChatListCell";

    if ([temp.messagebody.type isEqualToString:EMAIL]) {

        self.eMailCell=[[MailTableViewCell alloc] init];
        self.eMailCell.chatListModle = temp;
        _eMailCell.tag = MessageTypeEmail;
        _eMailCell.selectionStyle=UITableViewCellSelectionStyleGray;
        //去除分割线左边出现的空格
        if ([_eMailCell respondsToSelector:@selector(setSeparatorInset:)]) {
            [_eMailCell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([_eMailCell respondsToSelector:@selector(setLayoutMargins:)]) {
            [_eMailCell setLayoutMargins:UIEdgeInsetsZero];
        }
        return _eMailCell;
    }
    else {

        //从缓存中获取
        ChatListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        //如果还未缓存过
        if (cell == nil) {
            cell = [[ChatListTableViewCell alloc] init];

            //去除分割线左边出现的空格
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsZero];
            }

            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsZero];
            }
        }
        cell.backgroundColor = [UIColor clearColor];

        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        UIImage* tempimg = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:temp.faceurl]];

        NSString* path = [Tool Append:IMReasonableAPPImagePath witnstring:temp.faceurl];
        NSString* defaultphoto = @"default";
        if ([temp.isRoom isEqualToString:@"1"]) {
            defaultphoto = @"GroupChatRound";
        }
        else {
            cell.messagecount.backgroundColor = [UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];
        }

        [cell.userphoto sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:tempimg ? tempimg : [UIImage imageNamed:defaultphoto]]; //@"default"]];

        cell.username.text = temp.localname ? temp.localname : [[temp.jidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
        NSString* msg = temp.messagebody.body;
        if ([temp.messagebody.type isEqualToString:@"img"] || [temp.messagebody.type isEqualToString:@"locimg"]) {
            msg = @"[image]";
        }
        if ([temp.messagebody.type isEqualToString:@"voice"] || [temp.messagebody.type isEqualToString:@"locimg"]) {
            msg = @"[voice]";
        }
        cell.message.text = msg;
        cell.messagetime.text = NSLocalizedString(temp.messagebody.date, temp.messagebody.date);
        //是否显示消息条数
        if ([temp.messageCount integerValue] > 0) {
            cell.messagecount.hidden = NO;
            if ([temp.isRoom isEqualToString:@"1"] && [temp.isNeedTip isEqualToString:@"0"]) {
                cell.messagecount.backgroundColor = [UIColor lightGrayColor];
            }
            cell.messagecount.text = [temp.messageCount integerValue] < 99 ? temp.messageCount : @"99+";
        }
        else {
            cell.messagecount.hidden = YES;
        }
        if (_inviteButton != nil) {

            [_inviteButton removeFromSuperview];
            [_backImageView removeFromSuperview];
        }
        return cell;
    }
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IMChatListModle* temp = [_chatuserlist objectAtIndex:[indexPath row]];

    if ([tableView cellForRowAtIndexPath:indexPath].tag == MessageTypeEmail) {

        SpreadMailViewController* spreadMailViewControl = [[SpreadMailViewController alloc] init];
        spreadMailViewControl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:spreadMailViewControl animated:YES];
    }
    else {

        [searchDisplayController.searchBar resignFirstResponder];
        ChatViewController* Cannotview = [[ChatViewController alloc] init];
        self.tempmsg = temp.jidstr;
        Cannotview.from = temp;
        temp.messageCount = @"0";
        [_chatuserlist replaceObjectAtIndex:[indexPath row] withObject:temp];
        Cannotview.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:Cannotview animated:NO];
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 63;
}

//表格删除按钮的实现
- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return TRUE;
}
//修改删除按钮的标题
- (NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return NSLocalizedString(@"lbclvdelete", nil);
}
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{

    if (editingStyle == UITableViewCellEditingStyleDelete) { //如果编辑样式为删除样式
        if (indexPath.row < [_chatuserlist count]) {

            IMChatListModle* temp = [_chatuserlist objectAtIndex:[indexPath row]];

            if ([temp.isRoom isEqualToString:@"1"] && [temp.isimrea isEqualToString:@"1"]) { //是群且不是群成员的时候删除就是清除数据
                //真实的删除本地数据库数据
                if ([IMReasonableDao deleteUser:temp.jidstr]) { //删除成员并删除消息
                    [_chatuserlist removeObjectAtIndex:indexPath.row]; //移除数据源的数据
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft]; //移除tableView中的数据
                }
            }
            else {
                //删除普通聊天
                if ([IMReasonableDao updateNotShow:temp.jidstr]) {
                    [_chatuserlist removeObjectAtIndex:indexPath.row]; //移除数据源的数据
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft]; //移除tableView中的数据
                }
            }
        }
    }
    if(!_chatuserlist||_chatuserlist.count==0){
        
        [self.view addSubview:self.backImageView];
        [self.view addSubview:self.inviteButton];
    }
}

#pragma mark -ChatHelperdelegate
- (void)receiveNewMessage:(IMMessage*)message isFwd:(BOOL)isfwd
{
    NSLog(@"message:%@", message);
    NSLog(@"messageType:%@", message.type);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    [self initData];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.suspendAnimation=true;
//        [tableview reloadData];
        if (_inviteButton != nil) {

            [_inviteButton removeFromSuperview];
            [_backImageView removeFromSuperview];
        }
    });
}
- (void)isSuccSendMessage:(IMMessage*)msg issuc:(BOOL)flag;
{
}
- (void)userStatusChange:(XMPPPresence*)presence
{

    if (presence == nil) {
        [self initData];
    }
}

#pragma mark - searchdelegate

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchString:(NSString*)searchString
{
    [self getfilterData];
    return YES;
}

- (void)getfilterData
{

    [filterData removeAllObjects];

    NSString* search = searchDisplayController.searchBar.text;
    if (search.length > 0) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"localname contains[c] %@ or phonenumber contains[c] %@ ", search, search]; //用于过滤
        _chatuserlist = [NSMutableArray arrayWithArray:[_chatuserlist filteredArrayUsingPredicate:predicate]];
    }
    else {
        _chatuserlist = [IMReasonableDao getChatlistModle];
        self.suspendAnimation=true;
        dispatch_async(dispatch_get_main_queue(), ^{
              [tableview reloadData];
        });
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //当scope改变时调用
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{

    _chatuserlist = [IMReasonableDao getChatlistModle];
    [tableview reloadData];
}

#pragma mark -didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    //去除分割线左边出现的空格
    if ([tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableview setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }

    if ([tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableview setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)doRotateAction:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.allowRotation){
        
        int orientation=[((UIDevice *)notification.object) orientation];
        if (self.currentOrientation!=orientation&&(orientation==UIDeviceOrientationPortrait||orientation==UIDeviceOrientationLandscapeRight||orientation==UIDeviceOrientationLandscapeLeft)
            ) {
            [tableview reloadData];
            self.currentOrientation=orientation;
        }
   
    }
}

//cell加载时的动画效果
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
}

@end
