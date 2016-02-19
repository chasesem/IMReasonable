//
//  GroupSetViewController.m
//  IMReasonable
//
//  Created by apple on 15/4/21.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "GroupSetViewController.h"
#import "IMReasonableDao.h"
#import "OneRoomUser.h"
#import "XMPPDao.h"
#import "SelectUserViewController.h"
#import "UIImageView+WebCache.h"
#import "ChatViewController.h"
#import "MainViewController.h"
#import "NeedTipsTableViewCell.h"

@interface GroupSetViewController ()
{
    UITableView *tableview;
    NSMutableArray * oneRoomUser;
    BOOL isCreatByOwn;
    NSString * myjidstr;
}

@end

@implementation GroupSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [XMPPDao sharedXMPPManager].roomDelegate=self;
    
    [self initNavbutton];
    [self initControl];
    [self initData];
    
    myjidstr=[[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEJID];
    
    
    
  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeItem)
                                                 name:@"AddGroupUser"
                                               object:nil];
}





- (void)changeItem
{
     [self initData];  
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

-(void)initNavbutton
{
    self.navigationItem.title=[NSString stringWithFormat:@"%@%@",self.from.localname,@"详情"];
    
}
-(void)initControl
{
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    tableview =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIHEIGHT-64)];
    tableview.delegate=self;
    tableview.dataSource=self;
 //   tableview.backgroundColor=[UIColor lightGrayColor];
    tableview.tableFooterView = [[UIView alloc]init];//设置不要显示多余的行;
    [self.view addSubview:tableview];

    
}
-(void)initData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        oneRoomUser=[IMReasonableDao getOneRoomUser:self.from.jidstr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableview reloadData];
        });
        
    });
   
    
}

