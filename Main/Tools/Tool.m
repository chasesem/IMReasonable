//
//  Tool.m
//  RAJSupplyManger
//
//  Created by apple on 14-9-3.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//



#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>

#import "Tool.h"

#define VOICE @"voice"
#define ALLUSERFILE @"AllUserFile"

@implementation Tool

//判断日期是否超过若干天
+(int)intervalSinceNow: (NSString *) theDate
{
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    NSTimeInterval cha=now-late;
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        return [timeString intValue];
    }
    return -1;
}

//切割图片
+(UIImage *)CuttingImage:(UIImage *)image WitnRect:(CGRect)rect{
    
    return image;
}

+(NSDictionary *)JsonStrngToDictionary:(NSString *)json{
    if(json==nil){
        
        return nil;
    }
    NSData *jsonData=[json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err){
        
        return nil;
    }
    return dictionary;
}

//  颜色转换为背景图片
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color AndRect:(CGRect)rect{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//删除文件夹及文件夹下的文件
+(void)removeVoiceAndImg{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    //语音存放的路径
    NSString *AllvoicePath=[NSString stringWithFormat:@"%@/%@",documentsDirectory,VOICE];
    NSLog(@"%@",AllvoicePath);
    //图片存放的路径
    NSString *AllimgPath=[NSString stringWithFormat:@"%@/%@",documentsDirectory,ALLUSERFILE];
    //删除语音
    [fileManager removeItemAtPath:AllvoicePath error:nil];
    //删除图片
    [fileManager removeItemAtPath:AllimgPath error:nil];
}

+ (id)StringTojosn:(NSString *)stringdata
{
    NSData *data= [stringdata dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id weatherDic=nil;
    if (data!=nil) {
        weatherDic= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    }
    return weatherDic;
}

+ (NSString *) GetDate:(NSString *) famate
{
    
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:famate];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    
    return locationString;
    
}

+ (NSString *) GetOnlyString
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return timeString;
    
}



+ (NSData *) NSDataToBS64Data:(NSData *) data
{
    NSData *base64Data = [data base64EncodedDataWithOptions:0];
    
    return base64Data;
}

+ (NSString *) NSdatatoBSString:(NSData *) data
{
    return [data base64EncodedStringWithOptions:0];
    
}
+ (NSData *) Base64StringtoNSData:(NSString *) str
{
    return [[NSData alloc] initWithBase64EncodedString:str options:0];
    
}




+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}


+ (NSString *)intToString:(int )data
{
    return  [NSString stringWithFormat:@"%ld",(long)data];
}
+ (NSString *)Append:(NSString * )data witnstring:(NSString *) data2
{
    
    return  [NSString stringWithFormat:@"%@%@",data,data2];
}


+ (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image width:(CGFloat)width
{
    CGSize newSize = CGSizeMake(width, image.size.height/image.size.width *width);
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    NSData* pictureData = UIImageJPEGRepresentation(newImage,0.5);
    UIImage *image1 = [UIImage imageWithData:pictureData];
    
    return image1;
}


+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect=CGRectMake(0, 0, oldsize.width, oldsize.height);
        if (oldsize.width>asize.width) {
            CGFloat delta=oldsize.width/asize.width;
            CGFloat newHeight=oldsize.height/delta;
            rect=CGRectMake(0, 0, asize.width, newHeight);
        }
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(rect);//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}


+ (NSString *) GetFemate:(NSString *) str
{
    if(![str isEqualToString:@""])
    {
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray  * array= [str componentsSeparatedByString:@"/"];
        NSString * year=[array[2] substringWithRange:NSMakeRange(0, 4)];
        
        NSString *dateStr=[NSString stringWithFormat:@"%@年%@月%@日",
                           year,
                           array[0],
                           array[1]];
        return dateStr;
    }else{
        
        
        return str;
    }
    
    
    
}

+ (NSString *) GetFemate2:(NSString *) str
{
    if(![str isEqualToString:@""])
    {
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray  * array= [str componentsSeparatedByString:@"/"];
        NSString * year=[array[2] substringWithRange:NSMakeRange(0, 4)];
        
        NSString *dateStr=[NSString stringWithFormat:@"%@-%@-%@",
                           year,
                           array[0],
                           array[1]];
        return dateStr;
    }else{
        
        
        return str;
    }
    
    
    
}
+ (void) alert:(NSString *) msg
{
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"lbttitle", nil) message:msg delegate:self cancelButtonTitle:nil    otherButtonTitles:NSLocalizedString(@"lbtok", nil), nil];
    [alert show];
}


