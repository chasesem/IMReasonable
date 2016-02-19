//
//  WallpaperCollectionViewCell.m
//  IMReasonable
//
//  Created by apple on 15/6/23.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "WallpaperCollectionViewCell.h"

@implementation WallpaperCollectionViewCell

- (id)init{
    self = [super init];
    if (self) {
        
        self.img=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.seletedimg=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-30, self.frame.size.height-30, 30, 30)];
        
        [self.contentView addSubview:self.img];
        [self.contentView addSubview:self.seletedimg];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.img=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.seletedimg=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-35, self.frame.size.height-35, 30, 30)];
        
        [self.contentView addSubview:self.img];
        [self.contentView addSubview:self.seletedimg];
    }
    return self;
}
@end
