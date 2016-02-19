//
//  FunctionTableViewCell.m
//  IMReasonable
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "FunctionTableViewCell.h"

@implementation FunctionTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.mucListBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 7, 150, 42)];
        [self.mucListBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.mucListBtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        self.mucListBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.mucListBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        //[self.mucListBtn setBackgroundColor:[UIColor redColor]];
        
        self.mucChatBtn=[[UIButton alloc]initWithFrame:CGRectMake(SCREENWIDTH-150, 7, 150, 42)];
        [self.mucChatBtn setTitleColor:[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1] forState:UIControlStateNormal];
        [self.mucChatBtn setTitleColor:[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1] forState:UIControlStateHighlighted];
        self.mucChatBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.mucChatBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
          //[self.mucChatBtn setBackgroundColor:[UIColor yellowColor]];
     

        
        
        [self.contentView addSubview:self.mucListBtn];
        [self.contentView addSubview:self.mucChatBtn];
       // [self.contentView addSubview:self.userphoto];
       // [self.contentView addSubview:self.device];
        
        
        
        
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
