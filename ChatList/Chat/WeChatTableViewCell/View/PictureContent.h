//
//  PictureContent.h
//  KeyBoard
//
//  Created by apple on 15/6/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

@protocol PictureContentDelegate;

@interface PictureContent : UIView
@property (nonatomic,retain) UIImageView * backgroundImage;
@property (nonatomic,retain) MessageModel * messagemode;
@property (nonatomic,weak) id<PictureContentDelegate> delegate;
- (void)setMessagemode:(MessageModel *)messagemode isNeedName:(BOOL)isName;
@end
//消息内容的协议
@protocol PictureContentDelegate <NSObject>

@optional
- (void)touchPictureContent:(UIImageView*)imgV MessageModle:(MessageModel*) modle;


@end