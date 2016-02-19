//
//  PJButton.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/12/10.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PJButton : UIButton

//是否添加了图片
@property(nonatomic,assign)BOOL hasAddPhoto;
//该按钮的位置
@property(nonatomic,assign)int index;
//该按钮的图片
@property(nonatomic,strong)UIImage *talkkingImage;

@end
