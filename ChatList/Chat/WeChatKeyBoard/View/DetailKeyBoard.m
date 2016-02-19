//
//  DetailKeyBoard.m
//  KeyBoard
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "DetailKeyBoard.h"
#define EMJViewIndex  0
#define MOREViewIndex  1
#define SOUNDViewIndex  2

#define _ScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define _ScreenHeight  [[UIScreen mainScreen] bounds].size.height
#define _ratioW (_ScreenWidth/320)
#define _ratioH (_ScreenHeight/ 480)


@implementation DetailKeyBoard

{
    
    UIView * MoreView;
    UIScrollView *scrollView;
   // UIView * SoundView;


    
    NSArray * expressionarr;
    NSArray * expressionKeyarr;
    
    int page;
    CGSize size;
    
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        

        
        CGRect bounds = [self bounds];
        
        scrollView=[[UIScrollView alloc] initWithFrame:bounds]; //表情盘
        scrollView.backgroundColor=[UIColor whiteColor];
        scrollView.tag=EMJViewIndex;
        scrollView.hidden=YES;
        scrollView.scrollEnabled=YES;
        
        
        MoreView=[[UIView alloc] initWithFrame:bounds];
        MoreView.backgroundColor=[UIColor whiteColor];
        MoreView.tag=MOREViewIndex;
        MoreView.hidden=YES;
        
//        SoundView=[[UIView alloc] initWithFrame:bounds];
//        SoundView.backgroundColor=[UIColor grayColor];
//        SoundView.tag=SOUNDViewIndex;
//        SoundView.hidden=YES;
        
        
        
        //获取表情数组并计算页数和每个表情的size
        NSBundle * budle=[NSBundle mainBundle];
        NSString * path =[budle pathForResource:@"expressionImage_custom" ofType:@"plist"];
        NSDictionary * ds=[[NSDictionary alloc] initWithContentsOfFile:path];
        expressionarr=[ds allValues];//[ds objectForKey:@"SysExpression"];
        expressionKeyarr=[ds allKeys];//[ds objectForKey:@"SysExpressionKey"];
        page=roundf(expressionarr.count/(3*7));
        size=CGSizeMake(bounds.size.width/7, 50);
        
        [self addSubview:MoreView];
        [self addSubview:scrollView];
       // [self addSubview:SoundView];
        
    }
    return self;
}

-(void)show:(UIButton *)btnn{
    NSLog(@"Fuck");
    
}

#pragma mark - Draw Rect
- (void)drawRect:(CGRect)rect
{
    //初始化表情键盘
    CGRect bounds = [self bounds];
    size=CGSizeMake(bounds.size.width/7, bounds.size.height/3);
    
    for (int i=0; i<page; i++) {
        ExpressionView  * expview=[[ExpressionView alloc]initWithFrame:CGRectMake(i*self.bounds.size.width, bounds.origin.y, bounds.size.width, bounds.size.height)];
        //expview.backgroundColor=[UIColor blueColor];
        expview.backgroundColor=[UIColor whiteColor];
        [expview loadFacialView:i size:size data:expressionarr];
        expview.delegate=self;
        [scrollView addSubview:expview];
    }
    scrollView.contentSize=CGSizeMake(self.bounds.size.width*page,  self.bounds.size.height);
    scrollView.pagingEnabled=NO;
    scrollView.alwaysBounceHorizontal=NO;
    
    
    CGFloat spaceW=((bounds.size.width-50*4)/5)*_ratioW;
    CGFloat spaceH=((bounds.size.height-67*2)/3)*_ratioH;
    
    //第一行第一列
    UIButton *btn00 =[[UIButton alloc] initWithFrame:CGRectMake(spaceW, spaceH, 50, 50)];
    [btn00 setImage:[UIImage imageNamed:@"aio_icons_pic@2x.png"] forState:UIControlStateNormal];
    [btn00 setImage:[UIImage imageNamed:@"aio_icons_pic@2x.png"] forState:UIControlStateSelected];
    btn00.backgroundColor=[UIColor yellowColor];
    btn00.tag=900;
    [btn00 addTarget:self action:@selector(morefunction:) forControlEvents:UIControlEventTouchUpInside];
    [MoreView addSubview:btn00];
    UILabel *lab00 =[[UILabel alloc] initWithFrame:CGRectMake(spaceW, spaceH+50+2, 50, 15)];
    lab00.textAlignment=NSTextAlignmentCenter;
    lab00.font=[UIFont systemFontOfSize:11];
    lab00.text=NSLocalizedString(@"lbTPhonto",nil);//@"拍照";
    [MoreView addSubview:lab00];
    
    
    //第一行第二列
    UIButton *btn10 =[[UIButton alloc] initWithFrame:CGRectMake(spaceW*2+50, spaceH, 50, 50)];
    [btn10 setImage:[UIImage imageNamed:@"aio_icons_camera@2x.png"] forState:UIControlStateNormal];
    [btn10 setImage:[UIImage imageNamed:@"aio_icons_camera@2x.png"] forState:UIControlStateSelected];
    btn10.backgroundColor=[UIColor grayColor];
    btn10.tag=910;
    [btn10 addTarget:self action:@selector(morefunction:) forControlEvents:UIControlEventTouchUpInside];
    [MoreView addSubview:btn10];
    UILabel *lab10 =[[UILabel alloc] initWithFrame:CGRectMake(spaceW*2+50, spaceH+50+2, 50, 15)];
    lab10.textAlignment=NSTextAlignmentCenter;
    lab10.font=[UIFont systemFontOfSize:11];
    lab10.text=NSLocalizedString(@"lbTShoot",nil);//@"摄像";
    [MoreView addSubview:lab10];
    
    //    //第二行第一列
    //    UIButton *btn01 =[[UIButton alloc] initWithFrame:CGRectMake(spaceW, spaceH*2+50+15+2, 50, 50)];
    //    [btn01 setImage:[UIImage imageNamed:@"aio_icons_location@2x.png"] forState:UIControlStateNormal];
    //    [btn01 setImage:[UIImage imageNamed:@"aio_icons_location@2x.png"] forState:UIControlStateSelected];
    //   // btn01.backgroundColor=[UIColor grayColor];
    //    btn01.tag=901;
    //    [btn01 addTarget:self action:@selector(morefunction:) forControlEvents:UIControlEventTouchUpInside];
    //    [MoreView addSubview:btn01];
    //    UILabel *lab01 =[[UILabel alloc] initWithFrame:CGRectMake(spaceW, spaceH*2+50*2+15+2*2, 50, 15)];
    //    lab01.textAlignment=NSTextAlignmentCenter;
    //    lab01.text=NSLocalizedString(@"lblocation",nil);
    //    [MoreView addSubview:lab01];
    //
    
}

#pragma mnark-更多操作
- (void) morefunction:(UIButton *) btn
{
    // NSLog(@"%d",btn.tag);
    [self.detailKeyBoardDelegate MoreFunctionChoice:btn.tag];
    
}
#pragma mark-表情点击时间代理
- (void)selectedExpression:(NSInteger)index
{
    //获取表情的名字并把表情传出去
    NSString * tempemjname=[expressionKeyarr objectAtIndex:index];
    [self.detailKeyBoardDelegate EmojiImageClick:tempemjname];
}
#pragma mark-切换表情盘的显示内容
- (void) ChoiceViewShow:(NSInteger) viewIndex;
{
    for (UIView *view in [self subviews]) {
        if (view.tag==viewIndex) {
            view.hidden=NO;
            [view becomeFirstResponder];
        }else{
            view.hidden=YES;
        }
    }
    
}




@end
