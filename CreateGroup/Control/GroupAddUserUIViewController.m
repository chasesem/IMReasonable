//
//  GroupAddUserUIViewController.m
//  IMReasonable
//
//  Created by apple on 15/3/19.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "GroupAddUserUIViewController.h"
#import "AddUserTableViewCell.h"
#import "SelectUserViewController.h"
#import "IMChatListModle.h"
#import "XMPPRoomDao.h"
#import "IMReasonableDao.h"
#import "AnimationHelper.h"
#import "ASIFormDataRequest.h"

@interface GroupAddUserUIViewController ()
{

    NSMutableArray * selectUser;
    NSString * _roomname;
}

@end

@implementation GroupAddUserUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNav];
    [self initControl];
    [XMPPRoomDao sharedXMPPManager].roomHelerpDelegate=self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initNav
{
    ////self.nav.title=@"创建群组";//NSLocalizedString(@"lbFphone", nil);
   // self.next.title=@"下一步";
    
//    "lbgauaddme"="添加成員";
//    "lbgaucreat"="創建";
    self.navigationItem.title=NSLocalizedString(@"lbgauaddme", nil);//@"添加成员";
    
    UIBarButtonItem * right=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"lbgaucreat", nil) style:(UIBarButtonItemStyleBordered) target:self action:@selector(CreatGroup:)];
     right.enabled=NO;
    if (selectUser && [selectUser count]) {
        right.enabled=YES;
    }
   
    self.navigationItem.rightBarButtonItem=right;

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initNav];
}

