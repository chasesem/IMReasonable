//
//  StateView.m
//  KeyBoard
//
//  Created by apple on 15/6/1.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "StateView.h"
#import "TimeLable.h"


@implementation StateView
-(instancetype)init{
    self=[super init];
    
    if (self) {
       
        self.time=[[TimeLable alloc] initWithFrame:CGRectMake(0, 0, 25, 10)];
        self.time.backgroundColor=[UIColor clearColor];
        self.time.font=[UIFont systemFontOfSize:9];
        self.time.textColor=[UIColor grayColor];
        self.time.contentMode=UIViewContentModeLeft;
        
        [self addSubview:self.time];
        
        self.imagestate=[[UIImageView alloc] initWithFrame:CGRectMake(25,0, 16, 10)];
        self.imagestate.contentMode=UIViewContentModeScaleAspectFit;
        self.imagestate.userInteractionEnabled=YES;
        [self addSubview:self.imagestate];
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reSend:)];
        [self.imagestate addGestureRecognizer: tap];

        self.backgroundColor=[UIColor clearColor];
        
    }
    
    return self;
}

-(void)reSend:(id)sender{
 
   // [Tool alert:@"重发"];

}

- (void)setStateviewData:(MessageModel*)message
{
    
    self.time.text=message.time;
    NSString * imagename;
//    if (message.type==MessageTypeVoice && message.isFromMe) {
//        self.time.textColor=[UIColor whiteColor];
//    }
    if (message.isFromMe) {
        if ([message.isNeedSend isEqualToString:@"1"]&&[message.isReceived isEqualToString:@"0"]) {//发送成功
            imagename=@"CheckSingleDark";
        }

        if ([message.isNeedSend isEqualToString:@"1"]&&[message.isReceived isEqualToString:@"1"]) {//对方已经接收成功
            imagename=@"CheckDoubleDark";
        }
        //新添加的
        if ([message.isNeedSend isEqualToString:@"2"]&&[message.isReceived  isEqualToString:@"0"]) {//正在发送
            imagename=@"";
        }
    }
    
    

    
    self.imagestate.image=[UIImage imageNamed:imagename];
}

@end
