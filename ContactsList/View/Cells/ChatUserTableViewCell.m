//
//  ChatUserTableViewCell.m
//  IMReasonable
//
//  Created by apple on 14/12/23.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "ChatUserTableViewCell.h"

@implementation ChatUserTableViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        
        self.userphoto=[[UIImageView alloc]initWithFrame:CGRectMake(8, 7, 42, 42)];
        self.userphoto.layer.masksToBounds = YES;
        self.userphoto.layer.cornerRadius = 21;
        
        self.username=[[UILabel alloc] initWithFrame:CGRectMake(55 , 7, 150*ratioW, 22)];
        self.username.font=[UIFont systemFontOfSize:17];
        self.username.textColor=[UIColor blackColor];
        
        self.phoneown=[[UILabel alloc] initWithFrame:CGRectMake(60 , 29, 150*ratioW-5, 20)];
        self.phoneown.font=[UIFont systemFontOfSize:11];
        self.phoneown.textColor=[UIColor grayColor];
        
        
        self.device=[[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-95 , 16, 85, 22)];
        self.device.textAlignment=NSTextAlignmentRight;
        self.device.font=[UIFont systemFontOfSize:11];
        self.device.textColor=[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];//[UIColor greenColor];
        
        self.invite=[UIButton buttonWithType:UIButtonTypeCustom];
        //        [self.invite setFrame:CGRectMake(SCREENWIDTH-70 , 8, 60, 40)];
        self.invite.frame=CGRectMake(SCREENWIDTH-70, 8, 60, 40);
        self.invite.layer.cornerRadius=10.0;
        [self.invite setTitle:NSLocalizedString(@"lbcutinvite", nil) forState:UIControlStateNormal];//lbcutinvite
        [self.invite setTitle:NSLocalizedString(@"lbcutinvite", nil) forState:UIControlStateHighlighted];
        [self.invite setBackgroundColor:[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1]];//[UIColor lightTextColor]];
        //  self.invite.buttonType=UIButtonTypeRoundedRect;
        [self.invite setHidden:YES];
        
        
        
        
        //self.device.backgroundColor=[UIColor redColor];
        
        
        [self.contentView addSubview:self.username];
        [self.contentView addSubview:self.phoneown];
        [self.contentView addSubview:self.userphoto];
        [self.contentView addSubview:self.device];
        [self.contentView addSubview:self.invite];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.userphoto=[[UIImageView alloc]initWithFrame:CGRectMake(8, 7, 42, 42)];
        self.userphoto.layer.masksToBounds = YES;
        self.userphoto.layer.cornerRadius = 21;
        
        self.username=[[UILabel alloc] initWithFrame:CGRectMake(55 , 7, 150*ratioW, 22)];
        self.username.font=[UIFont systemFontOfSize:17];
        self.username.textColor=[UIColor blackColor];
        
        self.phoneown=[[UILabel alloc] initWithFrame:CGRectMake(60 , 29, 150*ratioW-5, 20)];
        self.phoneown.font=[UIFont systemFontOfSize:11];
        self.phoneown.textColor=[UIColor grayColor];
        
        
        self.device=[[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-95 , 16, 85, 22)];
        self.device.textAlignment=NSTextAlignmentRight;
        self.device.font=[UIFont systemFontOfSize:11];
        self.device.textColor=[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];//[UIColor greenColor];
        
        self.invite=[UIButton buttonWithType:UIButtonTypeCustom];
//        [self.invite setFrame:CGRectMake(SCREENWIDTH-70 , 8, 60, 40)];
        self.invite.frame=CGRectMake(SCREENWIDTH-70, 8, 60, 40);
        self.invite.layer.cornerRadius=10.0;
        [self.invite setTitle:NSLocalizedString(@"lbcutinvite", nil) forState:UIControlStateNormal];//lbcutinvite
        [self.invite setTitle:NSLocalizedString(@"lbcutinvite", nil) forState:UIControlStateHighlighted];
        [self.invite setBackgroundColor:[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1]];//[UIColor lightTextColor]];
      //  self.invite.buttonType=UIButtonTypeRoundedRect;
        [self.invite setHidden:YES];
        
        
        
        
        //self.device.backgroundColor=[UIColor redColor];

        
        [self.contentView addSubview:self.username];
        [self.contentView addSubview:self.phoneown];
        [self.contentView addSubview:self.userphoto];
        [self.contentView addSubview:self.device];
//        [self.contentView addSubview:self.invite];
        self.accessoryView=self.invite;

        
        
        
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
