//
//  SpreadMailModel.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/11/16.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpreadMailModel : NSObject

//用户的jid
@property(nonatomic,copy)NSString *user_id;
//邮件id
@property(nonatomic,copy)NSString *campaign_id;
//邮件发送者
@property(nonatomic,copy)NSString *campaign_from;
//邮件主题
@property(nonatomic,copy)NSString *campaign_subject;
//邮件内容
@property(nonatomic,copy)NSString *CampaignContent;
//
@property(nonatomic,copy)NSString *subscriber_email;
//邮件链接地址
@property(nonatomic,copy)NSString *newsletterLinkUrl;
//
@property(nonatomic,copy)NSString *home_phone;
@end
