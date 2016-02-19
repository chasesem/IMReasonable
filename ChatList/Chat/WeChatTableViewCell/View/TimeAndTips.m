//
//  TimeAndTips.m
//  KeyBoard
//
//  Created by apple on 15/6/1.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "TimeAndTips.h"

#define TIMEANDTIPSFONTSIZE  12
#define _ScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define _ScreenHeight  [[UIScreen mainScreen] bounds].size.height

@implementation TimeAndTips{

    UILabel * timeAndTips;
}

-(instancetype)init:(NSString *)timeandtipsconnect{
    self=[super init];
    if (self) {
        
        self.layer.cornerRadius=5;
        self.layer.masksToBounds=YES;
        self.backgroundColor=[UIColor lightGrayColor];
        
        timeAndTips=[[UILabel alloc]initWithFrame:self.frame];
        timeAndTips.backgroundColor=[UIColor clearColor];
        timeAndTips.textAlignment=NSTextAlignmentCenter;
        timeAndTips.textColor=[UIColor grayColor];
        timeAndTips.font=[UIFont systemFontOfSize:TIMEANDTIPSFONTSIZE];
        
        
        
        [self addSubview:timeAndTips];
        
    }
    
    return self;
}

- (void)setTimeAndTipsConnect:(NSString *)timeAndTipsConnect{
//    CGSize timeSize = [self.timeAndTipsConnect sizeWithFont:timeAndTips.font constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByWordWrapping];
//    
//    Rect  rect=CGRectMake((_ScreenWidth-timeSize.width)/2, self.frame.origin.y, timeSize.width, timeSize.height);
//    self.frame=;
}


@end
