//
//  PJImageBrowserController.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/12/10.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#define DELETE 0//删除

#import "PJImageView.h"
#import "PJImageBrowser.h"
#import "PJPhoto.h"

@interface PJImageBrowser ()<UIScrollViewDelegate,PJPhotoViewDelegate,UIActionSheetDelegate>

@property(nonatomic,weak)UIScrollView *scrollView;
//图片索引指示器
@property(nonatomic,copy)NSString *indexStr;
//存放所有的PJImageView
@property(nonatomic,strong)NSMutableArray *pjimageViewArray;

@end

@implementation PJImageBrowser

-(NSMutableArray *)pjimageViewArray{
    if(!_pjimageViewArray){
        
        _pjimageViewArray=[NSMutableArray array];
    }
    return _pjimageViewArray;
}

-(instancetype)initWithImageArray:(NSMutableArray *)imageArray AndCurrentIndex:(NSInteger)index{
    self=[super init];
    if(self){
        
        _photos=[NSMutableArray array];
        self.imageArray=[imageArray mutableCopy];
        self.currentIndex=index;
        for(int i=0;i<imageArray.count;i++){
            
            PJPhoto *photo=[[PJPhoto alloc] init];
            photo.image=imageArray[i];
            photo.index=i;
            [_photos addObject:photo];
            PJImageView *pjimageView=[[PJImageView alloc] init];
            pjimageView.photo=photo;
            [self.pjimageViewArray addObject:pjimageView];
        }
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initController];
    [self setupScrollView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)initController{
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhoto)];
    self.navigationItem.rightBarButtonItem=rightButton;
    [self updateTitle];
}

-(void)updateTitle{
    self.indexStr=[NSString stringWithFormat:@"%ld/%lu",self.currentIndex+1,(unsigned long)self.pjimageViewArray.count];
    self.navigationItem.title=self.indexStr;
}

-(void)deletePhoto{
    if(iOS(8)){
        
        [self heighSysDeletePhoto];
    }else{
        
        [self lowSysDeletePhoto];
    }
}

-(void)heighSysDeletePhoto{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"DELETE_THIS_PHOTO", nil)
                                                                             message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"lbTCancle",nil) style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"DELETE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        PJImageView *pjimageView=self.pjimageViewArray[self.currentIndex];
        if(pjimageView){
            
            [self didDeletePhoto:self.currentIndex];
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)lowSysDeletePhoto{
    UIActionSheet* inviteSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"DELETE_THIS_PHOTO", nil)
                                                             delegate:(id)self
                                                    cancelButtonTitle:NSLocalizedString(@"lbTCancle",nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"DELETE", nil),
                                  nil];
    [inviteSheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==DELETE){
        
        PJImageView *pjimageView=self.pjimageViewArray[self.currentIndex];
        if(pjimageView){
            
            [self didDeletePhoto:self.currentIndex];
        }
    }
}

- (void)setupScrollView
{
    // 1.添加UISrollView
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.scrollView=scrollView;
    self.scrollView.backgroundColor=[UIColor blackColor];
    
    // 2.添加图片
    CGFloat scrollW=scrollView.frame.size.width;
    CGFloat scrollH=scrollView.frame.size.height;
    for (int i = 0; i<self.pjimageViewArray.count; i++) {
        // 创建UIImageView
        PJImageView *pjimageView=_pjimageViewArray[i];
        pjimageView.photoViewDelegate=self;
        [scrollView addSubview:pjimageView];
        
        // 设置frame
        pjimageView.frame=CGRectMake(i * scrollW, 0, scrollW, scrollH);
    }
    
    // 3.设置其他属性
    scrollView.contentSize = CGSizeMake(self.pjimageViewArray.count * scrollW, 0);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentOffset=CGPointMake(self.currentIndex*scrollW, 0);
}

- (void)updateCurrentIndex
{
    self.currentIndex = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCurrentIndex];
    [self updateTitle];
}

-(void)setPhotos:(NSMutableArray *)photos{
    if(photos){
        
        for(PJPhoto *photo in photos){
            PJImageView *imageView=[[PJImageView alloc] init];
            imageView.photo=photo;
            [self.pjimageViewArray addObject:imageView];
        }
        self.photos=[photos mutableCopy];
    }
}

-(void)hideBar:(BOOL)hide{
    [UIView animateWithDuration:1.0 animations:^{
        [[self navigationController] setNavigationBarHidden:hide animated:YES];
    }];
}

//删除图片
-(void)didDeletePhoto:(NSInteger)index{
    __block NSInteger tempindex=index;
    PJImageView *pjimageView=self.pjimageViewArray[index];
    if(pjimageView){
        
            //把装载图片的pjimageView从父视图容器中删除，并且从集合中删除
            [pjimageView removeFromSuperview];
            [self.photos removeObjectAtIndex:index];
            [self.pjimageViewArray removeObjectAtIndex:index];
            [self.imageArray removeObjectAtIndex:index];
            [self updateCurrentIndex];
            [self updateTitle];
            int scrollW=self.scrollView.frame.size.width;
            self.scrollView.contentSize = CGSizeMake(self.pjimageViewArray.count * scrollW, 0);
            if(self.pjimageViewArray.count==0){
                
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                
                [UIView animateWithDuration:0.5 animations:^{
                for(int i=(int)tempindex;i<_pjimageViewArray.count;i++){
                    PJImageView *pjimageView=_pjimageViewArray[i];
                    if(pjimageView){
                        
                        //更新图片(pjimageView)的frame,即后面的图片往前移
                        pjimageView.frame=CGRectMake(pjimageView.frame.origin.x-scrollW, pjimageView.frame.origin.y, pjimageView.frame.size.width, pjimageView.frame.size.height);
                        
                    }
                }
            }];
        }
    }
    if([self.pjimageBrowserDelegate respondsToSelector:@selector(deletePhoto:AtIndex:)]){
        
        [self.pjimageBrowserDelegate deletePhoto:self AtIndex:index];
    }
}

-(void)dealloc{
    if([self.pjimageBrowserDelegate respondsToSelector:@selector(back:)]){
        
        [self.pjimageBrowserDelegate back:self];
    }
}

@end
