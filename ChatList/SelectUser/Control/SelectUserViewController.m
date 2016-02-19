//
//  SelectUserViewController.m
//  IMReasonable
//
//  Created by apple on 15/2/2.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//



#import "MessageModel.h"
#import "SelectUserViewController.h"
#import "AppDelegate.h"
#import "Tool.h"
#import "ChatViewController.h"
#import "GroupAddUserUIViewController.h"
#import "XMPPRoomDao.h"
#import "ChineseString.h"

@interface SelectUserViewController ()
//存放拼音排序后的名字
@property(nonatomic,strong)NSMutableArray *letterNameArray;
//存放未排序的名字
@property(nonatomic,strong)NSMutableArray *localNameArray;
//******key=localname,value=IMChatListModle
@property(nonatomic,strong)NSMutableDictionary *talKingUserDic;
//******value=IMChatListModle
@property(nonatomic,strong)NSMutableArray * chatuserlist;

@end

@implementation SelectUserViewController

-(NSMutableArray *)letterNameArray{
    _letterNameArray=[NSMutableArray arrayWithArray:[self.localNameArray sortedArrayUsingFunction:nickNameSort context:NULL]];
    return _letterNameArray;
}

NSInteger nickNameSort(id user1, id user2, void *context){
    NSString *u1,*u2;
    //类型转换
    u1 = (NSString*)user1;
    u2 = (NSString*)user2;
    return  [u1 localizedCompare:u2
             ];
}

-(NSMutableArray *)localNameArray{
    if(_localNameArray==nil){
        
        _localNameArray=[NSMutableArray array];
        for(int i=0;i<_chatuserlist.count;i++){
            
            NSString *name=((IMChatListModle*)_chatuserlist[i]).localname;
            //名字为空则用其jid代替
            if([Tool isBlankString:name]){
                
                name=((IMChatListModle*)_chatuserlist[i]).jidstr;
                //去除@及其后面
                name=[name substringToIndex:[name rangeOfString:@"@"].location];
            }
            [_localNameArray addObject:[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
    }
    return _localNameArray;
}

-(NSMutableDictionary *)talKingUserDic{
    if(_talKingUserDic==nil){
        
        if(_chatuserlist.count>0){
            
            _talKingUserDic=[[NSMutableDictionary alloc] init];
            for(int i=0;i<_chatuserlist.count;i++){
                IMChatListModle *model=_chatuserlist[i];
                [_talKingUserDic setValue:model forKey:_localNameArray[i]];
            }
        }
    }
    return _talKingUserDic;
}

-(NSMutableArray *)chatuserlist{
    if(_chatuserlist==nil){
        
        _chatuserlist=[IMReasonableDao getAllactiveUser];
    }
    return _chatuserlist;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    if (self.flag) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isGroup) {
        self.tableview.allowsMultipleSelectionDuringEditing=YES;
        self.tableview.editing=YES;
    }
    
    self.tableview.tableFooterView=[[UIView alloc]init];
    self.tableview.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self initNavbutton];
    [self initData];
    [self initControl];
}

- (void) initData
{
    
    if(self.chatuserlist.count<=0){
        
        UILabel *label=[[UILabel alloc] init];
        label.text=NSLocalizedString(@"GO_AND_INVITE_FRIENDS", nil);
        CGRect labelRect=CGRectMake(0, 0, self.view.bounds.size.width, 16);
        label.frame=labelRect;
        [self.view addSubview:label];
        label.center=self.view.center;
        label.textAlignment=UITextAlignmentCenter;
    }
    
}
- (void) initNavbutton
{
    self.navigationItem.title=NSLocalizedString(@"lbSUTitle", nil);
    UIBarButtonItem * left=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(undo)];
    self.navigationItem.leftBarButtonItem=left;
    
   
    
    if (self.isGroup) {
        UIBarButtonItem * right=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectUser:)];
        self.navigationItem.rightBarButtonItem=right;
        
        self.navigationItem.rightBarButtonItem.enabled=NO;
        
        
    }
    
    
    
}

- (AppDelegate *)appDelegate
{
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate;
}
- (void)initControl
{
    self.tableview .delegate=self;
    self.tableview .dataSource=self;
    
}

