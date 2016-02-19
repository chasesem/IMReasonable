//
//  PJImageBrowserController.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/12/10.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

@class PJImageBrowser;

#import <UIKit/UIKit.h>

@protocol PJImageBrowserDelegate <NSObject>

//删除图片代理方法
-(void)deletePhoto:(PJImageBrowser *)pjimageBrowser AtIndex:(NSInteger)index;
//返回
-(void)back:(PJImageBrowser *)pjimageBrowser;

@end

@interface PJImageBrowser : UIViewController

// 所有的图片对象
@property (nonatomic, strong) NSMutableArray *photos;
//当前图片的索引
@property(nonatomic,assign)NSInteger currentIndex;
//存放所有要显示的图片
@property(nonatomic,strong)NSMutableArray *imageArray;
//存放删除后剩余的图片
@property(nonatomic,strong)NSMutableArray *returnImageArray;
@property(nonatomic,weak)id<PJImageBrowserDelegate> pjimageBrowserDelegate;
-(instancetype)initWithImageArray:(NSMutableArray *)imageArray AndCurrentIndex:(NSInteger)index;

@end
