//
//  FriendsCircleViewController.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/12/1.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "FriendsCircleViewController.h"
#import "PostTalkkingViewController.h"

@implementation FriendsCircleViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self initController];
}

-(void)initController{
    self.navigationItem.title=NSLocalizedString(@"FRIENDS_CIRCLE", nil);
    UIBarButtonItem *camera=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(postTalk)];
    self.navigationItem.rightBarButtonItem=camera;
}

//发表说说
-(void)postTalk{
    PostTalkkingViewController *postTalkkingViewController=[[PostTalkkingViewController alloc]init];
    UINavigationController *postNavTalkking=[[UINavigationController alloc] init];
    [postNavTalkking addChildViewController:postTalkkingViewController];
    [self presentViewController:postNavTalkking animated:YES completion:nil];
}

@end
