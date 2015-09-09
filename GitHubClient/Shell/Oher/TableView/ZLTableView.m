//
//  ZLTableView.m
//  GitHubClient
//
//  tableView图片优化思路
//  1.当用户手动drag tableview的时候会加载cell中的图片
//  2.在用户快速滑动的减速过程中不加载过程中cell的图片（但文字信息还是会被加载，只是减少减速过程中的网络开销和图片加载的开销）
//      2.1如果内存中有图片的缓存，减速过程中也加载该图片
//      2.2如果图片属于targetContentOffSet能看到的cell正常加载，这样一来快速滚动的最后一屏出来的过程总用户就能看到目标区域的图片逐渐加载
//      2.3尝试用类似fade in或者flip的效果缓解生硬的突然出现
//  3.在减速结束后加载所有可见cell中的图片（如果需要的话）
//
//  Created by account on 15/9/2.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import "ZLTableView.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ZLUser.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "ZLUserCell.h"
#import "ZLTableViewConst.h"

@interface ZLTableView () <UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (nonatomic,strong) NSString *backGroundImage;
@property (nonatomic,strong) NSString *emptyDataTitle;
@property (nonatomic,strong) NSString *emptyDataDescription;
@property (nonatomic,strong) NSString *emptyDataButton;

@property (nonatomic,strong) NSValue *targetRect;
@end

@implementation ZLTableView
#pragma mark - life cycles
- (instancetype)initWithFrame:(CGRect)frame backGroundImage:(NSString *)image title:(NSString *)title description:(NSString *)description button:(NSString *)button{

    if (self=[super initWithFrame:frame style:UITableViewStylePlain]) {
        self.separatorStyle=UITableViewCellSeparatorStyleNone;
        self.delegate=self;
        self.dataSource=self;
        self.emptyDataSetDelegate=self;
        self.emptyDataSetSource=self;
        
        self.backGroundImage=image;
        self.emptyDataTitle=title;
        self.emptyDataDescription=description;
        self.emptyDataButton=button;
        
//        self.header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            [self reloadData];
//            [self.header endRefreshing];
//        }];
        
        self.footer=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            ZLUser *lastUser=[self.dataArray lastObject];
            NSString *url=[[URI_USER stringByAppendingString:@"?since="] stringByAppendingString:lastUser.id.description];
            ZLLog(@"url=%@",url);
            
            [ZLNetwork requestWithURL:url params:nil httpMethod:HTTPMethodGET finish:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
                
                if (error==nil) {
                    for (NSDictionary *dict in responseObject) {
                        ZLUser *user=[ZLUser userWithDictionary:dict];
                        
                        ZLLog(@"%@",user.description);
                        
                        [self.dataArray addObject:user];
                    }
                }
                //刷新数据啊
                [self reloadData];
                
                [self.footer endRefreshing];
            }];
        }];
    }
    return self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (ZLUserCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID=@"UITableViewCell";
    ZLUserCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell=[[ZLUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    [self setupCell:cell withIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableViewHeight;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.targetRect=nil;
    [self loadImageForVisibleCells];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    CGRect targetRect=CGRectMake(targetContentOffset->x, targetContentOffset->y, scrollView.frame.size.width, scrollView.frame.size.height);
    self.targetRect=[NSValue valueWithCGRect:targetRect];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.targetRect=nil;
    [self loadImageForVisibleCells];
}

#pragma mark - DZNEmptyDataSetSource
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIImage imageNamed:self.backGroundImage];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text=self.emptyDataTitle;
    
    NSDictionary *attributes=@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f],
                               NSForegroundColorAttributeName:[UIColor grayColor]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text=self.emptyDataDescription;
    
    NSMutableParagraphStyle *paragraph=[[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode=NSLineBreakByWordWrapping;
    paragraph.alignment=NSTextAlignmentCenter;
    
    NSDictionary *attributes=@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f],
                               NSForegroundColorAttributeName:[UIColor lightGrayColor],
                               NSParagraphStyleAttributeName:paragraph};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    NSDictionary *attributes=@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0f]};
    return [[NSAttributedString alloc] initWithString:self.emptyDataButton attributes:attributes];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIColor whiteColor];
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return self.canScrolled;
}

-(void)emptyDataSetDidTapButton:(UIScrollView *)scrollView{
    //[MBProgressHUD showMessage:@"正在加载..."];
}

#pragma mark - private methods
- (void)loadImageForVisibleCells{
    for (ZLUserCell *cell in self.visibleCells) {
        [self setupCell:cell withIndexPath:[self indexPathForCell:cell]];
    }
}

- (void)setupCell:(ZLUserCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    ZLUser *user=self.dataArray[indexPath.row];
    cell.nameLabel.text=user.login;
    
    NSURL *targetURL=[NSURL URLWithString:user.avatar_url];
    
    if (![cell.avatarImageView.sd_imageURL isEqual:targetURL]) {
        //cell.avatarImageView.alpha=0.0;
        
        CGRect cellFrame=[self rectForRowAtIndexPath:indexPath];
        BOOL shouldLoadImage=YES;
        if (self.targetRect&&!CGRectIntersectsRect([self.targetRect CGRectValue], cellFrame)) {
            SDImageCache *cache=[SDImageCache sharedImageCache];
            NSString *key=[[SDWebImageManager sharedManager] cacheKeyForURL:targetURL];
            if (![cache imageFromMemoryCacheForKey:key]) {
                shouldLoadImage=NO;
            }
        }
        
        __block UIActivityIndicatorView *activityIndicator;
        __weak UIImageView *weakImageView=cell.avatarImageView;
        if (shouldLoadImage) {
            [cell.avatarImageView sd_setImageWithURL:targetURL
                                    placeholderImage:[UIImage imageNamed:@"placeholder"]
                                             options:SDWebImageProgressiveDownload
                                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                if (!activityIndicator) {
                                                    [weakImageView addSubview:activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                                                    CGPoint activityIndicatorCenter=CGPointMake(weakImageView.center.x-5, weakImageView.center.y-5);
                                                    activityIndicator.center=activityIndicatorCenter;
                                                    [activityIndicator startAnimating];
                                                }
            }
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                               if (!error&&[imageURL isEqual:targetURL]) {
                                                   [activityIndicator removeFromSuperview];
                                                   activityIndicator=nil;
                                               }
                                           }];
//            
//            [cell.avatarImageView sd_setImageWithURL:targetURL
//                                    placeholderImage:[UIImage imageNamed:@"placeholder"]
//                                             options:SDWebImageHandleCookies
//                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                               if (!error&&[imageURL isEqual:targetURL]) {
////                                                   [UIView animateWithDuration:0.25 animations:^{
////                                                       cell.avatarImageView.alpha=1.0;
////                                                   }];
//                                                   
//                                                   // or flip animation
//                                                   [UIView transitionWithView:cell duration:0.5 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionTransitionFlipFromBottom animations:^{
//                                                       cell.avatarImageView.alpha = 1.0;
//                                                   } completion:^(BOOL finished) {
//                                                   }];
//                                               }
//                                           }];
        }
    }}
@end
