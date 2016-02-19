//
//  DetailKeyBoard.h
//  KeyBoard
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpressionView.h"
@protocol DetailKeyBoardDelegate;

@interface DetailKeyBoard : UIView<UIScrollViewDelegate,ExpressionViewDelegate>

@property (nonatomic,weak) id<DetailKeyBoardDelegate> detailKeyBoardDelegate;

- (void) ChoiceViewShow:(NSInteger) viewIndex;

@end


//键盘协议
@protocol DetailKeyBoardDelegate <NSObject>

@optional   //加上该字段意味着不实现代理方法也不会报警告
- (void) EmojiImageClick:(NSString *)emgname;
@optional
- (void) MoreFunctionChoice:(NSUInteger) funid;

@end
