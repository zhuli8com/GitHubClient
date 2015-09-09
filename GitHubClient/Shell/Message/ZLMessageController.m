//
//  ZLMessageController.m
//  GitHubClient
//
//  Created by account on 15/9/1.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import "ZLMessageController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface ZLMessageController () <DZNEmptyDataSetSource>
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation ZLMessageController
#pragma mark - life cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DZNEmptyDataSetSource
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIImage imageNamed:@"xiaoxi_blank"];
}

#pragma mark - getters and setters
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.emptyDataSetSource=self;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        // A little trick for removing the cell separators
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled=YES;
    }
    return _tableView;
}
@end
