//
//  EmailDetailViewController.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/11/19.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

@class SpreadMailModel;

#import <UIKit/UIKit.h>

@interface EmailDetailViewController : UIViewController<UIWebViewDelegate>

@property(nonatomic,strong)SpreadMailModel *model;

@end
