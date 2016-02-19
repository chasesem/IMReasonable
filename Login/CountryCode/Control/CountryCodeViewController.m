//
//  CountryCodeViewController.m
//  IMReasonable
//
//  Created by apple on 15/1/8.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "CountryCodeViewController.h"
#import "SelectCountryTableViewCell.h"
#import "FirstViewController.h"
#import "AppDelegate.h"


@interface CountryCodeViewController ()
{
    
    NSString *countru;
    NSMutableArray *allcountrycode;
    loginUserData * userdata;
    
    
}

@end

@implementation CountryCodeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initData];
    [self initControl];
    userdata=[self appDelegate].userdata;
    // Do any additional setup after loading the view from its nib.
}

- (void)initData{
     
    NSBundle * budle=[NSBundle mainBundle];
    NSString * path =[budle pathForResource:@"CountryList" ofType:@"plist"];
    allcountrycode=[[NSMutableArray alloc] initWithContentsOfFile:path];
    
}

- (void) initControl
{
    
    self.tableview.backgroundColor=[UIColor whiteColor];
    self.tableview.dataSource=self;
    self.tableview.delegate=(id)self;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self initNav];
}

- (void)initNav
{
    self.nav.title=NSLocalizedString(@"lbccvcountry",nil);//@"您的国家";
}
- (AppDelegate *)appDelegate
{
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate;
}
#pragma mark- 表格代理是需要实现的方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allcountrycode.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatListCell";
    
    SelectCountryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[SelectCountryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:CellIdentifier];
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
        }
    }   
    NSDictionary * dict=[allcountrycode objectAtIndex:[indexPath row]];
    cell.country.text =NSLocalizedString([dict objectForKey:@"Key"],nil);
    NSString *vaule=[dict objectForKey:@"Vaule"];
    NSString *Code=[dict objectForKey:@"Code"];
    cell.countrycode.text = [NSString stringWithFormat:@"+%@",vaule];
    if ([Code isEqualToString:userdata.countrySX]) {
        cell.isSelect.image=[UIImage imageNamed:@"selected.png"];
    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%ld",[indexPath row]);
    
    FirstViewController *firstview = [[FirstViewController alloc]initWithNibName:@"FirstViewController" bundle:nil];
    NSDictionary * dict=[allcountrycode objectAtIndex:[indexPath row]];
    
   [self appDelegate].userdata.countryname=NSLocalizedString([dict objectForKey:@"Key"],nil);
    NSString *vaule=[dict objectForKey:@"Vaule"];
    NSString *Code=[dict objectForKey:@"Code"];
    [self appDelegate].userdata.countrycode=vaule;
    [self appDelegate].userdata.countrySX=Code;

    
//    firstview.userdata=userdata;
   // firstview.userdata.countryname=NSLocalizedString([dict objectForKey:@"Key"],nil);
    // firstview.userdata.countrycode=vaule;
    
    [self presentViewController:firstview animated:YES completion:nil];
}

-(void)viewDidLayoutSubviews
{
    //去除分割线左边出现的空格
    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableview setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)disview:(id)sender {
    
   
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