+ (NSString *) md5HexDigest:(NSString *)str
{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (int)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}


+ (NSString *) getPhoneNumber:(NSString *) phonenumber
{
    
    NSString* tempPhonenumber = @"";
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i=0; i<[phonenumber length]; i++) {
        NSString* chr = [phonenumber substringWithRange:NSMakeRange(i, 1)];
        if([chr rangeOfCharacterFromSet:tmpSet].length) {
            
            tempPhonenumber = [tempPhonenumber stringByAppendingFormat:@"%@", chr];
        }
    }
    
    return tempPhonenumber;
    
}

//验证是不是手机号码
+ (BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(14[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}

//获取Doc文件夹下文件的路径,并判断文件是否存在，如果不存在返回nil，存在就返回文件路径
//没有带后缀名默认返回的是.png文件
+ (NSString *) getFilePathFromDoc:(NSString *) filename
{
    NSString *fullPathToFile;
    
    if([filename rangeOfString:@"."].location != NSNotFound)//_roaldSearchText
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        fullPathToFile= [documentsDirectory stringByAppendingPathComponent:filename];
        
    }
    else
    {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",filename];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        fullPathToFile= [documentsDirectory stringByAppendingPathComponent:imageName];
        
    }
    return fullPathToFile;
}

//语音保存的路径
+ (NSString *) getVoicePath:(NSString *) filename
{
    NSString *fullPathToFile;
    
    if([filename rangeOfString:@"."].location != NSNotFound)//_roaldSearchText
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        fullPathToFile= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"voice/%@",filename]];
        
    }
    else
    {
        NSString *imageName = [NSString stringWithFormat:@"%@.caf",filename];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        fullPathToFile= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"voice/%@",imageName]];
        
    }
    /*  NSFileManager *fileManager = [NSFileManager defaultManager];
     BOOL result = [fileManager fileExistsAtPath:fullPathToFile];
     if (!result) {
     */
    return fullPathToFile;
    /*}else{
     return nil;
     }
     */
    
}

//存储图片到Doc文件夹里面
+ (void) saveImageToDoc:(NSString*) imagename image:(UIImage*) img
{
    NSData *imageData = UIImagePNGRepresentation(img);
    [self saveFileToDoc:imagename fileData:imageData];
}
//存储图片到Doc文件夹
+ (void) saveFileToDoc:(NSString*) filename fileData:(NSData *) filedata
{
    NSString * filepath=[self getFilePathFromDoc:filename];
    if (filepath!=nil) {
        [filedata writeToFile: filepath atomically:YES];
    }
}

//存储图片到Doc文件夹
+ (void) saveFile:(NSString*) path fileData:(NSData *) filedata
{
    if (path!=nil) {
        [filedata writeToFile: path atomically:YES];
    }
}

//把doc文件的内容读取到NSdata里面
+ (NSData *) getFileData:(NSString *) filepath
{
    NSData *data;
    data = [NSData dataWithContentsOfFile:filepath];
    if (data.length>0) {
        return data;
    }else{
        return nil;
    }
}

#pragma mark-解析json数据
+ (NSDictionary *) jsontodate:(NSData *) jsondata
{
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableLeaves error:&error];
    
    NSLog(@"%@",error);
    return dict;
}

+(NSString *) getHHMM:(NSString *) str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:str];
    
    
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+(NSString *) getDisplayTime:(NSString *) str
{
    
    if (str && str.length>0) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:str];
        
        if (date) {
            NSString *dbDateString = [Tool getTextTime:date];
            return dbDateString;
        }else{
            return @"";
        }
        
    }else{
        return @"";
    }
    
    
}

