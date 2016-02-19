//
//  GroupUserTableViewCell.m
//  IMReasonable
//
//  Created by apple on 15/4/21.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "GroupUserTableViewCell.h"

@implementation GroupUserTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //用户头像
        self.userface=[[UIImageView alloc]initWithFrame:CGRectMake(10, 1, 42, 42)];
        self.userface.layer.masksToBounds = YES;
        self.userface.layer.cornerRadius = 21;
        
        
        //用户名字
        self.username=[[UILabel alloc]initWithFrame:CGRectMake(62, 2, 150*ratioW, 40)];
        [self.username setTextColor:[UIColor blackColor]];
       // self.username.backgroundColor=[UIColor redColor];
        
        //用户角色
        self.userrole=[[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-60*ratioW-10, 11, 60*ratioW, 22)];
        [self.userrole setTextColor:[UIColor redColor]];
        [self.userrole setTextAlignment:NSTextAlignmentRight];
       // self.userrole.backgroundColor=[UIColor yellowColor];
        
        
        [self.contentView addSubview:self.userface];
        [self.contentView addSubview:self.username];
        [self.contentView addSubview:self.userrole];
        
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
