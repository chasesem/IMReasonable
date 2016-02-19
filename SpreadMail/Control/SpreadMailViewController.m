//
//  SpreadMailViewController.m
//  IMReasonable
//
//  Created by apple on 15/9/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//



#define IDENTIFIER @"SpreadEmailPreviewCell"
#define CELL_HEIGHT 97//根据xib中视图的高度来定
#define EMAIL_COUNT 6
#define TABLEVIEW_COLOR @"#DEDEDE"

#import "PJNetWorkHelper.h"
#import "PJBaseHttpTool.h"
#import "EmailDetailViewController.h"
#import "SpreadMailModel.h"
#import "SpreadEmailPreviewCell.h"
#import "IMChatListModle.h"
#import "SpreadMailViewController.h"
#import "MailTableViewCell.h"
#import "IMReasonableDao.h"
#import "WeChatTableViewCell.h"
#import "Tool.h"
#import "DesHelper.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "UIColor+Hex.h"
#import "XMPPDao.h"

@interface SpreadMailViewController ()

@property(nonatomic,strong)UITableView *tableview;
//存放所有IMMessage(其中的body中包含邮件json)
@property(nonatomic,strong)NSMutableArray *emailArray;
//总页码
@property(nonatomic,assign)long totalCount;
//邮件的页码是否到头了
@property(nonatomic,assign)BOOL isEndOfEmail;
//分页
@property(nonatomic,assign)long pagerNumber;

@end

@implementation SpreadMailViewController

-(NSMutableArray *)emailArray{
    if(_emailArray==nil){
        
        _emailArray=[IMReasonableDao getEmailArray:JID WithPagerNumber:self.pagerNumber  AndCount:EMAIL_COUNT];
        if(_emailArray.count>0){
            
            _pagerNumber=[self getNextPagerNumber:_pagerNumber EmailCount:EMAIL_COUNT];
        }
    }
    return _emailArray;
}

-(long)pagerNumber{
    if(_pagerNumber<=0){
        
        _pagerNumber=[IMReasonableDao getEmailCount];
        self.totalCount=_pagerNumber;
        _pagerNumber=[self getNextPagerNumber:_pagerNumber EmailCount:EMAIL_COUNT];
    }
    return _pagerNumber;
}

-(long)getNextPagerNumber:(long)currentPagerNumber EmailCount:(long)emailCount{
    if(currentPagerNumber>0){
        
        long temp=currentPagerNumber-EMAIL_COUNT;
        if(temp<0){
            
            self.isEndOfEmail=true;
            return 0;
        }else{
            
            return temp;
        }
    }else if(currentPagerNumber==0&&!self.isEndOfEmail){
        
        self.isEndOfEmail=true;
        return 0;
    }else{
        
        return -1;
    }
}

