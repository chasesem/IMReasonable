//
//  RichTextBaseRun.m
//  IMReasonable
//
//  Created by apple on 14/11/13.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "RichTextBaseRun.h"

@implementation RichTextBaseRun
- (id)init
{
    self = [super init];
    if (self) {
        self.isResponseTouch = NO;
    }
    return self;
}

//-- 替换基础文本
- (void)replaceTextWithAttributedString:(NSMutableAttributedString*) attributedString
{
    [attributedString addAttribute:@"TQRichTextAttribute" value:self range:self.range];
}

//-- 绘制内容
- (BOOL)drawRunWithRect:(CGRect)rect
{
    return NO;
}

@end
