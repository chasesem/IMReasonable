//
//  PJBaseHttpTool.m
//  飘金笑话
//
//  Created by piaojin on 15/8/6.
//  Copyright (c) 2015年 piaojin. All rights reserved.
//

#import "PJBaseHttpTool.h"
#import "AFHTTPRequestOperationManager.h"

@implementation PJBaseHttpTool

//application/x-www-form-urlencoded类型的post请求
+(void)Post:(NSString *)url WithParam:(id)param success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
    NSString *postparam=param;
    NSMutableData *postBody=[NSMutableData data];
    [postBody appendData:[postparam dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody=postBody;
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation hasAcceptableStatusCode: %ld  responseObject:%@", [operation.response statusCode],responseObject);
        if(success){
            
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(failure){
            
            failure(error);
        }
        if (error.code != NSURLErrorTimedOut) {
            NSLog(@"error: %@", error);
        }
    }];
    [operation start];
}

+(void)PostWithJson:(NSString *)url WithParam:(id)param success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if(responseObject){
                    
                    if(success){
                        
                        success(responseObject);
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if(failure){
                    
                    failure(error);
                }
            }];
}

+(void)Soap:(NSString *)url WithParam:(id)param success:(void(^)(id))success failure:(void(^)(NSError *))faillure{
    NSString *soapParam=(NSString *)param;
    NSString *soapParamLength=[NSString stringWithFormat:@"%lu",(unsigned long)[soapParam length]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:soapParamLength forHTTPHeaderField:@"Content-Length"];
    [manager.requestSerializer setValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Accept"];
    NSMutableURLRequest *request=[manager.requestSerializer requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    [request setHTTPBody:[soapParam dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(responseObject){
            
            if(success){
                
                success(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(faillure){
            
            faillure(error);
        }
    }];
    [manager.operationQueue addOperation:operation];
    
}

@end
