//
//  WeChatKeyBoard.h
//  KeyBoard
//
//  Created by apple on 15/5/26.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailKeyBoard.h"
#import "MBProgressHUD.h"
#import "LVRecordTool.h"

#import "Mp3Recorder.h"
#import "UUProgressHUD.h"

@protocol WeChatKeyBoardDelegate;


@interface WeChatKeyBoard : UIView<UITextFieldDelegate,UITextViewDelegate,DetailKeyBoardDelegate,LVRecordToolDelegate,Mp3RecorderDelegate>


@property(nonatomic,assign)BOOL hidekey;

@property(nonatomic,retain) UIColor * wechatkeyboard;
@property (nonatomic,weak) id<WeChatKeyBoardDelegate> delegate;

-(void)hideKeyboard;
- (id)init:(UIViewController *) viewcontrol;
-(void)setText:(NSString *)txt;
-(NSString *)getText;
- (void)cancelRecordVoice:(UIButton *)button;

@end

//键盘协议
@protocol WeChatKeyBoardDelegate <NSObject>

@optional   //加上该字段意味着不实现代理方法也不会报警告
- (void) sendTextContent:(NSString *)txtvalue; //点击发送后纯文本
- (void) sendVoiceContent:(NSString *)voicePath voicedata:(NSData*)data voicelenth:(double)voicelenth; // 返回的是语言存储位置和时常
- (void) choiceFuction:(NSUInteger )functionid; //更多功能选择
- (void) WeChatKeyBoardY:(CGFloat )y; //每次键盘跳转高度是 键盘的y值

@end