#pragma mark-表格的代理函数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatuserlist.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
        }
    }
    
    NSString *localName=[self.letterNameArray objectAtIndex:[indexPath row]];
    IMChatListModle *temp=[self.talKingUserDic objectForKey:localName];
    if (!self.isGroup) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
   
    
    UIImage * tempimg=[UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:temp.faceurl]];
    tempimg=tempimg?tempimg:[UIImage imageNamed:@"default"];
    cell.imageView.image=[Tool imageCompressForSize:tempimg targetSize:CGSizeMake(40, 40)];//[UIImage imageNamed:temp.faceurl];
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 20;

    cell.textLabel.text=[[temp.jidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
    
    cell.detailTextLabel.text=temp.localname;
    return cell;
    
}

//确定转发
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    NSLog(@"确定转发");
    if (!self.isGroup) {
        
        if (self.isAddGroupUser) {
            
            UIActionSheet * sheet;
//            "lbsuvaddtitle"="加群";
//            "lbsuvadd"="添加";
//            "lbsuvcancel"="取消";
            sheet=[[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"lbsuvaddtitle",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"lbsuvcancel",nil) destructiveButtonTitle:NSLocalizedString(@"lbsuvadd",nil) otherButtonTitles:nil];
            sheet.tag=[indexPath row];
            sheet.actionSheetStyle=UIActionSheetStyleDefault;
            [sheet showInView:self.view];

            
        }else{
        
        NSString *localName=[self.letterNameArray objectAtIndex:[indexPath row]];
        IMChatListModle *temp=[self.talKingUserDic objectForKey:localName];
            
        ChatViewController *Cannotview=[[ChatViewController alloc] init];
        Cannotview.forwardMessageModel=self.messageModel;
        Cannotview.from=temp;
        Cannotview.isforward=self.isforward;
        Cannotview.forwardmssage=self.forwardmessage;
            
        temp.unreadcount=@"0";
        [_chatuserlist replaceObjectAtIndex:[indexPath row] withObject:temp];
        Cannotview.hidesBottomBarWhenPushed=YES;
        self.flag=true;
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = NSLocalizedString(@"lbchats",nil);
        self.navigationItem.backBarButtonItem = backItem;
        [self.navigationController pushViewController:Cannotview animated:NO];
            
        }
        
    }else{
         self.navigationItem.rightBarButtonItem.enabled=YES;
    
    }
    
    
    
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
           // [Tool alert:@"添加成功"];
            
            IMChatListModle * temp=[_chatuserlist objectAtIndex:actionSheet.tag];
           // [[XMPPRoomDao sharedXMPPManager] InviteUser:temp.jidstr subject:self.from.localname];//邀请好友加入群里
            [[XMPPDao sharedXMPPManager] addUserToRoom:self.from.jidstr userjidstr:temp.jidstr roomname:self.from.localname];
            [IMReasonableDao addRoomUser:self.from.jidstr userjidstr:temp.jidstr role:@"0"];//把人员添加到数据库
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddGroupUser"
                                                                object:self];

            [self dismissViewControllerAnimated:NO completion:nil];
            
            
        }break;
            
        default:
            break;
            
            
    }
    
    
}

- ( void )tableView:( UITableView *)tableView didDeselectRowAtIndexPath:( NSIndexPath *)indexPath
{
    
    if (![[tableView indexPathsForSelectedRows] count]) {
          self.navigationItem.rightBarButtonItem.enabled=NO;
    }
   // NSLog(@"dsa");
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)undo {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)selectUser:(UIBarButtonItem*) btn{
    
    NSMutableArray * selectUser=[[NSMutableArray alloc]init];
    
    NSArray *selectRow=[self.tableview indexPathsForSelectedRows];
    for (NSIndexPath *index in selectRow) {
        
        NSString *localName=[self.letterNameArray objectAtIndex:[index row]];
        IMChatListModle *temp=[self.talKingUserDic objectForKey:localName];
        [selectUser addObject:temp];
        
    }
    //把数据回传到页面
    [self.selectUserdelegate SelectUserData:selectUser withsubject:self.tempsubject];
    
    [self dismissViewControllerAnimated:NO completion:nil];
  
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

