//
//  ZLUser.h
//  GitHubClient
//
//  Created by account on 15/9/1.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZLUser : NSObject

@property (nonatomic,copy) NSString *login;
@property (nonatomic,copy) NSString *avatar_url;
@property (nonatomic,strong) NSNumber *id;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
+ (instancetype)userWithDictionary:(NSDictionary *)dict;
@end
