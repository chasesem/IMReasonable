//
//  VoiceContent.m
//  KeyBoard
//
//  Created by apple on 15/6/8.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "VoiceContent.h"
#import "UUAVAudioPlayer.h"
#import "StateView.h"
#import "AnimationHelper.h"

@interface VoiceContent()

@property(nonatomic,weak)UILabel *from;
@property(nonatomic,weak)UILabel *line;
@property(nonatomic,assign)BOOL hasVoice;

@end

@implementation VoiceContent
{
    
    UILabel * _voicetime;
    UIImageView * _voiceAm;
    UIActivityIndicatorView *_voiceload;
    
     BOOL contentVoiceIsPlaying;
    UUAVAudioPlayer *audio;
    StateView * _stateview; //状态视图


}

-(instancetype)init{
    self=[super init];
    
    if (self) {
        
        self.backgroundImage=[[UIImageView alloc] init];
        [self addSubview:self.backgroundImage];
        _voicetime = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 70, 30)];
        _voicetime.textAlignment = NSTextAlignmentCenter;
        _voicetime.font = [UIFont systemFontOfSize:12];
        _voiceAm = [[UIImageView alloc]initWithFrame:CGRectMake(80, 5, 20, 20)];
        _voiceAm.image = [UIImage imageNamed:@"chat_animation_white3"];
        _voiceAm.animationImages = [NSArray arrayWithObjects:
                                    [UIImage imageNamed:@"chat_animation_white1"],
                                    [UIImage imageNamed:@"chat_animation_white2"],
                                    [UIImage imageNamed:@"chat_animation_white3"],nil];
        _voiceAm.animationDuration = 1;
        _voiceAm.animationRepeatCount = 0;
        _voiceload = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _voiceload.center=CGPointMake(80, 15);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopvoice)
                                                     name:@"STOPVOICE"
                                                   object:nil];
        
        UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(voiceClick:)];
        singleFingerOne.numberOfTouchesRequired = 1; //手指数
        singleFingerOne.numberOfTapsRequired = 1; //tap次数
        
        [self addGestureRecognizer:singleFingerOne];
        
        _stateview=[[StateView alloc]init];
        UILabel *from=[[UILabel alloc] init];
        self.from=from;
        self.from.textColor=[UIColor colorWithRed:0.1 green:0.5 blue:0.2 alpha:1];
        [self.from setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
        UILabel *line=[[UILabel alloc] init];
        self.line=line;
        self.line.backgroundColor=[UIColor grayColor];
        [self addSubview:from];
        [self addSubview:line];
        [self addSubview:_stateview];
        [self addSubview:_voicetime];
        [self addSubview:_voiceAm];
        [self addSubview:_voiceload];
    

        _voicetime.userInteractionEnabled = NO;
        _voiceAm.userInteractionEnabled = YES;
        
       _voiceAm.backgroundColor = [UIColor clearColor];
        _voicetime.backgroundColor = [UIColor clearColor];
        _voiceload.backgroundColor = [UIColor clearColor];

        
    }
    
    return self;
}

- (void)voiceClick:(UITapGestureRecognizer *)tap{
    
    if(self.hasVoice){
        
        audio = [UUAVAudioPlayer sharedInstance];
        audio.delegate =self;
        
        
        if(!audio.player.isPlaying){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            [audio playSongWithUrl:self.messagemode.voicepath];
        }else{
            [self UUAVAudioPlayerDidFinishPlay];
        }
    }else{
        
        [AnimationHelper show:NSLocalizedString(@"VOICE_HAS_DELETED", nil) InView:[UIApplication sharedApplication].keyWindow];
    }
}

- (void)UUAVAudioPlayerBeiginLoadVoice
{
    _voiceAm.hidden = YES;
    [_voiceload startAnimating];
}
- (void)UUAVAudioPlayerBeiginPlay
{
    //开启红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    _voiceAm.hidden = NO;
    [_voiceload stopAnimating];
    [_voiceAm startAnimating];
}
- (void)UUAVAudioPlayerDidFinishPlay
{
    //关闭红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
  //  contentVoiceIsPlaying = NO;
     [_voiceAm stopAnimating];
    [[UUAVAudioPlayer sharedInstance]stopSound];
}

- (void)stopvoice{
    //关闭红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    //  contentVoiceIsPlaying = NO;
    [_voiceAm stopAnimating];
    [[UUAVAudioPlayer sharedInstance]stopSound];
}




