//
//  PostTalkkingViewController.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/12/1.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "PJImageBrowser.h"
#import "PJButton.h"
#import "PostTalkkingViewController.h"
#import "PJTextView.h"
#import "AppDelegate.h"

#define MARGEN_X 8
#define MARGEN_Y 8
#define HEIGHT 128
#define ADDPHOTO_COUNT 4
#define ROW_COUNT 2

@interface PostTalkkingViewController()<PJImageBrowserDelegate>

@property (weak, nonatomic)UIButton *addPhoto;
@property(weak,nonatomic) PJTextView *talkContent;
@property(nonatomic,assign)int index_x;
@property(nonatomic,assign)int index_y;
//当前未添加图片的按钮
@property(nonatomic,weak)PJButton *currentAddPhotoButton;
//存放有所有的按钮(即存放所有的图片)
@property(nonatomic,strong)NSMutableArray *addPhotoButtonArray;
//存放所有的图片
@property(nonatomic,strong)NSMutableArray *addPhotoArray;
//按钮的大小
@property(nonatomic,assign)int addPhotoWidth;
@property(nonatomic,assign)int maxYoftalkContent;
//按钮个数
@property(nonatomic,assign)int buttonCount;


@end

@implementation PostTalkkingViewController

-(NSMutableArray *)addPhotoButtonArray{
    if(_addPhotoButtonArray==nil){
        
        _addPhotoButtonArray=[NSMutableArray array];
    }
    return _addPhotoButtonArray;
}

-(NSMutableArray *)addPhotoArray{
    if(_addPhotoArray==nil){
        
        _addPhotoArray=[NSMutableArray array];
    }
    return _addPhotoArray;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    //禁止横屏
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    [self initController];
    [self initView];
}

-(void)initController{
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(send)];
    self.navigationItem.leftBarButtonItem=leftButton;
    self.navigationItem.rightBarButtonItem=rightButton;
}

-(void)initView{
    self.view.backgroundColor=[UIColor whiteColor];
    PJTextView *talkContent=[[PJTextView alloc] init];
    talkContent.placehoder=NSLocalizedString(@"IDEA", nil);
    talkContent.frame=CGRectMake(MARGEN_X, STATUSBAR_HEIGHT+MARGEN_Y, SCREENWIDTH-2*MARGEN_X, HEIGHT);
    [self.view addSubview:talkContent];
    self.talkContent=talkContent;
    talkContent.alwaysBounceVertical=YES;
    self.addPhotoWidth=(SCREENWIDTH-((1+ADDPHOTO_COUNT)*MARGEN_X))/ADDPHOTO_COUNT;
    self.maxYoftalkContent=CGRectGetMaxY(self.talkContent.frame);
    for(int p=0;p<ROW_COUNT;p++){
        for(int i=0;i<ADDPHOTO_COUNT;i++){
            PJButton *addPhoto=[[PJButton alloc] init];
            [addPhoto setImage:[UIImage imageNamed:@"addpic_unfocused"] forState:UIControlStateNormal];
            [addPhoto setImage:[UIImage imageNamed:@"addpic_focused"] forState:UIControlStateHighlighted];
            [self.view addSubview:addPhoto];
            addPhoto.hidden=i==0&&p==0?false:true;
            addPhoto.frame=CGRectMake(i*self.addPhotoWidth+(i+1)*MARGEN_X, self.maxYoftalkContent+p*self.addPhotoWidth+((p+1)*MARGEN_Y), self.addPhotoWidth, self.addPhotoWidth);
            [self.addPhotoButtonArray addObject:addPhoto];
            addPhoto.tag=self.buttonCount;
            addPhoto.index=self.buttonCount;
            self.buttonCount++;
            [addPhoto addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
            addPhoto.imageView.contentMode=UIViewContentModeScaleAspectFit;
        }
    }
}

-(void)send{
    
}

-(void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addPhoto:(id)button{
    PJButton *tempbutton=button;
    if(tempbutton.hasAddPhoto){
        
        //已经添加完图片
        PJImageBrowser *pjImageBrowser=[[PJImageBrowser alloc] initWithImageArray:self.addPhotoArray AndCurrentIndex:tempbutton.tag];
        pjImageBrowser.pjimageBrowserDelegate=self;
        [self.navigationController pushViewController:pjImageBrowser animated:YES];
    }else{
        
        //未添加图片
        self.currentAddPhotoButton=button;
        [self imagefromwhere];
    }
}

#pragma 删除图片方法回调
-(void)deletePhoto:(PJImageBrowser *)pjimageBrowser AtIndex:(NSInteger)index{
    [self.addPhotoArray removeAllObjects];
    self.addPhotoArray=[pjimageBrowser.imageArray mutableCopy];
    [self updateAddPhotoButtonView];
}

//刷新添加图片按钮界面
-(void)updateAddPhotoButtonView{
    for(PJButton *pjButton in self.addPhotoButtonArray){
        [pjButton setImage:[UIImage imageNamed:@"addpic_unfocused"] forState:UIControlStateNormal];
        [pjButton setImage:[UIImage imageNamed:@"addpic_focused"] forState:UIControlStateHighlighted];
        pjButton.hidden=true;
        pjButton.hasAddPhoto=false;
    }
    for(int i=0;i<self.addPhotoArray.count;i++){
        PJButton *pjButton=self.addPhotoButtonArray[i];
        pjButton.hidden=false;
        [pjButton setTalkkingImage:self.addPhotoArray[i]];
        int tempindex=i+1;
        if(tempindex<self.buttonCount){
            
         ((PJButton *)self.addPhotoButtonArray[tempindex]).hidden=false;
        }
    }
    //在图片浏览器的时候把图片全删除了
    if(self.addPhotoArray.count==0){
        
        PJButton *pjButton=self.addPhotoButtonArray[0];
        [pjButton setImage:[UIImage imageNamed:@"addpic_unfocused"] forState:UIControlStateNormal];
        [pjButton setImage:[UIImage imageNamed:@"addpic_focused"] forState:UIControlStateHighlighted];
        pjButton.hidden=false;
        pjButton.hasAddPhoto=false;
    }
}

//每次从图片浏览器返回也刷新界面
-(void)back:(PJImageBrowser *)pjimageBrowser{
    [self updateAddPhotoButtonView];
}

#pragma mark -图片源函数
- (void)imagefromwhere
{
    UIActionSheet* action;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        action = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:NSLocalizedString(@"lbTCancle", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"lbTPhonto", nil), NSLocalizedString(@"lbTShoot", nil), nil];
    }
    else {
        
        action = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:NSLocalizedString(@"lbTCancle", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"lbTPhonto", nil), nil];
    }
    
    action.actionSheetStyle = UIActionSheetStyleAutomatic;
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
        NSUInteger sourceType = 0;
        // 判断是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2:
                    // 取消
                    return;
            }
        }
        else {
            if (buttonIndex == 0) {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            else {
                return;
            }
        }
        
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = (id)self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController
                           animated:YES
                         completion:^{
                         }];
}
#pragma mark -图片设置到控件
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                               }];
    
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];

    [self.currentAddPhotoButton setTalkkingImage:image];
    [self.addPhotoArray addObject:image];
    if(self.currentAddPhotoButton.index+1<self.buttonCount){
        
        self.currentAddPhotoButton=self.addPhotoButtonArray[self.currentAddPhotoButton.index+1];
        self.currentAddPhotoButton.hidden=false;
    }
    
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    // 保存图片至本地，方法见下文
}

-(void)dealloc{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
}

@end
