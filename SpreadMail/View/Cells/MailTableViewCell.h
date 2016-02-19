//
//  MailTableViewCell.h
//  IMReasonable
//
//  Created by apple on 15/9/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//



@class IMChatListModle;
#import <UIKit/UIKit.h>

@interface MailTableViewCell : UITableViewCell

+(instancetype)MailCell;
+(instancetype)cellWithTableView:(UITableView *)tableView;
//@property (weak, nonatomic) IBOutlet UILabel *spreadTitle;
//@property (weak, nonatomic) IBOutlet UILabel *sendName;
//@property (weak, nonatomic) IBOutlet UILabel *sendTime;
//@property (weak, nonatomic) IBOutlet UILabel *emailCount;
//@property (weak, nonatomic) IBOutlet UIImageView *emailImage;
@property(nonatomic,strong)IMChatListModle *chatListModle;


@end
