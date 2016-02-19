//
//  NeedTipsTableViewCell.m
//  IMReasonable
//
//  Created by apple on 15/7/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "NeedTipsTableViewCell.h"

@implementation NeedTipsTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
//        //图像
//        self.groupface=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
//        self.groupface.layer.masksToBounds = YES;
//        self.groupface.layer.cornerRadius = 20;
//        
//        
//        //编辑头像
//        self.editface=[[UIButton alloc]initWithFrame:CGRectMake(10, 45, 40, 20)];
//        [self.editface setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        [self.editface setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
//        [self.editface.titleLabel setFont:[UIFont systemFontOfSize:11]];
        // [self.editface ]
        
        //头像
        self.title=[[UILabel alloc] initWithFrame:CGRectMake(10, 2, 150*ratioW, 40)];
        //[self.title setTextColor:[UIColor grayColor]];
       // self.title.backgroundColor=[UIColor redColor];
        
        self.isNeedTips=[[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH-60, 7, 30, 20)];
        [self.isNeedTips setOn:YES];
        self.isNeedTips.onTintColor=[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];;
      
        
        
        [self.contentView addSubview:self.title];
        [self.contentView addSubview: self.isNeedTips];
   
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
