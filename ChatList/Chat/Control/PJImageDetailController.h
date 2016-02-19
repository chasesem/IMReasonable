//
//  PJImageDetailController.h
//  IMReasonable
//
//  Created by 翁金闪 on 16/1/5.
//  Copyright © 2016年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  PJsendImageDelegate<NSObject>

-(void)PJsendImage:(UIImage *)image AndIsOriginal:(BOOL)isOriginal;

@end

@interface PJImageDetailController : UIViewController

-(instancetype)initWithImage:(UIImage *)image AndImageDic:(NSDictionary *)info;
@property(nonatomic,weak)id<PJsendImageDelegate> pjsendImageDelegate;

@end
