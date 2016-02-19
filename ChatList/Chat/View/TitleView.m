//
//  TitleView.m
//  IMReasonable
//
//  Created by apple on 15/1/4.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "TitleView.h"

@implementation TitleView
@synthesize  title;
@synthesize  subtitle;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame = frame;
        [self initControl];
    }
    return self;
}

-(void)initControl
{
    //主标题
    title=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    [title setTextColor:[UIColor blackColor]];
    [title setFont:[UIFont systemFontOfSize:17]];
    [title setTextAlignment:NSTextAlignmentCenter];
    
    //副标题
    subtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 30, self.frame.size.width, 14)];
    [subtitle setTextColor:[UIColor grayColor]];
    [subtitle setFont:[UIFont systemFontOfSize:11]];
    [subtitle setTextAlignment:NSTextAlignmentCenter];
    
    [self addSubview:title];
    [self addSubview:subtitle];

}

@end
