//
//  BorderView.m
//  IMReasonable
//
//  Created by apple on 15/9/11.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "BorderView.h"

@implementation BorderView

/*
 Only override drawRect: if you perform custom drawing.
 An empty implementation adversely affects performance during animation.
 */


- (void)drawRect:(CGRect)rect {
    
    self.layer.cornerRadius = 10;//设置那个圆角的有多圆
    self.layer.borderWidth = 1;//设置边框的宽度，当然可以不要
    self.layer.borderColor = [[UIColor grayColor] CGColor];//设置边框的颜色
    self.layer.masksToBounds = YES;
   
}


@end
