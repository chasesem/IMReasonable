//
//  RichTextURLRun.h
//  IMReasonable
//
//  Created by apple on 14/11/13.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RichTextBaseRun.h"

@interface RichTextURLRun : RichTextBaseRun

+ (NSString *)analyzeText:(NSString *)string runsArray:(NSMutableArray **)array;

@end
