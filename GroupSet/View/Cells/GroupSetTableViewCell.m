//
//  GroupSetTableViewCell.m
//  IMReasonable
//
//  Created by apple on 15/4/21.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "GroupSetTableViewCell.h"

@implementation GroupSetTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //图像
        self.groupface=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
        self.groupface.layer.masksToBounds = YES;
        self.groupface.layer.cornerRadius = 20;
     
   
        //编辑头像
        self.editface=[[UIButton alloc]initWithFrame:CGRectMake(10, 45, 40, 20)];
        [self.editface setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.editface setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        [self.editface.titleLabel setFont:[UIFont systemFontOfSize:11]];
       // [self.editface ]
        
        //头像
        self.subject=[[UILabel alloc] initWithFrame:CGRectMake(60, 20, 200, 20)];
        [self.subject setTextColor:[UIColor grayColor]];
        
    
        [self.contentView addSubview:self.groupface];
        [self.contentView addSubview:self.editface];
        [self.contentView addSubview:self.subject];
        
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
