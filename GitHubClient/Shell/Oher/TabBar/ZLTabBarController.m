//
//  ZLTabBarController.m
//  GitHubClient
//
//  Created by account on 15/9/1.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import "ZLTabBarController.h"
#import "ZLUserController.h"
#import "ZLRepositoryController.h"
#import "ZLMessageController.h"
#import "ZLNavigationController.h"

@interface ZLTabBarController ()

@end

@implementation ZLTabBarController

#pragma mark - life cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //用户
    ZLUserController *userController=[[ZLUserController alloc] init];
    [self addChildViewController:userController withTitle:@"用户" imgage:@"tabbar_contact_icon_normal" selectedImage:@"tabbar_contact_icon_press"];
    
    //仓库
    ZLRepositoryController *repositoryController=[[ZLRepositoryController alloc] init];
    [self addChildViewController:repositoryController withTitle:@"仓库" imgage:@"tabbar_service_icon_normal" selectedImage:@"tabbar_service_icon_press"];
    
    //消息
    ZLMessageController *messageController=[[ZLMessageController alloc] init];
    [self addChildViewController:messageController withTitle:@"消息" imgage:@"tabbar_message_icon_normal" selectedImage:@"tabbar_message_icon_press"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - private methods
- (void)addChildViewController:(UIViewController *)childController withTitle:(NSString *)title imgage:(NSString *)image selectedImage:(NSString *)selectedImage{
    //同时设置NavigaBarItem和TabBarItem的标题
    childController.title=title;
    //设置tabBarItem的背景图片
    [childController.tabBarItem setImage:[UIImage imageNamed:image]];
    //设置tabBarItem选中时的背景色
    [childController.tabBarItem setSelectedImage:[UIImage imageNamed:selectedImage]];
    
    //将childController用ZLNavigationController进行包装后添加到ZLTabBarController
    ZLNavigationController *navigationController=[[ZLNavigationController alloc] initWithRootViewController:childController];
    
    [self addChildViewController:navigationController];
}

@end
