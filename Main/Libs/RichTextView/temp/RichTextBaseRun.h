//
//  RichTextBaseRun.h
//  IMReasonable
//
//  Created by apple on 14/11/13.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

typedef enum richTextRunType
{
    //-- URL文本单元类型
    richTextURLRunType,
    //-- 表情文本单元类型
    richTextEmojiRunType,
    
}RichTextRunType;

@interface RichTextBaseRun : NSObject

//-- 文本单元类型
@property (nonatomic) RichTextRunType type;

//-- 原始文本
@property (nonatomic,copy) NSString *originalText;

//-- 原始字体
@property (nonatomic,strong) UIFont *originalFont;

//-- 文本所在位置
@property (nonatomic) NSRange range;

//-- 是否响应触摸
@property (nonatomic) BOOL isResponseTouch;

//-- 替换基本文本样式
- (void)replaceTextWithAttributedString:(NSMutableAttributedString*) attributedString;

//-- 绘制内容 (YES 表示这个函数自己绘制，NO表示CoreText绘制)
- (BOOL)drawRunWithRect:(CGRect)rect;

@end
