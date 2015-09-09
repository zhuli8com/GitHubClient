//
//  ZLUserController.m
//  GitHubClient
//
//  Created by account on 15/9/1.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import "ZLUserController.h"
#import "AFNetworking.h"
#import "ZLUser.h"
#import "ZLTableView.h"
#import "MJRefresh.h"

#define TEST_NOTIFICATION @"TEST_NOTIFICATION"

@interface ZLUserController ()
@property (nonatomic,strong) NSMutableArray *userArray;
@property (nonatomic,strong) ZLTableView *tableView;
@end

@implementation ZLUserController

#pragma mark - life cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getters and setters
-(NSArray *)userArray{
    if (!_userArray) {
        _userArray=[NSMutableArray array];
        
        [ZLNetwork requestWithURL:URI_USER params:nil httpMethod:HTTPMethodGET finish:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
            
            if (error==nil) {
                for (NSDictionary *dict in responseObject) {
                    ZLUser *user=[ZLUser userWithDictionary:dict];

                    ZLLog(@"%@",user.description);
                    
                    [_userArray addObject:user];
                }
            }
            //刷新数据啊
            [self.tableView reloadData];
        }];
    }
    return _userArray;
}

- (ZLTableView *)tableView{
    if (!_tableView) {
        _tableView=[[ZLTableView alloc] initWithFrame:self.view.frame backGroundImage:@"lianxiren_blank" title:@"用户页面" description:@"GitHub的用户页面" button:@""];
        
        _tableView.canScrolled=NO;
        _tableView.dataArray=self.userArray;
    }
    return _tableView;
}
@end
