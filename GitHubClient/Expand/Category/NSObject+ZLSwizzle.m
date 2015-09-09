//
//  NSObject+ZLSwizzle.m
//  GitHubClient
//
//  Created by account on 15/9/7.
//  Copyright (c) 2015年 chinasofti. All rights reserved.
//

#import "NSObject+ZLSwizzle.h"

@implementation NSObject (ZLSwizzle)

- (id)associatedObject{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAssociatedObject:(id)associatedObject{
    objc_setAssociatedObject(self, @selector(associatedObject), associatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel{
    Method originMethod=class_getInstanceMethod(self, origSel);
    Method newMethod=class_getInstanceMethod(self, altSel);
    
    if (originMethod&&newMethod) {
        if (class_addMethod(self, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            class_replaceMethod(self, altSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        }else{
            method_exchangeImplementations(originMethod, newMethod);
        }
        return YES;
    }
    return NO;
}

+ (BOOL)swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel{
    Class c=object_getClass(self);
    return [c swizzleMethod:origSel withMethod:altSel];
}
@end
