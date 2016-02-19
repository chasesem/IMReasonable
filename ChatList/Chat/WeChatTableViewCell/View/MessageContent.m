//
//  MessageContent.m
//  KeyBoard
//
//  Created by apple on 15/6/1.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "MessageContent.h"
#import "TQRichTextView.h"
#import "StateView.h"
#import "WeChat.h"


@implementation MessageContent
{
    TQRichTextView * _txtContent; //用于显示聊天文本的
    UILabel *_username;//用于显示对方的姓名的
    UILabel * _line;  //用于设置分割线，
    StateView * _stateview; //状态视图

}

-(instancetype)init{
    self=[super init];
    
    if (self) {
        self.backgroundImage=[[UIImageView alloc] init];
        [self addSubview:self.backgroundImage];
        _txtContent= [[TQRichTextView alloc]init];
         _txtContent.delegage=self;
        _txtContent.font = [UIFont systemFontOfSize:MESSAGECONNECTSIZE];
        _txtContent.lineSpace = 2.0f;
        _txtContent.backgroundColor = [UIColor clearColor];
        
        
        [self addSubview:_txtContent];
        
        _username=[[UILabel alloc] init];
        _username.textColor=[UIColor colorWithRed:0.1 green:0.5 blue:0.2 alpha:1];//[UIColor colorWithRed:0.3 green:0.2 blue:0.6 alpha:1];
        [_username setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
         [self addSubview:_username];
        
        _line=[[UILabel alloc] init];
        _line.backgroundColor=[UIColor grayColor];//[UIColor colorWithRed:0.1 green:0.5 blue:0.2 alpha:1];
        [self addSubview:_line];
        
        
        _stateview=[[StateView alloc]init];
        //_stateview.backgroundColor=[UIColor redColor];
        [self addSubview:_stateview];
        

        
    }
    
    return self;
}

- (void)setMessagemode:(MessageModel *)messagemode isNeedName:(BOOL)isName
{
    _messagemode=messagemode;
    _txtContent.text=messagemode.content;
    _username.text=messagemode.username;
    [_stateview setStateviewData:messagemode];
    
   // _txtContent.backgroundColor=[UIColor grayColor];
    CGRect rect=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height+5);
    
    self.backgroundImage.frame=rect;
    if (messagemode.isFromMe) {
        
        UIImage *bubble =[UIImage imageNamed:@"BubbleOutgoing"] ;
        CGFloat top =10; // 顶端盖高度
        CGFloat left = bubble.size.width/2 ; // 底端盖高度
        CGFloat bottom = bubble.size.height - top + 1; // 左端盖宽度
        CGFloat right = bubble.size.width - left - 1; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        self.backgroundImage.image=[bubble resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
          _txtContent.frame=CGRectMake(5, 2, self.frame.size.width-15, self.frame.size.height);
          _stateview.frame=CGRectMake(self.frame.size.width-53, self.frame.size.height-10, 45, 10);
        
        

    }else{
        
        //设置背景气泡
        UIImage *bubble =[UIImage imageNamed:@"BubbleIncoming"];
        CGFloat top =10; // 顶端盖高度
        CGFloat left = bubble.size.width/2 ; // 底端盖高度
        CGFloat bottom = bubble.size.height - top + 1; // 左端盖宽度
        CGFloat right = bubble.size.width - left - 1; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
       self.backgroundImage.image=[bubble resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
        NSLog(@"%@",self.messagemode.content);
        
        //设置聊天的内容
        CGFloat offset=0;
        if (isName) {
            offset=22;
            _username.hidden=NO;
            _line.hidden=NO;
        }else{
            offset=2;
            _username.hidden=YES;
            _line.hidden=YES;
        }
     
         _txtContent.frame=CGRectMake(15, offset, self.frame.size.width-15-13, self.frame.size.height-offset+2); //设置文本内容
        _username.frame=CGRectMake(15, 0, self.frame.size.width-15, offset-3); //设置显示用户的名字
        _line.frame=CGRectMake(15, offset-3, self.frame.size.width-15-5, 1);  //设置分割线
        
        
          _stateview.frame=CGRectMake(self.frame.size.width-30, self.frame.size.height-10, 25, 10);
       
    }
    
  
    
    

}

#pragma mark-富文本代理事件

- (void)richTextView:(TQRichTextView *)view touchBeginRun:(TQRichTextRun *)run

{
    
}
- (void)richTextView:(TQRichTextView *)view touchEndRun:(TQRichTextRun *)run
{
    if ([run isKindOfClass:[TQRichTextRunURL class]])
    {
      //  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:run.text]];
        
        [self.delegate touchMessageContent:run.text withType:TouchContentTypeURL];
    }
    
    NSLog(@"%@",run.text);
}
- (void)richTextView:(TQRichTextView *)view touchCanceledRun:(TQRichTextRun *)run
{
}


#pragma mark- 希望把粗磨事件传到下一层
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
//    return YES;
//}


//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    return self;
//}

-(void)dealloc{
    self.delegate=nil;
    _txtContent.delegage=nil;
}

@end
