//
//  SelectCountryTableViewCell.m
//  IMReasonable
//
//  Created by apple on 15/1/8.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "SelectCountryTableViewCell.h"

@implementation SelectCountryTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SelectCountryTableViewCell" owner:self options:nil];
        self = [array objectAtIndex:0];
        //self.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    return self;
}
@end
