//
//  SettingWithSwitchCell.m
//  IMReasonable
//
//  Created by 翁金闪 on 16/1/12.
//  Copyright © 2016年 Reasonable. All rights reserved.
//

#import "SettingWithSwitchCell.h"
#import "AppDelegate.h"
#define SWITCH_W 16
#define SWITCH_H 10

@interface SettingWithSwitchCell()

@property(nonatomic,strong)UISwitch *switchButton;

@end

@implementation SettingWithSwitchCell

-(instancetype)initWithType:(int)type AndStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        _switchButton=[[UISwitch alloc] init];
        _switchButton.frame=CGRectMake(0,0,SWITCH_W,SWITCH_H);
        self.accessoryView=_switchButton;
        _switchButton.tag=type;
        [_switchButton addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        BOOL boolValue = false;
        switch(type){
            case SWITCH_ALLOW_LANDSCAPE:
                boolValue=[defaults boolForKey:ALLOW_LANDSCAPE];
                break;
            //其他类型的开关可在此处扩展
            case SWITCH_OPEN_ANIMATION:
                boolValue=[defaults boolForKey:OPEN_ANIMATION];
                break;
        }
        [_switchButton setOn:boolValue];
    }
    return self;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        _switchButton=[[UISwitch alloc] init];
        _switchButton.frame=CGRectMake(0,0,SWITCH_W,SWITCH_H);
        self.accessoryView=_switchButton;
        [_switchButton addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        BOOL allow_landscape=[defaults boolForKey:ALLOW_LANDSCAPE];
        [_switchButton setOn:allow_landscape];
    }
    return self;
}

-(void)changeValue:(id)sender{
    UISwitch *switchButton=(UISwitch *)sender;
    BOOL isOn=switchButton.isOn;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    switch(switchButton.tag){
        case SWITCH_ALLOW_LANDSCAPE:
            [defaults setBool:isOn forKey:ALLOW_LANDSCAPE];
            [self AllowLandscape:isOn];
            break;
            //其他类型的开关可在此处扩展
        case SWITCH_OPEN_ANIMATION:
            [defaults setBool:isOn forKey:OPEN_ANIMATION];
            [self OpenAnimation:isOn];
            break;
    }
    [defaults synchronize];
}
-(void)AllowLandscape:(BOOL)allowLandscape{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = allowLandscape;
}

-(void)OpenAnimation:(BOOL)openAnimation{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.openAnimation = openAnimation;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
