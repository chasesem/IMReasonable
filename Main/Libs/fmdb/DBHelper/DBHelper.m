//
//  DBHelper.m
//  IMReasonable
//
//  Created by apple on 14/12/23.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "DBHelper.h"

@implementation DBHelper
+(FMDatabaseQueue *)getSharedInstance
{
    static FMDatabaseQueue *db=nil;
    @synchronized(self){
        
            if (!db) {
        
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString * fullPathToFile= [documentsDirectory stringByAppendingPathComponent:@"IMReasonable.sp"];
                    db = [FMDatabaseQueue databaseQueueWithPath:fullPathToFile];
            }
        
    }

    return db;
}
@end
