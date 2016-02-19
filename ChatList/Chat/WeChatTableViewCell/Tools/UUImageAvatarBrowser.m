//
//  UUAVAudioPlayer.m
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUImageAvatarBrowser.h"
#import "UIImageView+WebCache.h"


static UIImageView *orginImageView;
@implementation UUImageAvatarBrowser{

    CGFloat _lastScale;

}

+(void)showImage:(UIImageView *)avatarImageView data:(MessageModel *)data{
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    UIImage *image=avatarImageView.image;
    orginImageView = avatarImageView;
    orginImageView.alpha = 0;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    CGRect oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
    backgroundView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:1];
    backgroundView.alpha=1;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    
   NSString *  ImageURL1 = [data.content stringByReplacingOccurrencesOfString:@"Small" withString:@""];
    NSString *path=[Tool Append:IMReasonableAPPImagePath witnstring:ImageURL1];
   [imageView  sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:image];
   // imageView.image=image;
    imageView.tag=1;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = NO;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    [imageView setUserInteractionEnabled:YES];
    [imageView setMultipleTouchEnabled:YES];
    
    [UUImageAvatarBrowser addGestureRecognizerToView:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}
                                                 

// 添加所有的手势
+ (void) addGestureRecognizerToView:(UIView *)view
{
    
   
//    // 旋转手势
//    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
//    [view addGestureRecognizer:rotationGestureRecognizer];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
}

// 处理旋转手势
//+ (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
//{
//    UIView *view = rotationGestureRecognizer.view;
//    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
//        [rotationGestureRecognizer setRotation:0];
//    }
//}

// 处理缩放手势
+ (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    
    UIView *  temp=pinchGestureRecognizer.view;
    UIImageView *view = (UIImageView *)[temp viewWithTag:1];
    
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
      
          view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        
 
//        if (view.frame.size.width < orginImageView.frame.size.width) {
//            
//            UIWindow *window=[UIApplication sharedApplication].keyWindow;
//            CGRect oldframe=[orginImageView convertRect:orginImageView.bounds toView:window];
//            view.frame = oldframe;
//           //  view.frame = orginImageView.frame;
//             view.image=orginImageView.image;
//            
//            
//            //让图片无法缩得比原图小
//        }
//        if (view.frame.size.width > 10 *  orginImageView.frame.size.width) {
//             view.frame = orginImageView.frame;
//        }
        
        view.center=[UIApplication sharedApplication].keyWindow.center;
        
        pinchGestureRecognizer.scale = 1;
    }
}

// 处理拖拉手势
+ (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *  temp=panGestureRecognizer.view;
    UIImageView *view = (UIImageView *)[temp viewWithTag:1];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        CGPoint p= (CGPoint){view.center.x + translation.x, view.center.y + translation.y};
        if(p.y>0 && p.x>0)
        {
            [view setCenter:p];//(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        }
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}


+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIApplication *application = [UIApplication sharedApplication];
    [application setStatusBarHidden:NO];
    
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=[orginImageView convertRect:orginImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
        orginImageView.alpha = 1;
        backgroundView.alpha=0;
    }];
}
@end
