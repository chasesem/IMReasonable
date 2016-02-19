//
//  Message.h
//  IMReasonable
//
//  Created by apple on 14/11/3.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property NSString *from;
@property NSNumber *count;
@property NSString *messagebody;
@property NSString *creationDate;
@end


//@interface IMUser : NSObject
//@property NSString *faceurl;
//@property NSString *jibstr;
//@property NSString *nickname;
//@end

@interface IMUserNickName : NSObject
@property NSString *jibstr;
@property NSString *nickname;
@end

@interface offlineMessage : NSObject

@property NSString *ID;
@property NSString *IMfrom;
@property NSString *IMto;
@property NSString *body;
@property NSString *type;
@property NSString * date;
@end



