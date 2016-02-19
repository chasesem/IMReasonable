//
//  ExpressionView.h
//  Alliance
//
//  Created by apple on 14-10-16.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ExpressionViewDelegate

-(void)selectedExpression:(NSInteger)index;
@end

@interface ExpressionView : UIView
@property(nonatomic,weak)id<ExpressionViewDelegate>delegate;
-(void)loadFacialView:(int)page size:(CGSize)size data:(NSArray *) data;
@end
