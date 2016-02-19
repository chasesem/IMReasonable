//
//  GroupSubTitleTableViewCell.m
//  IMReasonable
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "GroupSubTitleTableViewCell.h"

@implementation GroupSubTitleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GroupSubTitleTableViewCell" owner:self options:nil];
        self = [array objectAtIndex:0];
        //取消cell选中状态
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
