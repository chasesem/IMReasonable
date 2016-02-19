//
//  RichTextView.h
//  IMReasonable
//
//  Created by apple on 14/11/13.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RichTextBaseRun.h"

@class RichTextView;

@protocol RichTextViewDelegate<NSObject>

@optional
- (void)richTextView:(RichTextView *)view touchBeginRun:(RichTextBaseRun *)run;
- (void)richTextView:(RichTextView *)view touchEndRun:(RichTextBaseRun *)run;

@end


@interface RichTextView : UIView


@property(nonatomic,copy)   NSString           *text;            // default is @""
@property(nonatomic,strong) UIFont             *font;            // default is [UIFont systemFontOfSize:12.0]
@property(nonatomic,strong) UIColor            *textColor;       // default is [UIColor blackColor]
@property(nonatomic)        float               lineSpacing;     // default is 1.5 行间距

//-- 特殊的文本数组。在绘制的时候绘制
@property(nonatomic,readonly)       NSMutableArray *richTextRunsArray;
//-- 特熟文本的绘图边界字典。用来做点击处理定位
@property(nonatomic,readonly)       NSMutableDictionary *richTextRunRectDic;
//-- 原文本通过解析后的文本
@property(nonatomic,readonly,copy)  NSString        *textAnalyzed;
@property  float     height;


@property(nonatomic,weak) id<RichTextViewDelegate> delegage;

@end