#pragma mark--页面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    self.pagerNumber=0;
    [self initViewControl];
    [self initNavTitle];
    //设置邮件已读
    [self setMessageReaded];
    //设置代理
    [self setDelegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark-一些初始化操作

- (void)initNavTitle{

    self.navigationItem.title=NSLocalizedString(@"lbtspreadname",nil);
}

//初始化页面控件
- (void)initViewControl{
    _tableview =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableview.delegate=self;
    _tableview.dataSource=self;

    UINib * nib=[UINib  nibWithNibName:IDENTIFIER bundle:nil ];
    [_tableview registerNib:nib forCellReuseIdentifier:IDENTIFIER];
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //添加下拉刷新监听方法
    __block __weak typeof(self) tmpSelf = self;
    [_tableview addLegendHeaderWithRefreshingBlock:^(){
        [ tmpSelf LoadData];
    }];
    
    // 设置文字
    [_tableview.header setTitle:@"Pull down to refresh" forState:MJRefreshHeaderStateIdle];
    [_tableview.header setTitle:@"Release to refresh" forState:MJRefreshHeaderStatePulling];
    [_tableview.header setTitle:@"Loading ..." forState:MJRefreshHeaderStateRefreshing];
    _tableview.header.updatedTimeHidden = YES;
    
    // 设置字体
    _tableview.header.font = [UIFont systemFontOfSize:15];
    
    // 设置颜色
    _tableview.header.textColor = [UIColor grayColor];
    
    _tableview.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableview];
    _tableview.separatorStyle=UITableViewCellAccessoryNone;
    UIView *footerView=[[UIView alloc] init];
    footerView.backgroundColor=[UIColor colorWithHexString:TABLEVIEW_COLOR];
    _tableview.tableFooterView=footerView;
    _tableview.backgroundColor=[UIColor colorWithHexString:TABLEVIEW_COLOR];
    //滚到最后一页
    dispatch_async(dispatch_get_main_queue(), ^{
       [_tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.totalCount>EMAIL_COUNT?EMAIL_COUNT-1:self.totalCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

-(void)LoadData{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray *tempArray;
        if(_pagerNumber>=0){
            
            if(_pagerNumber==0){
                
                long temp=self.totalCount%EMAIL_COUNT;
                if(temp==0){
                    
                    temp=EMAIL_COUNT;
                    self.isEndOfEmail=true;
                }
               tempArray=[IMReasonableDao getEmailArray:JID WithPagerNumber:_pagerNumber  AndCount:temp];
            }else{
                tempArray=[IMReasonableDao getEmailArray:JID WithPagerNumber:_pagerNumber  AndCount:EMAIL_COUNT];
            }
            if(tempArray.count>0){
                
                NSIndexSet *indexSet=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempArray.count)];
                [self.emailArray insertObjects:tempArray atIndexes:indexSet];
                _pagerNumber=[self getNextPagerNumber:_pagerNumber EmailCount:EMAIL_COUNT];
                [self.tableview reloadData];
            }
        }
        [self.tableview.header endRefreshing];
    });
}

-(void)setDelegate{
    [XMPPDao sharedXMPPManager].chatHelerpDelegate = self;
}

//设置消息已读
- (void)setMessageReaded
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for(IMMessage *message in self.emailArray){
            [IMReasonableDao setMessageRead:message.from needactive:YES];
        }
    });
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}

//删除邮件
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle==UITableViewCellEditingStyleDelete){
        
        NSLog(@"%ld",(long)indexPath.row);
        if(indexPath.row<self.emailArray.count){
            
            //修复当删除最后一条邮件的时候返回聊天列表的时候邮件item消失
            if(indexPath.row==self.emailArray.count-1&&(indexPath.row-1)>=0){
                
                IMMessage *message=[self.emailArray objectAtIndex:indexPath.row-1];
                [IMReasonableDao updateEmailID:message.ID WithJID:message.from];
            }
            IMMessage *message=[self.emailArray objectAtIndex:indexPath.row];
            [self.emailArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            self.totalCount--;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [IMReasonableDao removeEmail:message.ID];
            });
        }
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
    if([PJNetWorkHelper isNetWorkAvailable]){
        
        EmailDetailViewController *emailDetailViewController=[[EmailDetailViewController alloc] init];
        emailDetailViewController.hidesBottomBarWhenPushed=YES;
        emailDetailViewController.model=((SpreadEmailPreviewCell *)[tableView cellForRowAtIndexPath:indexPath]).emailModel;
        [self.navigationController pushViewController:emailDetailViewController animated:YES];
    }else{
        
        [PJNetWorkHelper NoNetWork];
    }
}

#pragma mark--表格代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.emailArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    IMMessage *message=[self.emailArray objectAtIndex:indexPath.row];
    SpreadEmailPreviewCell *cell=[SpreadEmailPreviewCell cellWithTableView:tableView];
    cell.message=message;
    cell.backgroundColor=[UIColor colorWithHexString:TABLEVIEW_COLOR];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return CELL_HEIGHT;
}

//收到邮件消息代理回调方法
-(void)receiveNewMessage:(IMMessage *)message isFwd:(BOOL)isfwd{
    //时间设置成今天，昨天等等
    message.date=[Tool getDisplayTime:message.date];
    [self.emailArray addObject:message];
    NSString *emailJson=message.body;
//    SpreadMailModel *model=[SpreadMailModel mj_objectWithKeyValues:[emailJson stringByReplacingOccurrencesOfString:@"'" withString:@"\""]];
    [self.tableview reloadData];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [IMReasonableDao setMessageRead:message.from needactive:YES];
    });
}

-(void)userStatusChange:(XMPPPresence *)presence{
    
}

@end
