//
//  PJImageView.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/12/21.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

@class PJPhoto,PJImageView;

#import <UIKit/UIKit.h>

@protocol PJPhotoViewDelegate <NSObject>
- (void)hideBar:(BOOL)hide;
@end

@interface PJImageView : UIScrollView

@property(nonatomic,strong)PJPhoto *photo;
@property(nonatomic,weak)id<PJPhotoViewDelegate> photoViewDelegate;

@end