- (void) initControl
{
    
    self.tableview.backgroundColor=[UIColor whiteColor];
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (selectUser!=nil) {
        return [selectUser count]+1;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
        return 44;

    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    if ([indexPath row]==0)
    {

            AddUserTableViewCell *   tempcell =[[AddUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddUserTableViewCell"];
        tempcell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([tempcell respondsToSelector:@selector(setSeparatorInset:)]) {
            [tempcell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
        }
        
        if ([tempcell respondsToSelector:@selector(setLayoutMargins:)]) {
            [tempcell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
        }
        //lbgauadd
        [tempcell.adduser addTarget:self action:@selector(selectUser:) forControlEvents:UIControlEventTouchUpInside];
        [tempcell.adduser setTitle:NSLocalizedString(@"lbgauadd", nil) forState:UIControlStateNormal];
        [tempcell.adduser setTitle:NSLocalizedString(@"lbgauadd", nil) forState:UIControlStateHighlighted];
           // [tempcell.groupSelectPhoto addTarget:self action:@selector(SelectPhoto:) forControlEvents:UIControlEventTouchUpInside];
           // tempcell.groupphoto.tag=8;
            
            cell=tempcell;
            
    }else{
        
        static NSString *CellIdentifier = @"ChatListCell";
        
        UITableViewCell *tempcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (tempcell == nil)
        {
            tempcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:CellIdentifier];
            
            if ([tempcell respondsToSelector:@selector(setSeparatorInset:)]) {
                [tempcell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
            }
            
            if ([tempcell respondsToSelector:@selector(setLayoutMargins:)]) {
                [tempcell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
            }
        }
        IMChatListModle *temp=[selectUser objectAtIndex:[indexPath row]-1];
        tempcell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImage * tempimg=[UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:temp.faceurl]];
        tempimg=tempimg?tempimg:[UIImage imageNamed:@"default"];
        tempcell.imageView.image=[Tool imageCompressForSize:tempimg targetSize:CGSizeMake(40, 40)];//[UIImage imageNamed:temp.faceurl];
        tempcell.imageView.layer.masksToBounds = YES;
        tempcell.imageView.layer.cornerRadius = 20;
        tempcell.textLabel.text=[[temp.jidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
        tempcell.detailTextLabel.text=temp.localname;
        cell=tempcell;
    }
   
    return cell;
    
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
- (void)selectUser:(UIButton *)btn
{
   // SelectUserViewController * selectview=[[SelectUserViewController alloc] init];
    SelectUserViewController *selectview = [[SelectUserViewController alloc]initWithNibName:@"SelectUserViewController" bundle:nil];

    selectview.isGroup=true;
    selectview.tempsubject=self.subject;
    selectview.selectUserdelegate=self;
    UINavigationController * nvisecond=[[UINavigationController alloc] init];
    [nvisecond addChildViewController:selectview];
    //[self.navigationController pushViewController:nvisecond animated:YES];
    [self presentViewController:nvisecond animated:YES completion:nil];
    
}




#pragma mark-创建群组
- (void)CreatGroup:(UIBarButtonItem*)btn
{
    [AnimationHelper showHUD:NSLocalizedString(@"lbgaucreating", nil)];
    
     NSString * user=[[[[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEFULLJID] componentsSeparatedByString:@"@"] objectAtIndex:0];

    NSString * roomname=[NSString stringWithFormat:@"%@-%@",user,[Tool GetOnlyString]];//[Tool GetOnlyString];
    _roomname=roomname;
    [[XMPPRoomDao sharedXMPPManager] createRoom:roomname];
}

//NSMutableDictionary * confdict=[self parserConfigElement:configForm];
//
//NSMutableDictionary * newConfdict=[self getRoomConfig:confdict];
//
//NSLog(@"%@",[self DictToBSXMLElement:newConfdict]);
//
//[xmppRoom configureRoomUsingOptions:[self DictToBSXMLElement:newConfdict]];

-(void)GetRoomConfigForm:(NSMutableDictionary *)configform
{
    //收到配置表格的时候需要配置房间
     NSMutableDictionary * newConfdict=[[XMPPRoomDao sharedXMPPManager] getRoomConfig:configform user:selectUser subject:self.subject];
    [[XMPPRoomDao sharedXMPPManager].xmppRoom configureRoomUsingOptions:[[XMPPRoomDao sharedXMPPManager] DictToBSXMLElement:newConfdict]];
}

- (void) creatRoomResult:(int)state
{
    if(state==3){//配置成功
          NSString * roomjidstr=[NSString stringWithFormat:@"%@@muc.%@",_roomname,XMPPSERVER]; //房间的jidstr
          NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
          NSString * myphone= [[[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
          NSString * path=@"";
        
        
         [IMReasonableDao addRoomUser:roomjidstr userjidstr:myJID role:@"1"];
         [[XMPPRoomDao sharedXMPPManager] ChangeSubject:roomjidstr subject:self.subject];//暂时没什么意义
        
        NSMutableArray *userarr=[[NSMutableArray alloc] init];  //房间的用户
        
        int i=0;
        //"lbgauyou"="您,";
        NSString * nickname=NSLocalizedString(@"lbgauyou", nil);//@"您,";
        for (IMChatListModle * temp in selectUser) {
            if (i<4 && temp.localname) {
               nickname =[nickname stringByAppendingString:[NSString stringWithFormat:@"%@,",temp.localname]];
                i++;
            }
            if (temp.phonenumber) {//这样做是因为这个可能为空，对法发消息给自己 自己通讯录没有电话的用户，这个可以添加的时候截取直接添加到数据库而不需要这里判断
                  [userarr addObject:temp.phonenumber];
            }else{
                 NSString * phonejid= [[temp.jidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
                 [userarr addObject:phonejid];
            
            }
          
            
            [[XMPPRoomDao sharedXMPPManager] InviteUser:temp.jidstr subject:self.subject];//邀请好友加入群里
            [IMReasonableDao addRoomUser:roomjidstr userjidstr:temp.jidstr role:@"0"];//把人员添加到数据库
        }
        
        
        NSString * photourl=nil;
         photourl=[_roomname stringByAppendingString:@".png"];
         [IMReasonableDao creatChatRoom:roomjidstr nick:[nickname substringToIndex:nickname.length-1]subject:self.subject faceurl:photourl isMeCreat:@"1"];
        
        
        if (self.image) {
            photourl=[_roomname stringByAppendingString:@".png"];
            UIImage* tempimg=[Tool imageCompressForSize:self.image targetSize:CGSizeMake(self.image.size.width , self.image.size.height)];
            NSData *imageData = UIImageJPEGRepresentation(tempimg, 0.01);//UIImagePNGRepresentation(tempimg);
            [Tool saveFileToDoc:_roomname fileData:imageData];
            
            
            //上传头像到服务器
            NSString * datastring1=[Tool NSdatatoBSString:imageData];//压缩编码发送
            NSURL *url = [NSURL URLWithString:  [Tool Append:IMReasonableAPP witnstring:@"Upload"]];
            
          
            NSString * appendfilename=[Tool GetOnlyString];
            
            NSDictionary *usert = [[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"type",myphone,@"username",datastring1,@"base64Content",appendfilename ,@"filename",nil];
            NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:usert, @"file", nil];
            if ([NSJSONSerialization isValidJSONObject:user])
            {
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];
                NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
                [request addRequestHeader:@"Accept" value:@"application/json"];
                [request setRequestMethod:@"POST"];
                [request setPostBody:tempJsonData];
                
                [request startSynchronous ];
                error =[request error];
                if (error == nil ) {
                    NSData *responsedata=[request responseData];
                    NSDictionary * dict=[Tool jsontodate:responsedata];
                    path=[dict objectForKey:@"UploadFileResult"];
                }

                
            }

        }
        
      // IMReasonableDao updateRoomFaceurl: roomjidstr:<#(NSString *)#>
       
        [self setServerChatRoom:roomjidstr creatphone:myphone faceurl:path userlist:userarr];
        
        
        
        
        [AnimationHelper removeHUD];
        //[Tool alert:@"传教成功"];
        
        //跳转到主页面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGEITEM"
                                                            object:self];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else{//房间创建失败
        
        [AnimationHelper removeHUD];
        [Tool alert:NSLocalizedString(@"lbgaucreatfaild", nil)];
    }

}
-(BOOL)setServerChatRoom:(NSString *)roomjidstr  creatphone:(NSString *)myphone faceurl:(NSString *) faceurl userlist:(NSMutableArray *)userarr
{
    
   
    NSURL *url = [NSURL URLWithString:  [Tool Append:IMReasonableAPP witnstring:@"SetChatRoom"]];
      NSString * Apikey= IMReasonableAPPKey;
    NSDictionary *usert = [[NSDictionary alloc] initWithObjectsAndKeys:userarr , @"roomuser",roomjidstr,@"roomjidstr",myphone,@"creatphone",self.subject ,@"roomsubject",faceurl ,@"roomfaceurl",Apikey ,@"apikey",nil];
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:usert, @"roomdata", nil];
    if ([NSJSONSerialization isValidJSONObject:user])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];
        NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempJsonData];
        
        [request startSynchronous ];
        error =[request error];
        if (error == nil ) {
            NSData *responsedata=[request responseData];
            NSDictionary * dict=[Tool jsontodate:responsedata];
            NSString *  code=[dict objectForKey:@"SetChatRoomResult"];
            if ([code isEqualToString:@"1"]||[code isEqualToString:@"2"]) {
                return true;
            }
        }else{
            return false;
        }
        
        
    }
    
    return false;
    
}

-(void)SelectUserData:(NSMutableArray *)presence withsubject:(NSString *)subject
{
    selectUser=presence;
    self.subject=subject;
    [self.tableview reloadData];
}
@end
