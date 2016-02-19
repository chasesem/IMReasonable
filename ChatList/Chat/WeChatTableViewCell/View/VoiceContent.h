//
//  VoiceContent.h
//  KeyBoard
//
//  Created by apple on 15/6/8.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"
#import "UUAVAudioPlayer.h"

@interface VoiceContent : UIView<UUAVAudioPlayerDelegate>

@property(nonatomic,assign)CGRect voiceframe;
@property (nonatomic,retain) UIImageView * backgroundImage;
@property (nonatomic,retain) MessageModel * messagemode;
- (void)setMessagemode:(MessageModel *)messagemode isNeedName:(BOOL)isName;

@end
