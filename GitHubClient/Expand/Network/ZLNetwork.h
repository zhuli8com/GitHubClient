//
//  ZLNetwork.h
//  GitHubClient
//
//  Created by account on 15/9/6.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZLURI.h"
#import "AFNetworking.h"

//#define HTTPMethodGET @"GET"
//#define HTTPMethodPOST @"POST"
typedef NS_ENUM(NSInteger, HTTPMethod){
    HTTPMethodGET=0,
    HTTPMethodPOST
};

#define RequestFinishedCallback void(^)(AFHTTPRequestOperation *operation, id responseObject, NSError *error)

@interface ZLNetwork : NSObject

+ (void)requestWithURL:(NSString *)url params:(NSDictionary *)params httpMethod:(HTTPMethod)httpMethod finish:(RequestFinishedCallback)callback;
@end
