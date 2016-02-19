//
//  WallPaperViewController.m
//  IMReasonable
//
//  Created by apple on 15/6/23.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "WallPaperViewController.h"
#import "WallpaperCollectionViewCell.h"
#import "AppDelegate.h"

@interface WallPaperViewController ()
{
    UICollectionView * _uicollectionview;
    NSMutableArray * _arrData;
    NSInteger seleteindex;
}

@end

@implementation WallPaperViewController

#pragma mark--ViewControl 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    
    [self initViewControl];
    [self initData];
    [self initNav];
    seleteindex=[[[NSUserDefaults standardUserDefaults] objectForKey:CHATWALLPAPER] integerValue];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    _arrData=nil;
    _uicollectionview=nil;
    
    
    NSString * imagename=[NSString  stringWithFormat:@"%ld",(long)seleteindex];
    [[NSUserDefaults standardUserDefaults] setObject:imagename forKey:CHATWALLPAPER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark-初始化导航栏
-(void)initNav{
    self.navigationItem.title=NSLocalizedString(@"lbwallpaper",nil);//lbwallpaper
}

#pragma mark-初始化界面上德各个控件
- (void)initViewControl{
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];

    _uicollectionview=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH , SCREENWIHEIGHT) collectionViewLayout:flowLayout];
    
    
   [_uicollectionview registerClass :[ WallpaperCollectionViewCell class ] forCellWithReuseIdentifier : @"WALLPAPER"];
    
    _uicollectionview.delegate=self;
    _uicollectionview.dataSource=self;
    _uicollectionview.backgroundColor=[UIColor whiteColor];
    
    [self.view addSubview:_uicollectionview];

}
#pragma mark--初始化界面数据
- (void) initData{
    _arrData=[[NSMutableArray alloc]init];
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString * nick=[defaults objectForKey:MyLOCALNICKNAME];
    int endindex=4;
    if (nick&&nick.length>0) {
         NSString *b = [nick substringFromIndex:nick.length-1];
        if ([b isEqualToString:@"$"]) {
            endindex=43;
        }
    }
   
    
    for (int i=0; i<endindex; i++) {//43
        
//        NSString * imagename=[NSString  stringWithFormat:@"wp_%d.jpg",i];
//       UIImage * tempimage=[UIImage imageNamed:imagename];
//        [_arrData addObject:tempimage];
        
        NSString * imagename=[NSString  stringWithFormat:@"wp_%d.jpg",i];
      //  UIImage * tempimage=[UIImage imageNamed:imagename];
        [_arrData addObject:imagename];
    }
  
}

#pragma mark-UICollectionview
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrData.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString * cellInde=@"WALLPAPER";
  
    
   WallpaperCollectionViewCell * cellt=[collectionView dequeueReusableCellWithReuseIdentifier:cellInde forIndexPath:indexPath];
    cellt.backgroundColor=[UIColor colorWithRed:0.01*indexPath.row green:0.03*indexPath.row blue:0.08*indexPath.row alpha:1];
    NSString * path=[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath],[_arrData objectAtIndex:[indexPath row]]];
//    cellt.img.image=[UIImage imageNamed:[_arrData objectAtIndex:[indexPath row]]];//[_arrData objectAtIndex:[indexPath row]];
    cellt.img.image=[UIImage imageWithContentsOfFile:path];
    if([indexPath row]==seleteindex){
    cellt.seletedimg.image=[UIImage imageNamed:@"selected"];
    }else{
        cellt.seletedimg.image=nil;
    }
    
    return cellt;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    seleteindex=[indexPath row];
    [_uicollectionview reloadData];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width=(self.view.frame.size.width-30)/3;
    return CGSizeMake(width, width/0.618);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

-(void)dealloc{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
}

@end
