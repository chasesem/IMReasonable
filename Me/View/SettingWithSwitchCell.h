//
//  SettingWithSwitchCell.h
//  IMReasonable
//
//  Created by 翁金闪 on 16/1/12.
//  Copyright © 2016年 Reasonable. All rights reserved.
//

typedef enum{
    SWITCH_ALLOW_LANDSCAPE, //是否开启横屏，其他类似setting可以扩展
    SWITCH_OPEN_ANIMATION //是否开启动画
} switchType;

#import <UIKit/UIKit.h>

@interface SettingWithSwitchCell : UITableViewCell

-(instancetype)initWithType:(int)type AndStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
