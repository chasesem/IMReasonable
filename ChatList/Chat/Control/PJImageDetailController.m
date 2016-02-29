//
//  PJImageDetailController.m
//  IMReasonable
//
//  Created by 翁金闪 on 16/1/5.
//  Copyright © 2016年 Reasonable. All rights reserved.
//

#import "PJImageDetailController.h"
#include<AssetsLibrary/AssetsLibrary.h>
#import "PJImageView.h"
#import "PJPhoto.h"
#import "AppDelegate.h"

#define MARGEN 10
#define MAXIMUMZOOMSCALE 2.0//图片最大放大倍数
#define MINIMUMZOOMSCALE 0.5//图片最大缩小倍数

@interface PJImageDetailController ()<PJPhotoViewDelegate>

@property(nonatomic,strong)PJImageView *pjimageView;
@property(nonatomic,strong)UILabel *imageSizeLabel;
@property(nonatomic,strong)UISwitch *original;
//是否发送原图
@property(nonatomic,assign)BOOL isOriginal;
//原图
@property(nonatomic,strong)UIImage *originalImage;
//图片浏览器返回的信息
@property(nonatomic,strong)NSDictionary *info;
@property(nonatomic,weak)UIView *footer;
@property(nonatomic,assign)float imageSize;
@end

@implementation PJImageDetailController

-(instancetype)initWithImage:(UIImage *)image AndImageDic:(NSDictionary *)info{
    if(self=[super init]){
        
        self.pjimageView=[[PJImageView alloc] init];
        self.imageSizeLabel=[[UILabel alloc] init];
        self.originalImage=image;
        self.info=info;
    }
    return self;
}

-(void)initView{
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.pjimageView];
    self.pjimageView.frame=[self.view bounds];
    self.pjimageView.photoViewDelegate=self;
    PJPhoto *photo=[[PJPhoto alloc] init];
    photo.image=self.originalImage;
    self.pjimageView.photo=photo;
    UIView *footer=[[UIView alloc] init];
    [self.view addSubview:footer];
    self.footer=footer;
    int footer_h=SCREENWIHEIGHT/10;
    footer.frame=CGRectMake(0, SCREENWIHEIGHT-footer_h, SCREENWIDTH, footer_h);
    footer.backgroundColor=[UIColor grayColor];
    footer.alpha=0.8;
    self.original=[[UISwitch alloc] init];
    int original_h=footer_h/2;
    [self SizeOfImage:self.info];
    self.imageSizeLabel=[[UILabel alloc] init];
    //添加
//    if(self.imageSize > 300){
        [footer addSubview:self.original];
        [footer addSubview:self.imageSizeLabel];
//    }
   
    self.original.frame=CGRectMake(2*MARGEN, (footer_h-original_h)/2, SCREENWIDTH/7, original_h);
    
    
    self.imageSizeLabel.frame=CGRectMake(CGRectGetMaxX(self.original.frame)+MARGEN, self.original.frame.origin.y, 165, original_h);
    //[self SizeOfImage:self.info];
    //NSLog(@"%f------------",[self SizeOfImage:self.info]);
    self.imageSizeLabel.textColor=[UIColor whiteColor];
    UIButton *sendImage=[[UIButton alloc] init];
    [footer addSubview:sendImage];
    int sendImage_w=46;
    int sendImage_h=4*footer_h/5;
    sendImage.frame=CGRectMake(SCREENWIDTH-sendImage_w-MARGEN,(footer.frame.size.height-sendImage_h)/2 ,sendImage_w ,sendImage_h );
    [sendImage setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
    [sendImage setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [sendImage setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.original addTarget:self action:@selector(OriginalImage:) forControlEvents:UIControlEventValueChanged];
    [sendImage addTarget:self action:@selector(sendImage) forControlEvents:UIControlEventTouchUpInside];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initView];
    //禁止横屏
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    
}


- (void)viewDidAppear:(BOOL)animated{
    if(![self checkImageSize:self.imageSizeLabel.text]){
        [self.original removeFromSuperview];
        [self.imageSizeLabel removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)OriginalImage:(id)sender{
    self.isOriginal=((UISwitch *)sender).isOn;
    if(self.isOriginal){
        
        self.imageSizeLabel.textColor=[UIColor greenColor];
    }else{
        
        self.imageSizeLabel.textColor=[UIColor whiteColor];
    }
}

-(void)sendImage{
    if([self.pjsendImageDelegate respondsToSelector:@selector(PJsendImage:AndIsOriginal:)]){
        
        [self.pjsendImageDelegate PJsendImage:self.originalImage AndIsOriginal:self.isOriginal];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//从手机相册返回的图片的大小
-(float)SizeOfImage:(NSDictionary *)info{
    __block __weak typeof(self) tmpSelf = self;
    ALAssetsLibrary* alLibrary = [[ALAssetsLibrary alloc] init];
    __block float fileMB  = 0.0;
    
    [alLibrary assetForURL:[self.info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation *representation = [asset defaultRepresentation];
         fileMB = (float)([representation size]/1024);
         [tmpSelf upDateImageSizeLabel:fileMB];
         
     }
              failureBlock:^(NSError *error)
     {
     }];
    return fileMB;
}

-(void)upDateImageSizeLabel:(float)imageSize{
    NSString *str;
    if(imageSize>=1024){
        
        str=[NSString stringWithFormat:@"%@(%0.2fMB)",NSLocalizedString(@"ORIGINAL", nil),imageSize/1024];
    }else{
        
        str=[NSString stringWithFormat:@"%@(%0.1fKB)",NSLocalizedString(@"ORIGINAL", nil),imageSize];
    }
    self.imageSizeLabel.text=str;
}


-(BOOL)checkImageSize:(NSString*)imageDataSize{
    NSArray *first = [imageDataSize componentsSeparatedByString:@"("];
    NSString *second = first[1];
    NSString *third = [second substringWithRange:NSMakeRange([second length] - 3,1)];
    if([third isEqual: @"K"]){
        float size = [[second substringToIndex:[second length]- 4] floatValue];
        if(size < 300){
            return NO;
        }
        else{
            return YES;
        }
        //NSLog(@"%f--------",size);
    }
    
    return YES;
}


-(void)hideBar:(BOOL)hide{
    [UIView animateWithDuration:1.0 animations:^{
        [[self navigationController] setNavigationBarHidden:hide animated:YES];
        self.footer.hidden=hide;
    }];
}

-(void)dealloc{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
}

@end
