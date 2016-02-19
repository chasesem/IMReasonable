//
//  SpreadEmailPreviewCell.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/11/19.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "SpreadMailModel.h"
#import "SpreadEmailPreviewCell.h"
#import "IMMessage.h"
#import "MJExtension.h"

#define IDENTIFIER @"SpreadEmailPreviewCell"

@implementation SpreadEmailPreviewCell

-(void)setMessage:(IMMessage *)message{
    NSString *emailJson=message.body;
    SpreadMailModel *model=[SpreadMailModel mj_objectWithKeyValues:[emailJson stringByReplacingOccurrencesOfString:@"'" withString:@"\""]];
    self.emailModel=model;
    self.emailSender.text=[NSString stringWithFormat:@"%@:",model.campaign_from];
    self.emailSubject.text=model.campaign_subject;
    NSString *temptime=message.date;
    NSString *displaytime=[Tool getDisplayTime:message.date];
    NSString *time=NSLocalizedString(displaytime, displaytime);
    //添加小时和分钟
        NSDate *  date=[NSDate date];
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyy-mm-dd HH:mm:ss"];
        date=[dateformatter dateFromString:temptime];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *componentsH = [cal components:NSHourCalendarUnit fromDate:date];
        NSString *H = [NSString stringWithFormat:@"%ld", (long)[componentsH hour]];
        NSDateComponents *componentsM = [cal components:NSMinuteCalendarUnit fromDate:date];
        NSString *M = [NSString stringWithFormat:@"%ld", (long)[componentsM minute]];
        time=[NSString stringWithFormat:@"%@ %@:%@",time,H,M];
    self.emailReceiveTime.text=time;
    self.emailReceiveTime.font=[UIFont systemFontOfSize:11];
    self.emailReceiveTime.textColor=[UIColor grayColor];
    self.emailContent.text=model.CampaignContent;
    self.emailModel=model;
    self.emailBg.layer.masksToBounds=YES;
    self.emailBg.layer.cornerRadius=6;
    
}

+(instancetype)cellWithTableView:(UITableView *)tableView{
    SpreadEmailPreviewCell *cell=[tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if(!cell){
        
        [tableView registerNib:[UINib nibWithNibName:IDENTIFIER bundle:nil] forCellReuseIdentifier:IDENTIFIER];
        cell=[tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    }
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
