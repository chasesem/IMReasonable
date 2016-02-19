//
//  PictureContent.m
//  KeyBoard
//
//  Created by apple on 15/6/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#define OFFSET 20

#import "PictureContent.h"
#import "StateView.h"
#import "UUImageAvatarBrowser.h"
#import "UIImageView+WebCache.h"

#define CUT @"cut"

@implementation PictureContent
{
    UIImageView * _imageview;
    UILabel *_username;//用于显示对方的姓名的
    UILabel * _line;  //用于设置分割线，
    StateView * _stateview; //状态视图
}


-(instancetype)init{
    self=[super init];
    
    if (self) {
        self.backgroundImage=[[UIImageView alloc] init];
        [self addSubview:self.backgroundImage];
        _imageview=[[UIImageView alloc] init];
        _imageview.layer.masksToBounds = YES;
        _imageview.layer.cornerRadius = 5;
        _imageview.tag=200;
        
        
        [self addSubview:_imageview];
        
        _username=[[UILabel alloc] init];
        _username.textColor=[UIColor colorWithRed:0.1 green:0.5 blue:0.2 alpha:1];
        [_username setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [self addSubview:_username];
        _stateview=[[StateView alloc]init];
        [self addSubview:_stateview];
    }
    
    return self;
}





- (void)setMessagemode:(MessageModel *)messagemode isNeedName:(BOOL)isName
{
    _messagemode=messagemode;
    _username.text=messagemode.username;
    
    [_stateview setStateviewData:messagemode];
    
    
    
    _imageview.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fangda:)];
    [_imageview addGestureRecognizer:singleTap];
    
    
    CGRect rect=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.backgroundImage.frame=rect;
    if (messagemode.isFromMe) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //聊天背景图片(气泡)
            UIImage *bubble =[UIImage imageNamed:@"BubbleOutgoing"] ;
            CGFloat top =10; // 顶端盖高度
            CGFloat left = bubble.size.width/2 ; // 底端盖高度
            CGFloat bottom = bubble.size.height - top + 1; // 左端盖宽度
            CGFloat right = bubble.size.width - left - 1; // 右端盖宽度
            UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
            /**
             *  自己发送的图片在聊天列表显示的不是原图，而是裁剪后的图片，裁剪后的图片会保存到本地，没有裁剪则去裁剪并保存，裁剪后的图片名称为原图的名称前面加"cut_"
             */
            //要显示的图片
            UIImage * tempimg=[UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:[NSString stringWithFormat:@"%@_%@",CUT,messagemode.content]]];
            if(!tempimg){
                
                tempimg=[UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:messagemode.content]];
                tempimg=[self cutImage:tempimg];
                [Tool saveImageToDoc:[NSString stringWithFormat:@"%@_%@",CUT,messagemode.content] image:tempimg];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                _imageview.image=tempimg;
                
                self.backgroundImage.image=[bubble resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
                
                _imageview.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                _stateview.frame=CGRectMake(_imageview.frame.size.width-45, _imageview.frame.size.height-10, 45, 10);
            });
        });
    }else{
        
        //设置背景气泡
        UIImage *bubble =[UIImage imageNamed:@"BubbleIncoming"];
        CGFloat top =10; // 顶端盖高度
        CGFloat left = bubble.size.width/2 ; // 底端盖高度
        CGFloat bottom = bubble.size.height - top + 1; // 左端盖宽度
        CGFloat right = bubble.size.width - left - 1; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        self.backgroundImage.image=[bubble resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
        CGFloat offset=0;
        if (isName) {
            offset=20;
            _username.hidden=NO;
        }else{
            _username.hidden=YES;
            offset=2;
            
        }
        //设置聊天的内容
        _imageview.frame=CGRectMake(0, OFFSET, self.frame.size.width, self.frame.size.height);
        _username.frame=CGRectMake(MARGEN, 0, self.frame.size.width-MARGEN, offset); //设置显示用户的名字
        
        NSString *path=[Tool Append:IMReasonableAPPImagePath witnstring:messagemode.content];
        [_imageview sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            _imageview.image=[self cutImage:image];
        }];
//        _stateview.frame=CGRectMake(self.frame.size.width-30, self.frame.size.height-15, 25, 10);
        _stateview.frame=CGRectMake(CGRectGetMaxX(_imageview.frame)-25,CGRectGetMaxY(_imageview.frame)-15 ,25 ,10 );
        
    }
}

-(UIImage *)cutImage:(UIImage *)image{
    CGSize imageSize=image.size;
    long x,y,c;
    long width=imageSize.width;
    long heigth=imageSize.height;
    if(width>=heigth){
        
        x=(width-heigth)/2;
        y=0;
        c=heigth;
    }else{
        
        x=0;
        y=(heigth-width)/2;
        c=width;
    }
    return [self getImageFromImage:image subImageSize:CGSizeMake(c, c) subImageRect:CGRectMake(x, y, c, c)];
}

//图片裁剪
-(UIImage *)getImageFromImage:(UIImage*) superImage subImageSize:(CGSize)subImageSize subImageRect:(CGRect)subImageRect {
     //    CGSize subImageSize = CGSizeMake(WIDTH, HEIGHT); //定义裁剪的区域相对于原图片的位置
     //    CGRect subImageRect = CGRectMake(START_X, START_Y, WIDTH, HEIGHT);
         CGImageRef imageRef = superImage.CGImage;
         CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, subImageRect);
         UIGraphicsBeginImageContext(subImageSize);
         CGContextRef context = UIGraphicsGetCurrentContext();
         CGContextDrawImage(context, subImageRect, subImageRef);
         UIImage* returnImage = [UIImage imageWithCGImage:subImageRef];
         UIGraphicsEndImageContext(); //返回裁剪的部分图像
         return returnImage;
}

- (void)fangda:(id)sender{
    [self.delegate touchPictureContent:_imageview MessageModle:_messagemode];
}

@end
