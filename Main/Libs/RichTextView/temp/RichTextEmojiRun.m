//
//  RichTextEmojiRun.m
//  IMReasonable
//
//  Created by apple on 14/11/13.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "RichTextEmojiRun.h"

@implementation RichTextEmojiRun
- (id)init
{
    self = [super init];
    if (self) {
        self.type = richTextEmojiRunType;
        self.isResponseTouch = NO;
    }
    return self;
}

- (BOOL)drawRunWithRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSString * tempimagename=self.originalText;
    tempimagename = [tempimagename stringByReplacingOccurrencesOfString:@"[" withString:@""];
    tempimagename = [tempimagename stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSString *emojiString = [NSString stringWithFormat:@"%@@2x.png",tempimagename];
    
    UIImage *image = [UIImage imageNamed:emojiString];
    if (image)
    {
        CGContextDrawImage(context, rect, image.CGImage);
    }
    return YES;
}

+ (NSArray *) emojiStringArray
{
    NSBundle * budle=[NSBundle mainBundle];
    NSString * path =[budle pathForResource:@"expressionImage_custom" ofType:@"plist"];
    NSDictionary * ds=[[NSDictionary alloc] initWithContentsOfFile:path];
    return [ds allKeys];
}
+ (NSArray *) emojinameArray
{
    NSBundle * budle=[NSBundle mainBundle];
    NSString * path =[budle pathForResource:@"expressionImage_custom" ofType:@"plist"];
    NSDictionary * ds=[[NSDictionary alloc] initWithContentsOfFile:path];
    return [ds allValues];
}

+ (NSString *)analyzeText:(NSString *)string runsArray:(NSMutableArray **)runArray
{
    NSString *markL = @"[";
    NSString *markR = @"]";
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    NSMutableString *newString = [[NSMutableString alloc] initWithCapacity:string.length];
    
    //偏移索引 由于会把长度大于1的字符串替换成一个空白字符。这里要记录每次的偏移了索引。以便简历下一次替换的正确索引
    int offsetIndex = 0;
    
    for (int i = 0; i < string.length; i++)
    {
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        
        if (([s isEqualToString:markL]) || ((stack.count > 0) && [stack[0] isEqualToString:markL]))
        {
            if (([s isEqualToString:markL]) && ((stack.count > 0) && [stack[0] isEqualToString:markL]))
            {
                for (NSString *c in stack)
                {
                    [newString appendString:c];
                }
                [stack removeAllObjects];
            }
            
            [stack addObject:s];
            
            if ([s isEqualToString:markR] || (i == string.length - 1))
            {
                NSMutableString *emojiStr = [[NSMutableString alloc] init];
                for (NSString *c in stack)
                {
                    [emojiStr appendString:c];
                }
                
                if ([[RichTextEmojiRun emojiStringArray] containsObject:emojiStr])
                {
                    RichTextEmojiRun *emoji = [[RichTextEmojiRun alloc] init];
                    emoji.range = NSMakeRange(i + 1 - emojiStr.length - offsetIndex, 1);
                    emoji.originalText = [[RichTextEmojiRun emojinameArray] objectAtIndex:[[RichTextEmojiRun emojiStringArray] indexOfObject:emojiStr]];
                    [*runArray addObject:emoji];
                    [newString appendString:@" "];
                    
                    offsetIndex += emojiStr.length - 1;
                }
                else
                {
                    [newString appendString:emojiStr];
                }
                
                [stack removeAllObjects];
            }
        }
        else
        {
            [newString appendString:s];
        }
    }
    
    return newString;
}

@end
