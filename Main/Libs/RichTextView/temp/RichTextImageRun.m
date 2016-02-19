//
//  RichTextImageRun.m
//  IMReasonable
//
//  Created by apple on 14/11/13.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "RichTextImageRun.h"
#import <CoreText/CoreText.h>

static const float kZoom = 1.1f;

@implementation RichTextImageRun

- (void)replaceTextWithAttributedString:(NSMutableAttributedString*) attString
{
    //删除替换的占位字符
    [attString deleteCharactersInRange:self.range];
    
    CTRunDelegateCallbacks emojiCallbacks;
    emojiCallbacks.version      = kCTRunDelegateVersion1;
    emojiCallbacks.dealloc      = RichTextRunEmojiDelegateDeallocCallback;
    emojiCallbacks.getAscent    = RichTextRunEmojiDelegateGetAscentCallback;
    emojiCallbacks.getDescent   = RichTextRunEmojiDelegateGetDescentCallback;
    emojiCallbacks.getWidth     = RichTextRunEmojiDelegateGetWidthCallback;
    
    NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];
    
    //
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&emojiCallbacks, (__bridge void*)self);
    [imageAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(0, 1)];
    CFRelease(runDelegate);
    
    [attString insertAttributedString:imageAttributedString atIndex:self.range.location];
    
    [super replaceTextWithAttributedString:attString];
}

#pragma mark - RunDelegateCallback

void RichTextRunEmojiDelegateDeallocCallback(void *refCon)
{
    
}

//--上行高度
CGFloat RichTextRunEmojiDelegateGetAscentCallback(void *refCon)
{
    RichTextImageRun *run =(__bridge RichTextImageRun *) refCon;
    return run.originalFont.ascender * kZoom;
}

//--下行高度
CGFloat RichTextRunEmojiDelegateGetDescentCallback(void *refCon)
{
    RichTextImageRun *run =(__bridge RichTextImageRun *) refCon;
    return run.originalFont.descender * kZoom;
}

//-- 宽
CGFloat RichTextRunEmojiDelegateGetWidthCallback(void *refCon)
{
    RichTextImageRun *run =(__bridge RichTextImageRun *) refCon;
    return (run.originalFont.ascender - run.originalFont.descender) * kZoom;
}



@end
