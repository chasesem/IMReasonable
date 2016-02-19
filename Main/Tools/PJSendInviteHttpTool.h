//
//  PJSendInviteHttpTool.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/13.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

@class SendEmailInvitationEntity;
#import <Foundation/Foundation.h>

@interface PJSendInviteHttpTool : NSObject
//发送邮件邀请
+(void)SendEmailInviteByPostWithParam:(SendEmailInvitationEntity *)param success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//发送短信邀请
+(void)SendInviteByPostWithParam:(NSDictionary *)param success:(void (^)(id))success failure:(void (^)(NSError *))failure;
@end
