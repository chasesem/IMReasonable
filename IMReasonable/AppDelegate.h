//
//  AppDelegate.h
//  XMPPIOS
//
//  Created by Mac Pro on 13-8-21.
//  Copyright (c) 2013年 Dawn_wdf. All rights reserved.
//

#import "XMPPFramework.h"
#import "FMDB.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MessageModel.h"
#import "XMPPMessageCarbons.h"
#import "loginUserData.h"
#import "XMPPAutoPing.h"
#import "XMPPDao.h"
#import "Reachability.h"




@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
        XMPPDao * xmppManager;
       UIWindow *window;
}

@property(nonatomic,assign)BOOL allowRotation;
@property(nonatomic,assign)bool openAnimation;

@property (strong, nonatomic) UIWindow *window;
@property  NSTimer * time;
@property (nonatomic, strong) Reachability * reachability;
@property (nonatomic, strong) loginUserData * userdata;

@end


