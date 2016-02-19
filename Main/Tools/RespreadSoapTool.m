//
//  RespreadSoapTool.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/11/25.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "PJBaseHttpTool.h"
#import "RespreadSoapTool.h"

@implementation RespreadSoapTool
+(void)Soap:(NSString *)url WithParam:(id)param success:(void(^)(id))success failure:(void(^)(NSError *))faillure{
    [PJBaseHttpTool Soap:url WithParam:param success:^(id responseObject) {
        if(success){
            
            success(responseObject);
        }
    } failure:^(NSError * error) {
        if(faillure){
            
            faillure(error);
        }
    }];
}
@end