#pragma mark-表格代理事件
#pragma mark- 表格代理是需要实现的方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 2;
    }else{
     return oneRoomUser.count+1;
    }
   
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell * cell;
    
    if ([indexPath section]==0) {
        
        if ([indexPath row]==0) {
            GroupSetTableViewCell * tempcell=[tableView dequeueReusableCellWithIdentifier:@"cell_Function"];
            if (tempcell == nil)
            {
                tempcell = [[GroupSetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                        reuseIdentifier:@"cell_Function"];
                //这段代码重复三次而不提到外层的原因是避免每一个cell的去执行这个片段
                if ([tempcell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [tempcell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
                }
                
                if ([tempcell respondsToSelector:@selector(setLayoutMargins:)]) {
                    [tempcell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
                }
            }
            
            
            UIImage * tempimg=[UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:self.from.faceurl]];
            
            NSString *path=[Tool Append:IMReasonableAPPImagePath witnstring:self.from.faceurl];
            [tempcell.groupface sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:tempimg?tempimg:[UIImage imageNamed:@"default"]];
            tempcell.subject.text=self.from.localname;
            
            tempcell.editface.hidden=YES;
            if ([self.from.isCreatMe isEqualToString:@"1"]) {
                [tempcell.editface setTitle:NSLocalizedString(@"lbgsvedit", nil) forState:UIControlStateHighlighted];
                [tempcell.editface setTitle:NSLocalizedString(@"lbgsvedit", nil) forState:UIControlStateNormal];
            }
            [tempcell.editface setTag:[indexPath row]];
            [tempcell.editface addTarget:self action:@selector(changeFace:) forControlEvents:UIControlEventTouchUpInside];
            tempcell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell= tempcell;
        }else{
        
            NeedTipsTableViewCell * tempcell=[tableView dequeueReusableCellWithIdentifier:@"cell_Need"];
            if (tempcell == nil)
            {
                tempcell = [[NeedTipsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                        reuseIdentifier:@"cell_Need"];
                //这段代码重复三次而不提到外层的原因是避免每一个cell的去执行这个片段
                if ([tempcell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [tempcell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
                }
                
                if ([tempcell respondsToSelector:@selector(setLayoutMargins:)]) {
                    [tempcell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
                }
            }
             tempcell.selectionStyle = UITableViewCellSelectionStyleNone;
             tempcell.title.text=@"静音";
            BOOL flag=false;
            if ([self.from.isNeedTip isEqualToString:@"1"]) {
                flag=true;
            }
            
             [tempcell.isNeedTips addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [tempcell.isNeedTips setOn:!flag];
            

            cell=tempcell;
        }
        
       
        
    }else{
        
    
        if ([indexPath row]==oneRoomUser.count) {
            
            AddGroupUserTableViewCell * tempcell=[tableView dequeueReusableCellWithIdentifier:@"cell_AddGroupUser"];
            if (tempcell == nil)
            {
                tempcell = [[AddGroupUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:@"cell_AddGroupUser"];
                
                if ([tempcell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [tempcell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
                }
                
                if ([tempcell respondsToSelector:@selector(setLayoutMargins:)]) {
                    [tempcell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
                }
            }
            
          
            [tempcell.addgroupuser addTarget:self action:@selector(addgroupuser:) forControlEvents:UIControlEventTouchUpInside];
            tempcell.addgroupuser.enabled=true;
            isCreatByOwn=true;
            if (![self.from.isCreatMe isEqualToString:@"1"]) {
                
                  [tempcell.addgroupuser setTitle:NSLocalizedString(@"lbgsvquit", nil) forState:UIControlStateNormal];
                  [tempcell.addgroupuser setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [tempcell.addgroupuser setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
                isCreatByOwn=false;
            }else{
                 [tempcell.addgroupuser setTitle:NSLocalizedString(@"lbgsvadd", nil) forState:UIControlStateNormal];
                [tempcell.addgroupuser setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [tempcell.addgroupuser setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
            }
            

            tempcell.selectionStyle = UITableViewCellSelectionStyleNone;
            return tempcell;
            
        }else{
            
            
            GroupUserTableViewCell * tempcell=[tableView dequeueReusableCellWithIdentifier:@"cell_GroupUser"];
            if (tempcell == nil)
            {
                tempcell = [[GroupUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:@"cell_GroupUser"];
                
                if ([tempcell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [tempcell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
                }
                
                if ([tempcell respondsToSelector:@selector(setLayoutMargins:)]) {
                    [tempcell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
                }
            }
            
            OneRoomUser *tempuser=[oneRoomUser objectAtIndex:[indexPath row]];
           
            if ([myjidstr isEqualToString:tempuser.userjidstr]) {
                tempcell.username.text=NSLocalizedString(@"lbgsvyou", nil) ;
                  NSString * imagename=[[NSUserDefaults standardUserDefaults] objectForKey:XMPPMYFACE];
                tempuser.faceurl=imagename;
                
            }else{
                
                tempcell.username.text=tempuser.localname?tempuser.localname:[[tempuser.userjidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
            }
;
            if ([tempuser.role isEqualToString:@"1"]) {//[self.from.isCreatMe isEqualToString:@"1"]
                
                tempcell.userrole.text=NSLocalizedString(@"lbgsvadmin", nil);
            }else{
                tempcell.userrole.text=@"";
            }
            
            UIImage * tempimg=[UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:tempuser.faceurl]];
            
            NSString *path=[Tool Append:IMReasonableAPPImagePath witnstring:tempuser.faceurl];
            [tempcell.userface sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:tempimg?tempimg:[UIImage imageNamed:@"default"]];

            
    
            tempcell.selectionStyle = UITableViewCellSelectionStyleNone;
            return  tempcell;
        }
    
        
    
    }
    
        
        
   
    
    
    return cell;
    
    
}
//设置每个section的高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section]==0 && [indexPath row]==0) {
       return 70;
        
    }else{
        return 44;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (isCreatByOwn&&[indexPath section]==1 && [indexPath row]!=oneRoomUser.count)
    {
        [self showAction:[indexPath row]];
    
    }

}

-(void)switchAction:(UISwitch*)sender{

    NSString * vaule=sender.isOn?@"1":@"0";
    [IMReasonableDao setUserNeedTips:self.from.jidstr vaule:vaule];
    [XMPPDao GetAllRoom];
    //[Tool alert:vaule];
}

-(void)showAction:(NSUInteger)tag
{
    OneRoomUser *tempuser=[oneRoomUser objectAtIndex:tag];
    UIActionSheet * sheet;
    if (![tempuser.role isEqualToString:@"1"]) {
        NSString * username=tempuser.localname?tempuser.localname:[[tempuser.userjidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
        
        NSString * movemsg=[NSString stringWithFormat:NSLocalizedString(@"lbgsvmoveout", nil),username];
        NSString * callmsg=[NSString stringWithFormat:NSLocalizedString(@"lbgsvcall", nil),username];
        NSString * messagemsg=[NSString stringWithFormat:NSLocalizedString(@"lbgsvmessage", nil),username];
        
          sheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"lbgsvcancel", nil) destructiveButtonTitle:movemsg otherButtonTitles:callmsg,messagemsg,nil];
     
        
    }else{
        sheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"lbgsvcancel", nil) destructiveButtonTitle:NSLocalizedString(@"lbgsvdestroy", nil) otherButtonTitles:nil];
    }
    sheet.tag=tag;
    sheet.actionSheetStyle=UIActionSheetStyleDefault;
    [sheet showInView:self.view];

}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
       OneRoomUser *tempuser=[oneRoomUser objectAtIndex:actionSheet.tag];
    switch (buttonIndex) {
        case 0:
        {


      
            if (![tempuser.role isEqualToString:@"1"]) {
                //把用户移除群
                if ([XMPPDao sharedXMPPManager].xmppStream.isConnected) {
                    [[XMPPDao sharedXMPPManager] SetOneLeave:self.from.jidstr leaveuser:tempuser.userjidstr iqid:@"AdminGetOut"];
                }else{
                    [Tool alert:NSLocalizedString(@"lbgsvmovefai", nil)];
                
                }
                
            }else{
                //把群销毁掉
                [[XMPPDao sharedXMPPManager] DestroyRoom:self.from.jidstr];
            
            }

            
            
        }break;
            
        case 1:
        {
            if (![tempuser.role isEqualToString:@"1"]) {
                NSString * phone= [[tempuser.userjidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
                NSString * phonestr=[NSString stringWithFormat:@"tel://%@",phone];
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonestr]];
             }
            
            
        }break;
            
        case 2:
        {
            
            [self goChats:tempuser];
            
            
        }break;
        
        default:
            break;
            
            
    }
    
    
}


- (void)goChats:(OneRoomUser *) user{
    
   IMChatListModle * temp=[[IMChatListModle alloc] init];
    temp.jidstr=user.userjidstr;
    temp.faceurl=user.faceurl;
    temp.localname=user.localname;
    temp.isRoom=@"0";
    ChatViewController *Cannotview=[[ChatViewController alloc] init];
    Cannotview.isNeedCustom=YES;
    Cannotview.from=temp;
   [self.navigationController pushViewController:Cannotview animated:NO];
}

- (void) deleteRoomUser:(NSInteger)state userjidstr:(NSString *)userjidstr
{
    if (state==301) {//删除成员成功 删除本地数据，服务数据，刷新界面
         [Tool alert:NSLocalizedString(@"lbgsvmovesuc", nil)];
        if (![self.from.isCreatMe isEqualToString:@"1"]){//删除
            //自己退群 就需要把群删除 （为了和what'app一样 现在做的就是把群标记为不可用）
           // [IMReasonableDao deleteUser:self.from.jidstr]; //
           [IMReasonableDao setNotinRoom:self.from.jidstr];
            MainViewController * main=[[MainViewController alloc] init];
            [self presentViewController:main animated:YES completion:nil];
            
        }else{
            //删除本地数据
            [IMReasonableDao deleteRoomUser:self.from.jidstr userjidstr:userjidstr];
        }
       
      
        [self initData];
    }else{
        //[Tool alert:NSLocalizedString(@"lbgsvmovefai", nil)];
    
    }

}

-(void)deleteRoom:(NSInteger)action
{
    if(action==0||action==2){//==0 是群主销毁群 ==2 是自己主动退群
        MainViewController * main=[[MainViewController alloc] init];
        [self presentViewController:main animated:YES completion:nil];
    }else{ //==1 群管理员把用户剔除
        [self initData];
    }
  
}
-(void)addgroupuser:(UIButton *)btn
{
    if (![self.from.isCreatMe isEqualToString:@"1"]){//删除
        
        // NSString * myjidstr=[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
        
        [[XMPPDao sharedXMPPManager] SetOneLeave:self.from.jidstr leaveuser:myjidstr iqid:@"UserLeave"];
         //[[XMPPDao sharedXMPPManager] SetOneLeave:self.from.jidstr leaveuser:myjidstr iqid:@"UserLeave"];
    }else{
        //SelectUserViewController * selectview=[[SelectUserViewController alloc] init];
        SelectUserViewController *selectview = [[SelectUserViewController alloc]initWithNibName:@"SelectUserViewController" bundle:nil];

        selectview.isAddGroupUser=YES;
        selectview.from=self.from;
        UINavigationController * nvisecond=[[UINavigationController alloc] init];
        [nvisecond addChildViewController:selectview];
        [self presentViewController:nvisecond animated:YES completion:nil];

    }
    
    
}
-(void)changeFace:(UIButton *)btn
{
    //[Tool alert:@"换头像"];
}

-(void)viewDidLayoutSubviews
{
    //去除分割线左边出现的空格
    if ([tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableview setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    
    NSString * nickname=NSLocalizedString(@"lbgauyou", nil);//@"您,";
    int i=0;
    for (OneRoomUser * temp in oneRoomUser) {
        if (i<4 && temp.localname && ![temp.localname isEqualToString:NSLocalizedString(@"lbgauyou", nil)]) {
            nickname =[nickname stringByAppendingString:[NSString stringWithFormat:@"%@,",temp.localname]];
            i++;
        }
        
        if (i>4) {
            break;
        }
    }
    nickname=  [nickname substringToIndex:nickname.length-1];
    
    [IMReasonableDao updateRoomLocalname:self.from.jidstr nickname:nickname];
    
    
}

- (void)dealloc
{
   // [self unregisterCallback];
   // [[NSNotificationCenter defaultCenter] removeObserver:self];//AddGroupUser
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddGroupUser" object:nil];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
