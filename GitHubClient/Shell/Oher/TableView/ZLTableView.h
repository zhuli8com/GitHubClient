//
//  ZLTableView.h
//  GitHubClient
//
//  Created by account on 15/9/2.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLTableView : UITableView

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) BOOL canScrolled;

- (instancetype)initWithFrame:(CGRect)frame backGroundImage:(NSString *)image title:(NSString *)title description:(NSString *)description button:(NSString *)button;
@end
