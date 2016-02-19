//
//  IMReasonableTests.m
//  IMReasonableTests
//
//  Created by apple on 14/11/20.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "PJBaseHttpTool.h"
#import "SpreadMailModel.h"
#import "SendEmailInvitationEntity.h"
#import "PJSendInviteHttpTool.h"
#import "MJExtension.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "IMReasonable.pch"

@interface IMReasonableTests : XCTestCase

@end

@implementation IMReasonableTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

NSInteger nickNameSort(id user1, id user2, void *context){
    NSString *u1,*u2;
    //类型转换
    u1 = (NSString*)user1;
    u2 = (NSString*)user2;
    return  [u1 localizedCompare:u2
             ];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
//    \"user_id\": \"10433\",
//    \"campaign_id\": \"84598\",
//    \"campaign_from\": \"testdddd\",
//    \"campaign_subject\": \"65789023o456hg!#@$%^@#$!#@%$$redhvabjfvuugbafo'i42536789asdfhgzxcvb\",
//    \"CampaignContent\": \"GroupBuyer  -  06.08.2012  如未能查看此電郵，請點擊此處  為保證您能順利收到我們發出的電郵，請您添加我們為你的常用聯絡人  關注我們  主頁&nbsp;  |  &nbsp\",
//    \"subscriber_email\": \"123456@qq.com\",
//    \"newsletterLinkUrl\": \"http://archive.rspread.com/10433-84598-55059173/.newsletter/web.aspx\",
//    \"home_phone\": \"8618566252453\"
    
//    {'user_id': '10433','campaign_id': '84598','campaign_from': 'testdddd','campaign_subject': '65789023o456hg!#@$%^@#$!#@%$$redhvabjfvuugbafo'i42536789asdfhgzxcvb','CampaignContent': 'GroupBuyer  -  06.08.2012  如未能查看此電郵，請點擊此處  為保證您能順利收到我們發出的電郵，請您添加我們為你的常用聯絡人  關注我們  主頁&nbsp;  |  &nbsp','subscriber_email': '123456@qq.com','newsletterLinkUrl': 'http://archive.rspread.com/10433-84598-55059173/.newsletter/web.aspx','home_phone': '8618566252453'}
//    NSString *string=@"{'user_id': '10433','campaign_id': '84598','campaign_from': 'testdddd','campaign_subject': '65789023o456hg!#@$%^@#$!#@%$$redhvabjfvuugbafoi42536789asdfhgzxcvb','CampaignContent': 'GroupBuyer  -  06.08.2012  如未能查看此電郵，請點擊此處  為保證您能順利收到我們發出的電郵，請您添加我們為你的常用聯絡人  關注我們  主頁&nbsp;  |  &nbsp','subscriber_email': '123456@qq.com','newsletterLinkUrl': 'http://archive.rspread.com/10433-84598-55059173/.newsletter/web.aspx','home_phone': '8618566252453'}";
//    string=[string stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
//    NSLog(@"%@",string);
//    NSDictionary *dictionary=[Tool JsonStrngToDictionary:string];
//    SpreadMailModel *emailModel=[SpreadMailModel mj_objectWithKeyValues:dictionary];
//    NSLog(@"%@",emailModel);
//    [IMReasonableDao getEmailArray:@""];
//    NSString *param=@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\"><soap12:Body><addSubscriberByInfo xmlns=\"http://service.reasonablespread.com/\"><loginEmail>804488815@qq.com</loginEmail><password>804488815</password><subscriberArgs><email>13666902838@163.com</email><firstName>firstName</firstName><middleName>middleName</middleName><lastName>lastName</lastName><jobTitle>string</jobTitle><company>string</company><homePhone>13666902838</homePhone><address1>string</address1><address2>string</address2><address3>string</address3><city>string</city><state>string</state><country>string</country><postalCode>string</postalCode><subPostalCode>string</subPostalCode><fax>string</fax><webUrl>string</webUrl><title>string</title><gender>string</gender><date1>%@</date1><date2>%@</date2><customField1>string</customField1><customField2>string</customField2><customField3>string</customField3><customField4>string</customField4><customField5>string</customField5><customField6>string</customField6><customField7>string</customField7><customField8>string</customField8><customField9>string</customField9><customField10>string</customField10><customField11>string</customField11><customField12>string</customField12><customField13>string</customField13><customField14>string</customField14><customField15>string</customField15></subscriberArgs><subscription>string</subscription><optInType>On</optInType></addSubscriberByInfo></soap12:Body></soap12:Envelope>";
//    NSDate *date=[NSDate date];
//    param=[NSString stringWithFormat:param,date,date];
//    [PJBaseHttpTool Soap:WSDL_URL WithParam:param success:^(id success){
//        NSLog(@"%@",success);
//    } failure:^(NSError * failure){
//        NSLog(@"%@",failure);
//    }];
    NSMutableArray *arr=[NSMutableArray array];
    [arr addObject:@"电脑"];
    [arr addObject:@"显示器"];
    [arr addObject:@"你好"];
    [arr addObject:@"推特"];
    [arr addObject:@"乔布斯"];
    [arr addObject:@"再见"];
    [arr addObject:@"暑假作业"];
    [arr addObject:@"键盘"];
    [arr addObject:@"鼠标"];
    [arr addObject:@"谷歌"];
    [arr addObject:@"苹果"];
    [arr addObject:@"l"];
    [arr addObject:@"a"];
    [arr addObject:@"l"];
    NSArray *sortArr = [arr sortedArrayUsingFunction:nickNameSort context:NULL];
    for(int i=0;i<sortArr.count;i++){
        
        NSLog(@"%@",sortArr[i]);
    }
    NSLog(@"piaojinxgz");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        
    }];
}

@end
