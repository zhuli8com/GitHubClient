//
//  NSObject+ZLSwizzle.h
//  GitHubClient
//
//  Created by account on 15/9/7.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (ZLSwizzle)

@property (nonatomic,strong) id associatedObject;

+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel;
+ (BOOL)swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel;
@end
