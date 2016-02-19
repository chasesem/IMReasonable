//
//  GroupPhotoTableViewCell.h
//  IMReasonable
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupPhotoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *groupphoto;
@property (weak, nonatomic) IBOutlet UIButton *groupSelectPhoto;
@property (weak, nonatomic) IBOutlet UILabel *msgTitle;

@end
