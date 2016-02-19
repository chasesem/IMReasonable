//
//  PJButton.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/12/10.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "PJButton.h"

@implementation PJButton

-(void)setTalkkingImage:(UIImage *)talkkingImage{
    [self setImage:talkkingImage forState:UIControlStateNormal];
    _talkkingImage=talkkingImage;
    self.hasAddPhoto=true;
}

@end
