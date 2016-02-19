//
//  PJBaseHttpTool.h
//  飘金笑话
//
//  Created by piaojin on 15/8/6.
//  Copyright (c) 2015年 piaojin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJBaseHttpTool : NSObject

+(void)Post:(NSString *)url WithParam:(id)param success:(void (^)(id))success failure:(void (^)(NSError *))failure;
+(void)PostWithJson:(NSString *)url WithParam:(id)param success:(void (^)(id))success failure:(void (^)(NSError *))failure;
+(void)Soap:(NSString *)url WithParam:(id)param success:(void(^)(id))success failure:(void(^)(NSError *))faillure;
@end
