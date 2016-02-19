//
//  RespreadSoapTool.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/11/25.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RespreadSoapTool : NSObject
+(void)Soap:(NSString *)url WithParam:(id)param success:(void(^)(id))success failure:(void(^)(NSError *))faillure;
@end
