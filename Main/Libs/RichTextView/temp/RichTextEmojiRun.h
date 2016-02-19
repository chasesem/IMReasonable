//
//  RichTextEmojiRun.h
//  IMReasonable
//
//  Created by apple on 14/11/13.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RichTextImageRun.h"

@interface RichTextEmojiRun : RichTextImageRun

+ (NSString *)analyzeText:(NSString *)string runsArray:(NSMutableArray **)runArray;

@end
