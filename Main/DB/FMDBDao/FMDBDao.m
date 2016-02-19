//
//  FMDBDao.m
//  IMReasonable
//
//  Created by apple on 15/3/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "FMDBDao.h"




@implementation FMDBDao





+ (FMDatabaseQueue*)sharedFMDBManager
{
        FMDatabaseQueue *FMDBHelper;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString * jidstr=[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
        NSString * jidstrname=[[jidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
        NSString * fullPathToFile= [documentsDirectory  stringByAppendingFormat:@"/IMReasonable%@.sp",jidstrname];
        @synchronized(self){
            FMDBHelper = [FMDatabaseQueue databaseQueueWithPath:fullPathToFile];
        }

    return FMDBHelper;
}


+ (BOOL)executeUpdate:(NSString *)Sql
{
 
    __block BOOL flag=NO;
    if (!Sql) {
        return flag;
    }
 
      [[FMDBDao sharedFMDBManager] inDatabase:^(FMDatabase *db) {
            flag=[db executeUpdate:Sql];
        }];
        return flag;

}
+ (FMResultSet*)executeQuery:(NSString *)sql
{
    __block  FMResultSet *rs=nil;
        [[FMDBDao sharedFMDBManager] inDatabase:^(FMDatabase *db) {
            rs=[db executeQuery:sql];
        }];
    return rs;
}

//+(BOOL)executeUpdateWithinTransaction:(NSArray *)Sqlarr
//{
//    __block BOOL flag=NO;
//    if (!Sqlarr.count) {
//        return flag;
//    }
//    
////    [[FMDBDao sharedFMDBManager] inDatabase:^(FMDatabase *db) {
////        flag=[db executeUpdate:Sql];
////    }];
//    
//    [[FMDBDao sharedFMDBManager] inTransaction:^(FMDatabase *db, BOOL *rollback) {
//    
//    }];
//    return flag;
//}




@end

//
//@implementation FMDBDao
//{
//FMDatabaseQueue *FMDBHelper;
//}
//
//
//+ (FMDBDao*)sharedFMDBManager
//{
//    static FMDBDao *sharedFMDBManager=nil;
//    
//    static dispatch_once_t onceToken;
//   
//    dispatch_once(&onceToken, ^{
//        sharedFMDBManager=[[self alloc] init];
//    });
//    return sharedFMDBManager;
//}
//
//- (id)init
//{
//    self = [super init];
//    if(self){
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString * jidstr=[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
//        NSString * jidstrname=[[jidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
//        NSString * fullPathToFile= [documentsDirectory  stringByAppendingFormat:@"/IMReasonable%@.sp",jidstrname];
//        @synchronized(self){
//            FMDBHelper = [FMDatabaseQueue databaseQueueWithPath:fullPathToFile];
//        }
//        
//    }
//    return self;
//}
//- (BOOL)executeUpdate:(NSString *)Sql
//{
//    [FMDBDao sharedFMDBManager];
//    __block BOOL flag=NO;
//    if(FMDBHelper!=nil)
//      {
//          [FMDBHelper inDatabase:^(FMDatabase *db) {
//           flag=[db executeUpdate:Sql];
//          }];
//          return flag;
//      }else{
//          return  flag;
//      }
//}
//- (FMResultSet*)executeQuery:(NSString *)sql
//{
//    [FMDBDao sharedFMDBManager];
//    __block  FMResultSet *rs=nil;
//    if(FMDBHelper!=nil)
//    {
//      
//        [FMDBHelper inDatabase:^(FMDatabase *db) {
//           rs=[db executeQuery:sql];
//        }];
//    }
//    
//    return rs;
//}
//
//
//
//
//
//
//@end
