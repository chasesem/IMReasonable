//
//  ImageHelp.m
//  IMReasonable
//
//  Created by apple on 14/10/29.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "ImageHelp.h"

@implementation ImageHelp

+(UIImage*)imageWithImage:(UIImage*)image
{
  
    int bitmapInfo = kCGImageAlphaNone;
    int width = image.size.width;
    int height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  bitmapInfo);
    CGColorSpaceRelease(colorSpace);
 
    if (context == NULL) {
        return nil;
    }else{
        CGContextDrawImage(context,
                           CGRectMake(0, 0, width, height), image.CGImage);
        UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];

        CGContextRelease(context);
    
        return grayImage;
    }
    
   

}

@end