- (void)setMessagemode:(MessageModel *)messagemode isNeedName:(BOOL)isName{
    
    self.from.text=messagemode.username;
    _messagemode=messagemode;
    CGRect rect=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
      [_stateview setStateviewData:messagemode];
    
    self.backgroundImage.frame=rect;
    
    if (messagemode.isFromMe) {
        _voicetime.textColor = [UIColor grayColor];
//        UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chatto_bg_normal" ofType:@"png"]];
//        self.backgroundImage.image=[bubble resizableImageWithCapInsets:UIEdgeInsetsMake(49, 97, 57, 118) resizingMode:UIImageResizingModeStretch];
        
        UIImage *bubble =[UIImage imageNamed:@"BubbleOutgoing"] ;
        CGFloat top =10; // 顶端盖高度
        CGFloat left = bubble.size.width/2 ; // 底端盖高度
        CGFloat bottom = bubble.size.height - top + 1; // 左端盖宽度
        CGFloat right = bubble.size.width - left - 1; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        self.backgroundImage.image=[bubble resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
         _stateview.frame=CGRectMake(120-50, 40-15, 45, 10);
    }else{
        
         _voicetime.textColor = [UIColor grayColor];
        _voicetime.frame=CGRectMake(15, 5, 70, 30);
        _voiceAm.frame=CGRectMake(95, 10, 20, 20);
        //设置聊天的内容
        CGFloat offset=0;
        if (isName) {
            offset=22;
            self.from.hidden=NO;
            self.line.hidden=NO;
        }else{
            offset=2;
            self.from.hidden=YES;
            self.line.hidden=YES;
        }
        self.from.frame=CGRectMake(15, 0, [self.from sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)].width, offset-3); //设置显示用户的名字
        self.line.frame=CGRectMake(15, offset-3, self.frame.size.width-15-5, 1);  //设置分割线

        //设置背景气泡
        UIImage *bubble =[UIImage imageNamed:@"BubbleIncoming"];
        CGFloat top =10; // 顶端盖高度
        CGFloat left = bubble.size.width/2 ; // 底端盖高度
        CGFloat bottom = bubble.size.height - top + 1; // 左端盖宽度
        CGFloat right = bubble.size.width - left - 1; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        self.backgroundImage.image=[bubble resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        

       _stateview.frame=CGRectMake(120-30, 40-15, 25, 10);
    
        
        
        CGSize maxSize=CGSizeMake(MAXFLOAT, MAXFLOAT);
        _voicetime.text=[NSString stringWithFormat:@"%@ 's Voice",messagemode.content];
        CGSize size=[_voicetime sizeThatFits:maxSize];
        _voicetime.frame=(CGRect){self.from.frame.origin.x, CGRectGetMaxY(self.line.frame)+6, size};
        CGFloat fromMaxX=CGRectGetMaxX(self.from.frame);
        _voiceAm.frame=CGRectMake(CGRectGetMaxX(_voicetime.frame)+10,CGRectGetMaxY(self.line.frame)+3 ,20 ,20 );
        CGFloat voiceAmMaxX=CGRectGetMaxX(_voiceAm.frame);
        if(fromMaxX>voiceAmMaxX){
            
            _voiceAm.frame=CGRectMake(fromMaxX-20,_voiceAm.frame.origin.y , _voiceAm.frame.size.width, _voiceAm.frame.size.height);
        }
        voiceAmMaxX=CGRectGetMaxX(_voiceAm.frame);
        self.line.frame=CGRectMake(self.line.frame.origin.x, self.line.frame.origin.y,voiceAmMaxX-15 ,self.line.frame.size.height );
        _stateview.frame=CGRectMake(voiceAmMaxX-15, CGRectGetMaxY(_voiceAm.frame)+3,15 ,10 );
        CGRect rect=CGRectMake(0, 0, voiceAmMaxX+6, CGRectGetMaxY(_stateview.frame)+6);
        self.backgroundImage.frame=rect;
        self.voiceframe=rect;
        _stateview.frame=CGRectMake(self.voiceframe.size.width-15-15,_stateview.frame.origin.y ,_stateview.frame.size.width ,_stateview.frame.size.height );
                
    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:[Tool getVoicePath:self.messagemode.voicepath] isDirectory:false]){
        
        self.hasVoice=true;
    }else{
        
        self.hasVoice=false;
        _voiceAm.image = [UIImage imageNamed:@"no_voice"];
    }
}

 -(void)dealloc{
     
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"STOPVOICE" object:nil];
}

@end
