//
//  PJSendInviteHttpTool.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/13.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "SendEmailInvitationEntity.h"
#import "PJSendInviteHttpTool.h"
#import "AFHTTPRequestOperationManager.h"
#import "PJBaseHttpTool.h"

#define APIKEY @"apikey"
#define OWNPHONE @"ownphone"//本机号码
#define USERARR @"userarr"//已经注册的用户(talking 用户)
#define SENDDATA @"senddata"
#define FORMATERROR @"参数格式不正确"
#define PARAMNULLERROR @"参数为空"
#define CODE -3//无意义
#define ERROR @"error"
/**
 *
 *  发送给服务器的数据：{senddata ={apikey = "24F2D104-703F-46A0-92DE-383C6C7FBC50";ownphone=8613720886489;userarr =({phone=8613666902838;});};}
 *
 *  服务器返回结果数据：{SendInvitationSMSResult={count = 0;userarr =(8613666902838);};}
 *
 *  @return <#return value description#>
 */

//发送邀请短信
@implementation PJSendInviteHttpTool

+(void)SendEmailInviteByPostWithParam:(SendEmailInvitationEntity *)param success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    if(param){
        
        NSString *params=[NSString stringWithFormat:SEND_EMAIL_INVITATION_PARAM,param.LoginEmail,param.Password,param.From,param.FromName,param.To,param.Subject,param.Body];
        NSLog(@"%@",params);
            [PJBaseHttpTool Post:SEND_EMAIL_INVITATION_URL WithParam:params success:^(id responseObject) {
                if(success){
                    
                    NSLog(@"responseObject:%@",responseObject);
                    success(responseObject);
                }
            } failure:^(NSError * error) {
                if(failure){
                    
                    failure(error);
                }
            }];
    }else{
        
        if(failure){
            
            failure([NSError errorWithDomain:PARAMNULLERROR code:CODE userInfo:[NSDictionary dictionaryWithObject:PARAMNULLERROR forKey:ERROR]]
                    );
        }
    }
}

+(void)SendInviteByPostWithParam:(NSDictionary *)param success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    if(param){
        
        NSArray * phonearray=[NSArray arrayWithObject:param];
        NSString* phone= [[[[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
        NSString * Apikey= IMReasonableAPPKey;
        NSDictionary *sendsms = [[NSDictionary alloc] initWithObjectsAndKeys:Apikey, APIKEY,phone,OWNPHONE,phonearray,USERARR, nil];
        NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:sendsms, SENDDATA, nil];
        NSLog(@"%@",parameters);
        if([NSJSONSerialization isValidJSONObject:parameters]){
            
            [PJBaseHttpTool PostWithJson:[Tool Append:IMReasonableAPP witnstring:@"SendInvitationSMS"] WithParam:parameters success:^(id responseObject) {
                if(success){
                    
                    NSLog(@"responseObject:%@",responseObject);
                    success(responseObject);
                }
            } failure:^(NSError * error) {
                if(failure){
                    
                    failure(error);
                }
            }];
        }else{
            
            if(failure){
                
                failure([NSError errorWithDomain:FORMATERROR code:CODE userInfo:[NSDictionary dictionaryWithObject:FORMATERROR forKey:ERROR]]
                        );
            }
        }
    }else{
        
        if(failure){
            
            failure([NSError errorWithDomain:PARAMNULLERROR code:CODE userInfo:[NSDictionary dictionaryWithObject:PARAMNULLERROR forKey:ERROR]]
                      );
        }
    }
}
@end
