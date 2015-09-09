//
//  ZLNetwork.m
//  GitHubClient
//
//  Created by account on 15/9/6.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import "ZLNetwork.h"
#import "MBProgressHUD+MJ.h"

@implementation ZLNetwork

+ (void)requestWithURL:(NSString *)url params:(NSDictionary *)params httpMethod:(HTTPMethod)httpMethod finish:(void (^)(AFHTTPRequestOperation *, id, NSError *))callback{
    [MBProgressHUD showMessage:@"正在加载..."];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSURL *baseURL=[NSURL URLWithString:URI_BASE];
    AFHTTPRequestOperationManager *manager=[[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    //检查网络状态和顺序执行的请求（用NSOperationQueue控制）不在一个线程，当网络状态不可用的时候会发出通知，这时候你执行的请求会被立刻中断执行并回到failure里面,return貌似没有意义了
    if (![self beforeExecute:manager]) {
        return;
    }

    if (httpMethod==HTTPMethodGET) {
        [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            callback(operation,responseObject,nil);
            [MBProgressHUD hideHUD];
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            callback(operation,nil,error);
            [self afterExecute:error];
            [MBProgressHUD hideHUD];
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        }];
    }else if(httpMethod==HTTPMethodPOST){
        [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            callback(operation,responseObject,nil);
            [MBProgressHUD hideHUD];
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            callback(operation,nil,error);
            [self afterExecute:error];
            [MBProgressHUD hideHUD];
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        }];
    }
}

/**
 *  检查网络状态和顺序执行的请求（用NSOperationQueue控制）不在一个线程，当网络状态不可用的时候会发出通知，这时候你执行的请求会被立刻中断执行并回到failure里面，回来的错误如果是 NSURLErrorNotConnectedToInternet 就是网络不好，否则就是服务器故障。
 */
+ (BOOL)beforeExecute:(AFHTTPRequestOperationManager *)manager{
    NSOperationQueue *queue=manager.operationQueue;
    
    __block BOOL isSuspend=NO;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                isSuspend=NO;
                [queue setSuspended:isSuspend];
                break;
            }
            case AFNetworkReachabilityStatusNotReachable:
            default:
            {
                isSuspend=YES;
                [queue setSuspended:isSuspend];
                break;
            }
        }
    }];
    
    [manager.reachabilityManager startMonitoring];
    return !isSuspend;
}

/**
 *  网络状态不佳的时候应该提示用户“网络不给力”，如果是API异常应该提示出“服务器错误，请您稍后刷新试试。”。
 *  检查网络状态和顺序执行的请求（用NSOperationQueue控制）不在一个线程，当网络状态不可用的时候会发出通知，这时候你执行的请求会被立刻中断执行并回到failure里面，回来的错误如果是 NSURLErrorNotConnectedToInternet 就是网络不好，否则就是服务器故障。
 */
+ (BOOL)afterExecute:(NSError *)error{
    if (error==nil) {
        return YES;
    }
    
    if (error.code==NSURLErrorNotConnectedToInternet) {
        //TODO: alert
        ZLLog(@"网络不给力");
        return NO;
    }
    
    ZLLog(@"Server error text is %@",error);
    //TODO: alert
    ZLLog(@"服务器故障，请稍后再试!%@",error);
    return YES;
}

@end