+(NSInteger)getDay:(NSDate*) date withDate:(NSDate*)date2{
    
    
    int timediff = fabs([date timeIntervalSince1970]-[date2 timeIntervalSince1970]);
    
    return timediff/(24*60*60);
}

+(NSInteger) calcDaysFromBegin:(NSDate *)inBegin end:(NSDate *)inEnd
{
    NSInteger unitFlags = NSDayCalendarUnit| NSMonthCalendarUnit | NSYearCalendarUnit;
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [cal components:unitFlags fromDate:inBegin];
    NSDate *newBegin  = [cal dateFromComponents:comps];
    NSCalendar *cal2 = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps2 = [cal2 components:unitFlags fromDate:inEnd];
    NSDate *newEnd  = [cal2 dateFromComponents:comps2];
    NSTimeInterval interval = [newEnd timeIntervalSinceDate:newBegin];
    NSInteger beginDays=((NSInteger)interval)/(3600*24);
    
    return beginDays;
}

+(NSString *)getTextTime:(NSDate *)date{
    
    //   NSInteger nowyear,nowmonth,nowday,nowhour,nowmin,nowsec,nowweek;
    //   NSInteger dateyear,datemonth,dateday,datehour,datemin,datesec,dateweek;
    
    //  NSInteger nowyear,nowmonth,nowday,nowweek;
    NSInteger dateyear,datemonth,dateday,dateweek;
    
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //  NSDateComponents *compsnow = [[NSDateComponents alloc] init];//今天时间
    
    NSDateComponents *compsdate = [[NSDateComponents alloc] init];//要比较的日期
    
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    //   compsnow = [calendar components:unitFlags fromDate:now];
    compsdate = [calendar components:unitFlags fromDate:date];
    
    //今天的事件分割
    //    nowyear = [compsnow year];
    //    nowweek = [compsnow weekday];
    //    nowmonth = [compsnow month];
    //    nowday = [compsnow day];
    //    nowhour = [compsnow hour];
    //    nowmin = [compsnow minute];
    //    nowsec = [compsnow second];
    //待比较事件分割
    dateyear = [compsdate year];
    dateweek = [compsdate weekday];
    datemonth = [compsdate month];
    dateday = [compsdate day];
    //    datehour = [compsdate hour];
    //    datemin = [compsdate minute];
    //    datesec = [compsdate second];
    
    
    
    
    
    NSInteger countday=[Tool calcDaysFromBegin:date end:now];   //[Tool getDay:now withDate:date];
    if (countday<=7) {
        if (countday==0) {
            return @"lbtimetoday";
        }else if(countday==1){
            return @"lbtimeyestoday";
        }else{
            
            NSString * weekStr;
            if(dateweek==1)
            {
                weekStr=@"lbtimeSunday";
            }else if(dateweek==2){
                weekStr=@"lbtimeMonday";
                
            }else if(dateweek==3){
                weekStr=@"lbtimeTuesday";
                
            }else if(dateweek==4){
                weekStr=@"lbtimeWednesday";
                
            }else if(dateweek==5){
                weekStr=@"lbtimeThursday";
                
            }else if(dateweek==6){
                weekStr=@"lbtimeFriday";
                
            }else if(dateweek==7){
                weekStr=@"lbtimeSaturday";
                
            }
            
            return weekStr;
        }
        
        
    }else{
        
        return [NSString stringWithFormat:@"%ld/%ld/%ld",(long)datemonth,(long)dateday,(long)dateyear];
        
    }
    //
    //          if (nowyear==dateyear) {//同一年
    //
    //        if (nowmonth==datemonth) {//同年同月
    //
    //
    //
    //
    //        }else{
    //           return [NSString stringWithFormat:@"%ld/%ld/%ld",datemonth,dateday,dateyear];
    //        }
    //
    //    }else{
    //        return [NSString stringWithFormat:@"%ld/%ld/%ld",datemonth,dateday,dateyear];
    //    }
    return @"";
}

+(NSString *)getDateWithFormatString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateString];
    NSDate *date=[NSDate date];
    NSString *formatDate = [dateFormatter stringFromDate:date];
    return formatDate;
}

