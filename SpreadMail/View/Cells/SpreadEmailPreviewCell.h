//
//  SpreadEmailPreviewCell.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/11/19.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

@class SpreadMailModel,IMMessage;

#import <UIKit/UIKit.h>

@interface SpreadEmailPreviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *emailReceiveTime;
@property (weak, nonatomic) IBOutlet UILabel *emailSender;
@property (weak, nonatomic) IBOutlet UILabel *emailSubject;
@property (weak, nonatomic) IBOutlet UILabel *emailContent;
@property (weak, nonatomic) IBOutlet UIView *emailBg;
+(instancetype)cellWithTableView:(UITableView *)tableView;
@property(nonatomic,strong)SpreadMailModel *emailModel;
@property(nonatomic,strong)IMMessage* message;


@end
