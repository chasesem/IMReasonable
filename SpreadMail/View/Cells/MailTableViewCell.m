//
//  MailTableViewCell.m
//  IMReasonable
//
//  Created by apple on 15/9/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//



#define SPREAD_EMAIL @"SPREAD_EMAIL"
#define SPREAD_EMAIL_PROMPT @"SPREAD_EMAIL_PROMPT"
#define EMAIL_IMAGE_R 25//由xib中邮件的图标的宽的大小(为其一半)决定(图标为正方形)
#define EMAIL_MESSAGE_COUNT_R 13//与上面同理

#import "SPreadMailModel.h"
#import "MailTableViewCell.h"
#import "Tool.h"
#import "IMChatListModle.h"
#import "MJExtension.h"

@interface MailTableViewCell ()

@property (weak, nonatomic) UILabel *spreadTitle;
@property (weak, nonatomic) UILabel *sendName;
@property (weak, nonatomic) UILabel *sendTime;
@property (weak, nonatomic) UILabel *emailCount;
@property (weak, nonatomic) UIImageView *emailImage;


@end

@implementation MailTableViewCell

//通过xib初始化
+(instancetype)MailCell{
    return [[[NSBundle mainBundle] loadNibNamed:@"MailTableViewCell" owner:nil options:nil] lastObject];
}

-(void)setChatListModle:(IMChatListModle *)chatListModle{
    NSString *emailJson=chatListModle.messagebody.body;
    SpreadMailModel *emailModel=[SpreadMailModel mj_objectWithKeyValues:[emailJson stringByReplacingOccurrencesOfString:@"'" withString:@"\""]];
    self.sendName.text=[NSString stringWithFormat:@"%@:%@",emailModel.campaign_from,emailModel.campaign_subject];
    self.sendTime.text=NSLocalizedString(chatListModle.messagebody.date, chatListModle.messagebody.date);
    self.spreadTitle.text=NSLocalizedString(SPREAD_EMAIL_PROMPT, nil);
    if([chatListModle.unreadcount intValue]>0){
        
        self.emailCount.hidden=NO;
        self.emailCount.text=[chatListModle.unreadcount intValue]>99?@"99":chatListModle.unreadcount;
    }else{
        
        self.emailCount.hidden=YES;
    }
}

+(instancetype)cellWithTableView:(UITableView *)tableView{
  static NSString *ID=SPREAD_EMAIL;
    MailTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell){
        
        [tableView registerNib:[UINib nibWithNibName:@"MailTableViewCell" bundle:nil] forCellReuseIdentifier:ID];
        cell=[tableView dequeueReusableCellWithIdentifier:ID];
    }
    return cell;
}

- (CGSize)boundingRectWithSize:(CGSize)size WithLabel:(UILabel *)label
{
    NSDictionary *attribute = @{NSFontAttributeName: label.font};
    
    CGSize retSize = [label.text boundingRectWithSize:size
                                             options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                          attributes:attribute
                                             context:nil].size;
    
    return retSize;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        self.spreadTitle.text=NSLocalizedString(SPREAD_EMAIL_PROMPT, nil);
        self.emailCount.font=[UIFont systemFontOfSize:14];
        self.emailCount.backgroundColor=[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];
        self.emailCount.textColor=[UIColor whiteColor];
        self.emailCount.textAlignment=NSTextAlignmentCenter;
        self.emailCount.layer.masksToBounds=YES;
        self.emailCount.layer.cornerRadius=13;
        self.emailCount.hidden=YES;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        
        //邮件标题
        UILabel *spreadTitle=[[UILabel alloc] initWithFrame:CGRectMake(71 , 3, 150*ratioW, 27)];
        [self.contentView addSubview:spreadTitle];
        self.spreadTitle=spreadTitle;
        self.spreadTitle.font=[UIFont systemFontOfSize:17];
        self.spreadTitle.textColor=[UIColor blackColor];
        //发件人即邮件标题
        UILabel *sendName=[[UILabel alloc] initWithFrame:CGRectMake(71 , 32, 205*ratioW, 30)];
        [self.contentView addSubview:sendName];
        self.sendName=sendName;
        self.sendName.font=[UIFont systemFontOfSize:14];
        self.sendName.textColor=[UIColor grayColor];
        //发送时间
        UILabel *sendTime=[[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH-80*ratioW-10, 0, 80*ratioW, 21)];
        [self.contentView addSubview:sendTime];
        self.sendTime=sendTime;
        self.sendTime.font=[UIFont systemFontOfSize:11];
        self.sendTime.textColor=[UIColor grayColor];
        self.sendTime.textAlignment=NSTextAlignmentRight;
        //新邮件数量
        UILabel *emailCount=[[UILabel alloc] initWithFrame:CGRectMake(283*ratioW , 35, 26, 26)];
        [self.contentView addSubview:emailCount];
        self.emailCount=emailCount;
        self.emailCount.font=[UIFont systemFontOfSize:14];
        self.emailCount.textColor=[UIColor grayColor];
        self.emailCount.backgroundColor=[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];
        self.emailCount.textColor=[UIColor whiteColor];
        self.emailCount.textAlignment=NSTextAlignmentCenter;
        self.emailCount.layer.masksToBounds=YES;
        self.emailCount.layer.cornerRadius=13;
        self.emailCount.hidden=YES;
        //邮件图标
        UIImageView *emailImage=[[UIImageView alloc] initWithFrame:CGRectMake(8, 7, 50, 50)];
        [self.contentView addSubview:emailImage];
        self.emailImage=emailImage;
        self.emailImage.layer.masksToBounds = YES;
        self.emailImage.layer.cornerRadius = 25;
        [self.emailImage setImage:[UIImage imageNamed:@"email_100px"]];
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
