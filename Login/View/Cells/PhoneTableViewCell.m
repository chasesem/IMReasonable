//
//  PhoneTableViewCell.m
//  IMReasonable
//
//  Created by apple on 14/12/19.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "PhoneTableViewCell.h"

@implementation PhoneTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PhoneTableViewCell" owner:self options:nil];
        self = [array objectAtIndex:0];
        self.selectionStyle=UITableViewCellSelectionStyleNone;
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
