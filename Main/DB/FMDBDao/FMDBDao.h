//
//  FMDBDao.h
//  IMReasonable
//
//  Created by apple on 15/3/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface FMDBDao : NSObject

//+ (FMDatabaseQueue*)sharedFMDBManager;
+ (BOOL)executeUpdate:(NSString *)Sql;
+ (FMResultSet*)executeQuery:(NSString *)sql;
 

@end
