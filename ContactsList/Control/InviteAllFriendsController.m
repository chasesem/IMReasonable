//
//  InviteAllFriendsController.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/20.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "Person.h"
#import "ContactsTool.h"
#import "InviteAllFriendsController.h"
#import "AnimationHelper.h"
#import "UIColor+Hex.h"
#import "AppDelegate.h"

#define INVITECELL @"UITableViewCell"
#define INVITEALL_BUTTON_H 56//一键邀请按钮大小

@interface InviteAllFriendsController ()<UIAlertViewDelegate>
//所有非talkking用户
@property(nonatomic,copy)NSArray* personArray;
@end

@implementation InviteAllFriendsController

//懒加载所有非talkking用户
-(NSArray *)personArray{
    if(!_personArray){
        
        _personArray=[ContactsTool AllPerson];
    }
    return _personArray;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [self initTableView];
    [self initNav];
}

-(void)viewWillAppear:(BOOL)animated{
    [AnimationHelper removeHUD];
}

- (void)initTableView
{
    //去除空行
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //显示左边的checkbox
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    //添加一键邀请所有按钮
    UIButton * inviteAllButton=[[UIButton alloc] init];
    [inviteAllButton setTitle:NSLocalizedString(@"INVITE_ALL_PEOPLE", nil) forState:UIControlStateNormal];
    [inviteAllButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [inviteAllButton setBackgroundImage:[Tool imageWithColor:[UIColor colorWithHexString:@"#00ccff"]AndRect:CGRectMake(0, 0, SCREENWIDTH, INVITEALL_BUTTON_H)] forState:UIControlStateNormal];
    [inviteAllButton setBackgroundImage:[Tool imageWithColor:[UIColor colorWithHexString:@"#0099ff"] AndRect:CGRectMake(0, 0, SCREENWIDTH, INVITEALL_BUTTON_H)] forState:UIControlStateNormal];
    inviteAllButton.frame=CGRectMake(0, 0, SCREENWIDTH, INVITEALL_BUTTON_H);
    [inviteAllButton addTarget:self action:@selector(InviteAllFriends) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView setTableHeaderView:inviteAllButton];
    self.tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}

//一键邀请所有好友
-(void)InviteAllFriends{
    UIAlertView* myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"lbinvitation",nil) message:NSLocalizedString(@"lbissureinvitation",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"btnDone",nil) otherButtonTitles:NSLocalizedString(@"lbTCancle",nil), nil];
    [myAlertView show];
}

#pragma mark -uialertview代理
- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //确定群邀
    if(buttonIndex==INVITE){
        
        [self didInvitationAllFriends];
    }
}

//发送群邀
-(void)didInvitationAllFriends{
    [AnimationHelper show:NSLocalizedString(@"START_INVITE",nil) InView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [ContactsTool DidInviteAllFriends:[ContactsTool AllPhoneAndEmail]];
}

- (void)initNav
{
    self.navigationItem.title = NSLocalizedString(@"lbSUTitle", nil);
    UIBarButtonItem* left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = left;
    UIBarButtonItem* right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(invite)];
    self.navigationItem.rightBarButtonItem = right;

    self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //判断完成按钮是否可以被点击
    if([self.tableView indexPathsForSelectedRows]!=nil){
        
        self.navigationItem.rightBarButtonItem.enabled=YES;
    }else{
        
        self.navigationItem.rightBarButtonItem.enabled=NO;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置完成按钮可以被点击
    self.navigationItem.rightBarButtonItem.enabled=YES;
}

- (void)invite
{
    [AnimationHelper show:NSLocalizedString(@"START_INVITE",nil) InView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    //群邀
    NSArray* selectedPersonIndexArray=[self.tableView indexPathsForSelectedRows];
    //存放所有待邀请手机号码
    NSMutableArray* allPhoneArray=[NSMutableArray array];
    //存放所有待邀邮箱
    NSMutableArray* allemailArray=[NSMutableArray array];
    NSMutableArray* phoneAndemailArray=[NSMutableArray array];
    for(int i=0;i<selectedPersonIndexArray.count;i++){
        
        Person* per=self.personArray[((NSIndexPath *)selectedPersonIndexArray[i]).row];
        //有些用户只有手机号码或只有邮箱(手机号码和邮箱都可以是多个的，手机号码或邮箱为空就没必要添加)
        NSArray* phone=per.phoneArray;
        NSArray* email=per.emailArray;
        if(phone.count>0){
            
            [allPhoneArray addObjectsFromArray:phone];
        }
        if(email.count>0){
            
            [allemailArray addObjectsFromArray:email];
        }
    }
    [phoneAndemailArray addObject:allPhoneArray];
    [phoneAndemailArray addObject:allemailArray];
    [ContactsTool DidInviteAllFriends:phoneAndemailArray];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete implementation, return the number of rows
    return self.personArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:INVITECELL];
    if(cell==nil){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:INVITECELL];
    }
    Person* per=self.personArray[indexPath.row];
    //用户可能只有手机号码或邮箱或者两个都没有
    if(per.phoneArray.count>0){
        
        //有多个电话号码也只是显示第一个号码
        NSString *phone=per.phoneArray[0];
        cell.detailTextLabel.text=[ContactsTool DidCutPhoneArea:phone];
    }else if(per.emailArray.count>0){
        
        //有多个邮箱也只显示第一个邮箱
        cell.detailTextLabel.text=per.emailArray[0];
    }
    cell.textLabel.text = per.name;
    cell.textLabel.lineBreakMode=NSLineBreakByTruncatingTail;
    return cell;
}

//cell加载时的动画效果
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.openAnimation) {
        
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
    }
}

@end
