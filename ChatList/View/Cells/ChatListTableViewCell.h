//
//  ChatListTableViewCell.h
//  IMReasonable
//
//  Created by apple on 14/10/31.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *userphoto;
@property (retain, nonatomic) IBOutlet UILabel *username;
@property (retain, nonatomic) IBOutlet UILabel *message;
@property (retain, nonatomic) IBOutlet UILabel *messagetime;
@property (retain, nonatomic) IBOutlet UILabel *messagecount;

@end
