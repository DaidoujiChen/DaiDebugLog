//
//  DaiDebugLogViewFinder.h
//  DaiDebugLog
//
//  Created by DaidoujiChen on 2015/8/26.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DaiDebugLogViewHelper : NSObject

+ (UIWindow *)currentWindowHandlePoint:(CGPoint)handlePoint exceptWindow:(UIWindow *)exceptWindow;
+ (NSArray *)recursiveSubviewsAtPoint:(CGPoint)pointInView inView:(UIView *)view skipHiddenViews:(BOOL)skipHidden;
+ (UIImage *)drawView:(UIView *)view inWindow:(UIWindow *)window;

@end
