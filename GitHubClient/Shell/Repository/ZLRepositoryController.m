//
//  ZLRepositoryController.m
//  GitHubClient
//
//  Created by account on 15/9/1.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import "ZLRepositoryController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ZLUser.h"
#import "AFNetworking.h"
#import "MJRefresh.h"

@interface ZLRepositoryController () <UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *userArray;
@end

@implementation ZLRepositoryController
#pragma mark - life cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.userArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID=@"UITableViewCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    ZLUser *user=self.userArray[indexPath.row];
    cell.textLabel.text=user.login;
    cell.detailTextLabel.text=user.avatar_url;
    return cell;
}

#pragma mark - DZNEmptyDataSetSource
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIImage imageNamed:@"jieguo_blank"];
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

#pragma mark - getters and setters
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.dataSource=self;
        _tableView.emptyDataSetSource=self;
        _tableView.emptyDataSetDelegate=self;
        
        _tableView.header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [_tableView reloadData];
            [_tableView.header endRefreshing];
        }];
        
        _tableView.footer=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [_tableView reloadData];
            [_tableView.footer endRefreshing];
        }];
    }
    return _tableView;
}

-(NSArray *)userArray{
    if (!_userArray) {
        _userArray=[NSMutableArray array];
        NSString *url=@"https://api.github.com/users";
        
        AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            for (NSDictionary *dict in responseObject) {
                ZLUser *user=[ZLUser userWithDictionary:dict];
                NSLog(@"%@",user.login);
                [_userArray addObject:user];
            }
            //[_tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failur");
        }];
    }
    return _userArray;
}
@end
