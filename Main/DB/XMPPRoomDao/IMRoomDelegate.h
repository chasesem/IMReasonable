//
//  IMRoomDelegate.h
//  IMReasonable
//
//  Created by apple on 15/3/19.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#ifndef IMReasonable_IMRoomDelegate_h
#define IMReasonable_IMRoomDelegate_h

@protocol RoomHelerpDelegate <NSObject>

@optional   //加上该字段意味着不实现代理方法也不会报警告
//状态为0的时候是创建房间失败，可能是房间名重复了
//状态为1的为配置房间出错
//状态为2是创建成功，房间还未配置
//状态为3是为创建成功
- (void) creatRoomResult:(int)state;
- (void) GetRoomConfigForm:(NSMutableDictionary*)configform;
@end

#endif
