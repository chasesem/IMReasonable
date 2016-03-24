//
//  EmailSettingViewController.m
//  IMReasonable
//
//  Created by apple on 16/3/18.
//  Copyright © 2016年 Reasonable. All rights reserved.
//

#import "EmailSettingViewController.h"
#import "SettingHeaderView.h"
#import "IMReasonableDao.h"
#import "XMPPDao.h"
@interface EmailSettingViewController ()
@property(nonatomic,strong)UITableView *tableview;

@end

@implementation EmailSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.backgroundColor = [UIColor colorWithRed:239 green:239 blue:243 alpha:0];
    
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated{
    [[self tableView] reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initViewControl{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    if (indexPath.section == 0) {
        
         //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        //UILabel *funcintroLabel = [[UILabel alloc] initwith];
        cell.textLabel.text = @"功能介绍";
        cell.detailTextLabel.text = @"我能及时通知你有新邮件到达，还可以直接查阅及回复邮件。";
        UIFont *newFont = [UIFont fontWithName:@"Arial" size:13.0];
        UIFont *titleFont = [UIFont fontWithName:@"Arial" size:16.0];
        //创建完字体格式之后就告诉cell
        cell.textLabel.font = newFont;
        cell.detailTextLabel.font = newFont;
         cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    }
    if(indexPath.section == 1){
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.textLabel.text = @"查看邮件";
    }
    if(indexPath.section ==2){
        cell.textLabel.text = @"写邮件";
    }
    if(indexPath.section ==3){
        if(indexPath.row == 0){
            cell.textLabel.text = @"接收邮件提醒";
            UISwitch *mailNotice = [[UISwitch alloc] init];
            Boolean mailNoticeBool = [[NSUserDefaults standardUserDefaults] boolForKey:@"mailNotice"];
            mailNotice.frame = CGRectMake(0, SCREENWIDTH-60, 30, 50);
            [mailNotice addTarget:self action:@selector(changeNotice:) forControlEvents:UIControlEventValueChanged];
            NSLog(@"%@",mailNoticeBool?@"Yes":@"NO");
            if(mailNoticeBool){
                [mailNotice setOn:YES];
            }else{
                [mailNotice setOn:NO];
            }
            cell.accessoryView = mailNotice;
        }else{
            cell.textLabel.text = @"设置提醒文件夹";
        }
    }
    if(indexPath.section ==4){
        cell.textLabel.text = @"清空此功能消息记录";
    }
    if(indexPath.section ==5){
        UILabel *stopButton = [[UILabel alloc]init];
        stopButton.text = @"停用";
        stopButton.textAlignment = NSTextAlignmentCenter;
        cell.backgroundColor = [UIColor redColor];
        stopButton.textColor = [UIColor whiteColor];
        stopButton.frame = CGRectMake(SCREENWIDTH/2 - 25,10, 50, 20);
        [cell addSubview:stopButton];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if(section == 1){
        return 1;
    }else if(section == 2){
        return 1;
    }else if(section == 3){
        return 2;
    }else{
        return 1;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 50;
    }
    else{
        return 40;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 110;
    }
    else{
        return 25;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==0 ){
        UIView *headerView = [[SettingHeaderView alloc] init];
        //NSLog(@"%@~~~~~~~~~~",headerView.subviews);
        //self.tableView.tableHeaderView=headerView;
        UIImageView *mailIcon = [[UIImageView alloc] init];
        UILabel *mailName = [[UILabel alloc] init];
        UILabel *mailState = [[UILabel alloc] init];
        mailName.text = @"电子邮件提醒";
        mailName.frame = CGRectMake(90, 10, 200, 30);
        mailState.text = @"已启用";
        mailState.frame = CGRectMake(90, 40, 100, 30);
        mailState.textColor = [UIColor greenColor];
        mailIcon.image = [UIImage imageNamed:@"email_100px.png"];
        mailIcon.frame = CGRectMake(10, 10, 60, 60);
        [headerView addSubview:mailIcon];
        [headerView addSubview:mailName];
        [headerView addSubview:mailState];
        return headerView;
    }
    return nil;
}

- (void) changeNotice:(UISwitch*)sender{
    NSString * vaule=sender.isOn?@"1":@"0";
    NSLog(@"%@",vaule);
    if ([vaule  isEqual: @"1"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"mailNotice"];
    }else{
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"mailNotice"];
    }
    
    [IMReasonableDao setUserNeedTips:self.from.jidstr vaule:vaule];
    [XMPPDao GetAllRoom];
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


