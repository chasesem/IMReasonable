//
//  Message.m
//  IMReasonable
//
//  Created by apple on 14/11/3.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "Message.h"

@implementation Message


- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.from forKey:@"from"];
    [encoder encodeObject:self.count forKey:@"count"];
    [encoder encodeObject:self.messagebody forKey:@"messagebody"];
    [encoder encodeObject:self.creationDate forKey:@"creationDate"];
}
- (id)initWithCoder:(NSCoder *)decoder
{
    if(self = [super init])
    {
        self.from = [decoder decodeObjectForKey:@"from"];
        self.count = [decoder decodeObjectForKey:@"count"];
        self.messagebody = [decoder decodeObjectForKey:@"messagebody"];
        self.creationDate = [decoder decodeObjectForKey:@"creationDate"];
    }
    return  self;
}

@end

//@implementation IMUser
//
///*
//- (void)encodeWithCoder:(NSCoder *)encoder
//{
//    [encoder encodeObject:self.faceurl forKey:@"faceurl"];
//    [encoder encodeObject:self.jibstr forKey:@"jibstr"];
//    [encoder encodeObject:self.nickname forKey:@"nickname"];
//}
//- (id)initWithCoder:(NSCoder *)decoder
//{
//    if(self = [super init])
//    {
//        self.faceurl = [decoder decodeObjectForKey:@"faceurl"];
//        self.jibstr = [decoder decodeObjectForKey:@"jibstr"];
//        self.nickname = [decoder decodeObjectForKey:@"nickname"];
//       
//    }
//    return  self;
//}
// */
//
//@end

@implementation offlineMessage
@end

@implementation IMUserNickName
@end


