//
//  PJNetWorkHelper.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/21.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "PJNetWorkHelper.h"
#import "Reachability.h"

@implementation PJNetWorkHelper

+(void)NoNetWork{
    UIAlertView* myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NONETWORK",nil) message:NSLocalizedString(@"CHECK_NET_WORK",nil)delegate:nil cancelButtonTitle:NSLocalizedString(@"btnDone",nil) otherButtonTitles:nil, nil];
    [myAlertView show];
}

+(BOOL)isNetWorkAvailable{
 Reachability* reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    return [reach isReachable];
}
@end
