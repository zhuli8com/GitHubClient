//
//  ZLUserCell.m
//  GitHubClient
//
//  Created by account on 15/9/2.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import "ZLUserCell.h"
#import "ZLTableViewConst.h"

@implementation ZLUserCell
#pragma mark - life cycles
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        //添加高度是1的下缘线来分割Cell（刷新和选择有问题）
//        UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kTableViewHeight, [UIScreen mainScreen].bounds.size.width, 1)];
//        bottomView.backgroundColor=[UIColor lightGrayColor];
//        [self.contentView addSubview:bottomView];
        
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

#pragma mark -getters and setters
- (UIImageView *)avatarImageView{
    if (!_avatarImageView) {
        _avatarImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, kAvatarWidth, kAvatarHight)];
//        _avatarImageView.layer.cornerRadius=10;
//        _avatarImageView.layer.borderColor=(__bridge CGColorRef)([UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.00f]);
//        _avatarImageView.layer.borderWidth=0.3;
//        _avatarImageView.layer.masksToBounds=YES;
//        
//        _avatarImageView.contentMode=UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius=_avatarImageView.frame.size.width/2;
        
        _avatarImageView.layer.shouldRasterize=YES;
        _avatarImageView.layer.rasterizationScale=[UIScreen mainScreen].scale;
        
        _avatarImageView.layer.masksToBounds=YES;
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(90, 0, [UIScreen mainScreen].bounds.size.width-90, kTableViewHeight)];
    }
    return _nameLabel;
}
@end
