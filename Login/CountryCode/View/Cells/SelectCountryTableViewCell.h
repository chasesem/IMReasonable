//
//  SelectCountryTableViewCell.h
//  IMReasonable
//
//  Created by apple on 15/1/8.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCountryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *country;
@property (weak, nonatomic) IBOutlet UILabel *countrycode;
@property (weak, nonatomic) IBOutlet UIImageView *isSelect;

@end
