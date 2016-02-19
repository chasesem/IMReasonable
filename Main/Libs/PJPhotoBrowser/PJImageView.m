//
//  PJImageView.m
//  IMReasonable
//
//  Created by 翁金闪  on 15/12/21.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "PJImageView.h"
#import "PJPhoto.h"
#import "PJImageBrowser.h"

#define MAXIMUMZOOMSCALE 2.0//图片最大放大倍数
#define MINIMUMZOOMSCALE 1.0//图片最大缩小倍数
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENWIHEIGHT [UIScreen mainScreen].bounds.size.height

@interface PJImageView()<UIScrollViewDelegate>

@property(nonatomic,strong)UIImageView *imageView;
//是否隐藏导航栏
@property(nonatomic,assign)BOOL hideBar;
@property(nonatomic,assign)CGRect tempFrame;

@end

@implementation PJImageView

-(void)initImage{
    // 2.添加图片
        _imageView.contentMode=UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        // 设置frame
        _tempFrame=[self adjustFrame:_imageView];
    _imageView.frame=CGRectMake(_tempFrame.origin.x, ((SCREENWIHEIGHT-_tempFrame.size.height)/2)-rectStatus.size.height, _tempFrame.size.width, _tempFrame.size.height);
    // 3.设置其他属性
    self.contentSize = CGSizeMake(SCREENWIDTH, 0);
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
}

//设置图片显示比例
#pragma mark 调整frame
- (CGRect)adjustFrame:(UIImageView *)imageView
{
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width==0?SCREENWIDTH:boundsSize.width;
    CGFloat boundsHeight = boundsSize.height==0?SCREENWIHEIGHT:boundsSize.height;
    
    CGSize imageSize = imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    // 设置伸缩比例
    CGFloat minScale = boundsWidth / imageWidth;
    if (minScale > 1) {
        minScale = 1.0;
    }
    CGFloat maxScale = 2.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    self.maximumZoomScale = MAXIMUMZOOMSCALE;
    self.minimumZoomScale = MINIMUMZOOMSCALE;
    self.zoomScale = minScale;

    
    CGRect imageFrame;
    CGRect screenSize=[UIScreen mainScreen].bounds;
    //图片小于屏幕的大小
    if(screenSize.size.height>=imageSize.height&&screenSize.size.width>=imageSize.width){
        
        imageFrame = CGRectMake((SCREENWIDTH-imageSize.width)/2, 0, imageSize.width,imageSize.height);
        
    }else{
        
        imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    }
    // 内容尺寸
    self.contentSize = CGSizeMake(0, imageFrame.size.height);
    
    // y值
    if (imageFrame.size.height < boundsHeight) {
        imageFrame.origin.y = floorf((boundsHeight - imageFrame.size.height) / 2.0);
    } else {
        imageFrame.origin.y = 0;
    }
    return imageFrame;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        self.clipsToBounds = YES;
        self.delegate=self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // 监听点击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

- (void)handleSingleTap:(UITapGestureRecognizer*)singleTap
{
    [self hideBar:!_hideBar];
    [self setZoomScale:self.minimumZoomScale animated:YES];
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap{
    [self hideBar:YES];
    _hideBar=YES;
    CGPoint touchPoint = [doubleTap locationInView:self];
    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

-(void)setPhoto:(PJPhoto *)photo{
    _imageView=[[UIImageView alloc] initWithImage:photo.image];
    [self initImage];
}

-(void)hideBar:(BOOL)hideBar{
    if([self.photoViewDelegate respondsToSelector:@selector(hideBar:)]){
        
        [self.photoViewDelegate hideBar:hideBar];
    }
    _hideBar=!_hideBar;
}

@end
