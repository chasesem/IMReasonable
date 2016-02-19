//
//  SetterViewController.m
//  IMReasonable
//
//  Created by apple on 15/6/17.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//


#import "SettingViewController.h"

#import "IMReasonableDao.h"
#import "SetterViewController.h"
#import "XMPPDao.h"
#import "ThirdViewController.h"
#import "WallPaperViewController.h"
#import "UIColor+Hex.h"
#import "FirstViewController.h"
#import "AppDelegate.H"

#define CLEAR 0//确定清除数据

#define FOOTERVIEW_HEIGTH 44

@interface SetterViewController ()
{
    
    UITableView * _tableview;
    
    NSMutableArray *_datalist;

}

@property(nonatomic,copy)NSString *docSize;

@end

@implementation SetterViewController

-(NSString *)docSize{
    if(!_docSize){
        
        [self updateCache];
    }
    return _docSize;
}

- (void)viewDidLoad {
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadtableview)
                                                 name:@"NETCHANGE"
                                               object:nil];
    

    [super viewDidLoad];
    [self initViewControl];
    [self initNav];
    [self initData];
  
}

- (void)reloadtableview{
    [_tableview reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableview reloadData];
}

- (void)initNav{
  self.navigationItem.title=NSLocalizedString(@"lbsetter",nil);
}


- (void)initData{
 
    NSArray * section5=[[NSArray alloc] initWithObjects:@"SETTING", nil];
    NSArray * section0=[[NSArray alloc] initWithObjects:@"CLEAR_DATA", nil];
    NSArray * section1=[[NSArray alloc] initWithObjects:@"lbsabout", nil];
    NSArray * section2=[[NSArray alloc] initWithObjects:@"lbsprofile", @"lbwallpaper",nil];
    NSArray * section3=[[NSArray alloc] initWithObjects:@"lbsnetstate", nil];
    NSArray * section4=[[NSArray alloc] initWithObjects:@"lbsusage", nil];
    _datalist=[[NSMutableArray alloc] initWithObjects:section1,section2,section3,section4, section0,section5,nil];

}

- (void)initViewControl{

    self.edgesForExtendedLayout = UIRectEdgeNone ;
    _tableview =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIHEIGHT)];
    _tableview.delegate=self;
    _tableview.dataSource=self;
    //退出按钮
    UIButton *footerButton=[[UIButton alloc] init];
    footerButton.titleLabel.font=[UIFont systemFontOfSize:20.0];
    [footerButton setTitle:NSLocalizedString(@"SIGN_OUT", nil) forState:UIControlStateNormal];
    footerButton.frame=CGRectMake(0, 0, 0, FOOTERVIEW_HEIGTH);
    [footerButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchDown];
    [footerButton setBackgroundImage:[UIImage imageNamed:@"red_1"] forState:UIControlStateNormal];
    [footerButton setBackgroundImage:[UIImage imageNamed:@"red_2"] forState:UIControlStateHighlighted];
    _tableview.tableFooterView = footerButton;

    _tableview.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableview];
}

//退出登录
-(void)logout:(UIButton *)button{
    FirstViewController* firstViewController=[[FirstViewController alloc] init];
    [self presentViewController:firstViewController animated:YES completion:nil];
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        //清除用户数据
        NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
        //设置退出登录为真
        [userDefaults setBool:true forKey:ISSIGN_OUT];
        //清除手机号码和密码
        [userDefaults removeObjectForKey:XMPPREASONABLEJID];
        [userDefaults removeObjectForKey:XMPPREASONABLEPWD];
        [userDefaults setBool:false forKey:@"FIRSTLOGIN"];
        [userDefaults synchronize];
        //发出下线通知
        [[XMPPDao sharedXMPPManager] disconnect];
        [[XMPPDao sharedXMPPManager] goOffline];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _datalist.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_datalist objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * Idetify=@"asd";
    
    NSArray * data=[_datalist objectAtIndex:[indexPath section]];
    
    UITableViewCell *cell;
    NSInteger section=[indexPath section];
    if (section<2) {
        cell= [tableView dequeueReusableCellWithIdentifier:Idetify];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Idetify];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
    }else if(section==2){
        cell= [tableView dequeueReusableCellWithIdentifier:@"NETWORK"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NETWORK"];
        }
        if ([XMPPDao sharedXMPPManager].isConnectInternet) {
            cell.detailTextLabel.text=NSLocalizedString(@"lbsnetstateconnect",nil);
             cell.detailTextLabel.textColor=[UIColor greenColor];
        }else{
           cell.detailTextLabel.text=NSLocalizedString(@"lbsnetstatedisconnect",nil);
           cell.detailTextLabel.textColor=[UIColor redColor];
        }
    }else{
        
        cell= [tableView dequeueReusableCellWithIdentifier:@"NETWORK"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NETWORK"];
        }
        
        
        if(indexPath.section==3){
            
            cell.detailTextLabel.text=self.docSize<=0?NSLocalizedString(@"COUNTING", nil):self.docSize;
        }else{
            
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
    }
   
     cell.selectionStyle=UITableViewCellAccessoryNone;
    cell.textLabel.text=NSLocalizedString([data objectAtIndex:[indexPath row]],nil);
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
    
}

//删除缓存
-(void)deleteCache{
    __block __weak typeof(self) piaojin = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       [Tool removeVoiceAndImg];
        dispatch_async(dispatch_get_main_queue(), ^{
            [piaojin updateCache];
        });
    });
}

-(void)ClearAlert{
    if(iOS(8)){
        
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"lbttitle",nil)
                                                                                 message:NSLocalizedString(@"CLEAR_PROMPT",nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"btnDone",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
                [self deleteCache];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"lbTCancle",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        
        UIAlertView* myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"lbttitle",nil) message:NSLocalizedString(@"CLEAR_PROMPT",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"btnDone",nil) otherButtonTitles:NSLocalizedString(@"lbTCancle",nil), nil];
        [myAlertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex==CLEAR){
        
        [self deleteCache];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSInteger section=[indexPath section];
    if (section==0) {
        
        NSString * ver=[NSString stringWithFormat:@"V %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        [Tool alert:ver];
        
    } else if (section==1){
        
        if (indexPath.row==0) {
            ThirdViewController *firstview = [[ThirdViewController alloc]initWithNibName:@"ThirdViewController" bundle:nil];
            firstview.isSetting=true;
            firstview.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:firstview animated:YES];
        }else {
            WallPaperViewController * wallpaper=[[WallPaperViewController alloc] init];
               wallpaper.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:wallpaper animated:YES];
        }
       
    }
    //清除数据
    else if(section==4){
        
        [self ClearAlert];
    }
    
    //设置
    else if(section==5){
        
        SettingViewController *setting=[[SettingViewController alloc] init];
        setting.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:setting animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//获取缓存的大小
-(void)updateCache{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _docSize =[Tool getDocSize];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *index=[NSIndexPath indexPathForRow:0 inSection:3];
            ((UITableViewCell *)[_tableview cellForRowAtIndexPath:index]).detailTextLabel.text=_docSize;
        });
    });
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//cell加载时的动画效果
- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.openAnimation) {

        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        [UIView animateWithDuration:0.5 animations:^{
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }];
    }
}

@end
