//
//  SettingHeaderView.m
//  IMReasonable
//
//  Created by apple on 16/3/18.
//  Copyright © 2016年 Reasonable. All rights reserved.
//

#import "SettingHeaderView.h"

@implementation SettingHeaderView



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:243/255.0f alpha:0];
        //self.backgroundColor = [UIColor grayColor];
        self.mailPic.frame = CGRectMake(10, 10, 10, 10);
        self.mailPic.image = [UIImage imageNamed:@"email_100px.png"];
        self.mailName.text = @"电子邮箱";
        self.mailName.font = [UIFont fontWithName:@"Arial" size:13];
        self.mailName.textColor = [UIColor blackColor];
        self.mailName.frame = CGRectMake(140, 30, 50, 30);
      // [self addSubview:self.mailPic];
        //[self addSubview:self.mailName];
        self.frame = CGRectMake(0, 0, SCREENWIDTH, 50);
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
