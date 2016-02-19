//
//  AddGroupUserTableViewCell.m
//  IMReasonable
//
//  Created by apple on 15/4/21.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "AddGroupUserTableViewCell.h"

@implementation AddGroupUserTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
  
        
        
        //编辑头像
        self.addgroupuser=[[UIButton alloc]initWithFrame:CGRectMake(0, 2, 200, 40)];
        [self.addgroupuser setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.addgroupuser setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        
        self.addgroupuser.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.addgroupuser.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        
        
        [self.contentView addSubview:self.addgroupuser];
        
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
