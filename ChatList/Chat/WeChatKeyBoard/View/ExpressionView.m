//
//  ExpressionView.m
//  Alliance
//
//  Created by apple on 14-10-16.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "ExpressionView.h"

@implementation ExpressionView




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
    }
       // [self initData];
       // [self initControl];
    return self;
}



-(void)loadFacialView:(int)page size:(CGSize)size data:(NSArray *) data;
{
    
    
    for (int x=0; x<3; x++) {
        
        for (int y=0; y<7; y++) {
            
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            int index=x*7+y+(page*21);
            NSString * imagename=[data objectAtIndex:index];
            CGFloat bx=0+y*size.width;
            CGFloat by=0+x*size.height;
            [button setFrame:CGRectMake(bx, by, size.width, size.height)];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",imagename]] forState:UIControlStateNormal];
            button.tag=index;
            [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            
        }
        
    }

    
    
}


-(void)selected:(UIButton*)btn
{
    [self.delegate selectedExpression:btn.tag];
}



@end
