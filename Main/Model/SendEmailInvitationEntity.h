//
//  SendEmailInvitationEntity.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/15.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendEmailInvitationEntity : NSObject
@property(nonatomic,copy)NSString *LoginEmail;
@property(nonatomic,copy)NSString *Password;
@property(nonatomic,copy)NSString *From;
@property(nonatomic,copy)NSString *FromName;
@property(nonatomic,copy)NSString *To;
@property(nonatomic,copy)NSString *Subject;
@property(nonatomic,copy)NSString *Body;
@end
