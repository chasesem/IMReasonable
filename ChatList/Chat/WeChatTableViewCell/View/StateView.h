//
//  StateView.h
//  KeyBoard
//
//  Created by apple on 15/6/1.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

@interface StateView : UIView
@property (nonatomic,retain) UIImageView * imagestate;
@property (nonatomic,retain) UILabel * time;

- (void)setStateviewData:(MessageModel*)message;
@end
