//
//  DBHelper.h
//  IMReasonable
//
//  Created by apple on 14/12/23.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"

@interface DBHelper : NSObject
+(FMDatabaseQueue *)getSharedInstance;
@end
