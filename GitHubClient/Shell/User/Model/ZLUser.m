//
//  ZLUser.m
//  GitHubClient
//
//  Created by account on 15/9/1.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import "ZLUser.h"
#import <objc/runtime.h>

@implementation ZLUser

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self=[super init]) {
        
        unsigned int outCount=0;
        objc_property_t * properties=class_copyPropertyList([self class], &outCount);
        for (int i=0; i<outCount; i++) {
            objc_property_t property=properties[i];
            NSString *key=[NSString stringWithUTF8String:property_getName(property)];
            [self setValue:dict[key] forKeyPath:key];
        }
        
        free(properties);
    }
    return self;
}

+ (instancetype)userWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@,%@,%@",self.login,self.id,self.avatar_url];
}
@end