//////////////////
+(NSString *) getTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *  senddate=[NSDate date];
    // [dateFormatter setDateFormat:@"HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:senddate];
    return strDate;
}
+(NSString *) getYYYYMMDD:(NSString *) str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:str];
    
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+(NSString *) getStringToIndex10:(NSString *) str
{
    if ([str length]>10) {
        return   [str substringToIndex:10];
    }else{
        return @"";
        
    }
    
    
}

+(int)getDateDictiance:(NSString *) strdate
{
    NSDate *now=[NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date =[dateFormatter dateFromString:strdate];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSDayCalendarUnit;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:date  toDate:now  options:0];
    int days =(int)[comps day];
    return days;
}

+ (UIImage *)fixOrientation:(UIImage *)srcImg {
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (NSString *)Get1970time
{
    //    NSDate *datenow = [NSDate date];
    //
    //    NSString *timeSp = [NSString stringWithFormat:@"%ld",(long) [datenow timeIntervalSince1970]];
    //      return timeSp;
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *timeSp = [NSString stringWithFormat:@"%llu",recordTime];
    return timeSp;
    
    //    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    //    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    //    NSString *date =  [formatter stringFromDate:[NSDate date]];
    //    NSString *timeLocal = [[NSString alloc] initWithFormat:@"%@", date];
    //    return timeLocal;
}

+ (NSString *) GetTimeFromstring:(NSString *) sjc
{
    
    
    //    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateStyle:NSDateFormatterMediumStyle];
    //    [formatter setTimeStyle:NSDateFormatterShortStyle];
    //    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSDate *date = [formatter dateFromString:sjc];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[sjc integerValue]];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *  locationString=[dateformatter stringFromDate:date];
    return locationString;
}

+(int)compareDate:(NSString *)date{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *yesterday;
    
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    
    NSString * dateString = [date  substringToIndex:10];
    
    if ([dateString isEqualToString:todayString])
    {
        return 0;
    } else if ([dateString isEqualToString:yesterdayString])
    {
        return 1;
    }else{
        return 2;
    }
}

//检验大陆电话号码
+ (BOOL)isCHMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134、135、136、137、138、139、150、151、152、157、158、159、182、183、184、187、188、178(4G)
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[0127-9]|8[32478]|78)\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130、131、132、155、156、185、186、176(4G)
     17         */
    NSString * CU = @"^1(3[0-2]|5[56]|8[56]|76)\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189  //133、153、180、181、189 、177
     22         */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349|77)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)isHKMobileNumber:(NSString *)mobileNum
{
    
    
    //    NSString * MOBILE = @"^([5689])\\d{7}$";//^(5[1-6][0-9]|59[0-9]|6[0-9][1-9]|9[0-8][1-9])\\d{5}$
    NSString * MOBILE = @"^(5[1-6][0-9]|59[0-9]|6[0-9][1-9]|9[0-8][1-9])\\d{5}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    // NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    //  NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    //  NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES))
        // || ([regextestcm evaluateWithObject:mobileNum] == YES)
        //|| ([regextestct evaluateWithObject:mobileNum] == YES)
        // || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
    
}

+(CGSize)labelAutoCalculateRectWith:(NSString*)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize

{
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing=0;
    
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize size = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
    
}

+(NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

+(BOOL)isHaveChinese:(NSString *) str
{
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return true;
        }
        
    }
    
    return false;
}

+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}



//遍历文件夹获得文件夹大小，返回多少M
+ (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

// 获取Doc文件夹占用的控件
+ (NSString *)getDocSize{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    float size=[Tool folderSizeAtPath:documentsDirectory];
    
    return [NSString stringWithFormat:@"%0.1fM",size];
    
}
//。net
+ (NSData *)getDataFromGBKString:(NSString *)str{
    
    NSData * contentdata=[Tool Base64StringtoNSData:str] ;
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    NSString *contentdatajsonstring=[[NSString alloc] initWithData:contentdata encoding:enc];
    if (contentdatajsonstring&&contentdatajsonstring.length) {
        return  [contentdatajsonstring dataUsingEncoding:NSUTF8StringEncoding] ;
    }else{
        
        return nil;
    }
    
    
}

//校验邮箱格式是否正确
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}


@end
