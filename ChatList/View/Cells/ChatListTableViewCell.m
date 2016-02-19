//
//  ChatListTableViewCell.m
//  IMReasonable
//
//  Created by apple on 14/10/31.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//



#import "ChatListTableViewCell.h"

@implementation ChatListTableViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideMessageCount)
                                                     name:@"HIDEMESSAGECOUNT"
                                                   object:nil];
        
        self.userphoto=[[UIImageView alloc]initWithFrame:CGRectMake(8, 7, 50, 50)];
        self.userphoto.layer.masksToBounds = YES;
        self.userphoto.layer.cornerRadius = 25;
        
        self.username=[[UILabel alloc] initWithFrame:CGRectMake(71 , 3, 150*ratioW, 27)];
        self.username.font=[UIFont systemFontOfSize:17];
        self.username.textColor=[UIColor blackColor];
        // self.username.backgroundColor=[UIColor greenColor];
        
        self.message=[[UILabel alloc] initWithFrame:CGRectMake(71 , 32, 205*ratioW, 30)];
        self.message.font=[UIFont systemFontOfSize:14];
        self.message.textColor=[UIColor grayColor];
        // self.message.backgroundColor=[UIColor yellowColor];
        
        
        self.messagetime=[[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-80*ratioW-10, 0, 80*ratioW, 21)];
        self.messagetime.font=[UIFont systemFontOfSize:11];
        self.messagetime.textColor=[UIColor grayColor];
        // self.messagetime.backgroundColor=[UIColor blueColor];
        self.messagetime.textAlignment=NSTextAlignmentRight;
        
        self.messagecount=[[UILabel alloc] initWithFrame:CGRectMake(283*ratioW , 35, 26, 26)];
        self.messagecount.font=[UIFont systemFontOfSize:14];
        self.messagecount.textColor=[UIColor grayColor];
        self.messagecount.backgroundColor=[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];//[UIColor blueColor];
        self.messagecount.textColor=[UIColor whiteColor];
        self.messagecount.textAlignment=NSTextAlignmentCenter;
        self.messagecount.layer.masksToBounds=YES;
        self.messagecount.layer.cornerRadius=13;
        self.messagecount.hidden=YES;
        
        [self.contentView addSubview:self.username];
        [self.contentView addSubview:self.messagetime];
        [self.contentView addSubview:self.message];
        [self.contentView addSubview:self.userphoto];
        [self.contentView addSubview:self.messagecount];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      
       self.userphoto=[[UIImageView alloc]initWithFrame:CGRectMake(8, 7, 50, 50)];
       self.userphoto.layer.masksToBounds = YES;
       self.userphoto.layer.cornerRadius = 25;
        
        self.username=[[UILabel alloc] initWithFrame:CGRectMake(71 , 3, 150*ratioW, 27)];
        self.username.font=[UIFont systemFontOfSize:17];
        self.username.textColor=[UIColor blackColor];
       // self.username.backgroundColor=[UIColor greenColor];
        
        self.message=[[UILabel alloc] initWithFrame:CGRectMake(71 , 32, 205*ratioW, 30)];
        self.message.font=[UIFont systemFontOfSize:14];
        self.message.textColor=[UIColor grayColor];
       // self.message.backgroundColor=[UIColor yellowColor];
        
        
        self.messagetime=[[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-80*ratioW-10, 0, 80*ratioW, 21)];
        self.messagetime.font=[UIFont systemFontOfSize:11];
        self.messagetime.textColor=[UIColor grayColor];
       // self.messagetime.backgroundColor=[UIColor blueColor];
        self.messagetime.textAlignment=NSTextAlignmentRight;
        
        self.messagecount=[[UILabel alloc] initWithFrame:CGRectMake(283*ratioW , 35, 26, 26)];
        self.messagecount.font=[UIFont systemFontOfSize:14];
        self.messagecount.textColor=[UIColor grayColor];
        self.messagecount.backgroundColor=[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];//[UIColor blueColor];
        self.messagecount.textColor=[UIColor whiteColor];
        self.messagecount.textAlignment=NSTextAlignmentCenter;
        self.messagecount.layer.masksToBounds=YES;
        self.messagecount.layer.cornerRadius=13;
        self.messagecount.hidden=YES;
        
        [self.contentView addSubview:self.username];
        [self.contentView addSubview:self.messagetime];
        [self.contentView addSubview:self.message];
        [self.contentView addSubview:self.userphoto];
        [self.contentView addSubview:self.messagecount];
        
        
             
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
   ///self.userphoto.layer.masksToBounds = YES;
  /// self.userphoto.layer.cornerRadius = 30;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)hideMessageCount{
    self.messagecount.hidden=YES;
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
