//
//  Tool.h
//  RAJSupplyManger
//
//  Created by apple on 14-9-3.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Tool : NSObject
+(int)intervalSinceNow: (NSString *) theDate;
+(NSString *)getDateWithFormatString:(NSString *)dateString;
+(NSDictionary *)JsonStrngToDictionary:(NSString *)json;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color AndRect:(CGRect)rect;
+(void)removeVoiceAndImg;
+ (id)StringTojosn:(NSString *)stringdata;
+ (NSString *) GetDate:(NSString *) femate;
+ (NSData *) NSDataToBS64Data:(NSData *) data;
+ (NSString *) GetOnlyString;
+ (NSString *) NSdatatoBSString:(NSData *) data;
+ (NSData *) Base64StringtoNSData:(NSString *) str;
+ (BOOL)isBlankString:(NSString *)string;
+ (NSString *)intToString:(int )data;
+ (NSString *)Append:(NSString * )data witnstring:(NSString *) data2;
+ (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image width:(CGFloat)width;
+ (NSString *) GetFemate:(NSString *) str;
+ (NSString *) GetFemate2:(NSString *) str;
+ (void) alert:(NSString *) msg;
+ (NSString *) md5HexDigest:(NSString *)str;
+ (NSString *) getPhoneNumber:(NSString *) phonenumber;
+ (BOOL) isValidateMobile:(NSString *)mobile;

//Doc文件操作有关
+ (NSString *) getFilePathFromDoc:(NSString *) filename;
+ (NSString *) getVoicePath:(NSString *) filename;
+ (void) saveImageToDoc:(NSString*) imagename image:(UIImage*) img;
+ (void) saveFileToDoc:(NSString*) filename fileData:(NSData *) filedata;
+ (void) saveFile:(NSString*) path fileData:(NSData *) filedata;
+ (NSData *) getFileData:(NSString *) filepath;

+ (NSDictionary *) jsontodate:(NSData *) jsondata;
+(NSString *) getHHMM:(NSString *) str;
+(NSString *) getDisplayTime:(NSString *) str;
+(NSString *) getYYYYMMDD:(NSString *) str;
+(int)getDateDictiance:(NSString *) strdate;
+ (UIImage *)fixOrientation:(UIImage *)srcImg;
+ (NSString *)Get1970time;
+ (NSString *) GetTimeFromstring:(NSString *) sjc;
+(int)compareDate:(NSString *)date;
+ (BOOL)isCHMobileNumber:(NSString *)mobileNum;
+ (BOOL)isHKMobileNumber:(NSString *)mobileNum;
+(CGSize)labelAutoCalculateRectWith:(NSString*)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize;
+(NSString *) getTime;
+(NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate;
+(BOOL)isHaveChinese:(NSString *) str;
+(NSString *) getStringToIndex10:(NSString *) str;
+ (NSString *)getDocSize;
+ (NSData *)getDataFromGBKString:(NSString *)str;
+(BOOL)isValidateEmail:(NSString *)email;
@end
