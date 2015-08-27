//
//  DaiDebugLogViewFinder.m
//  DaiDebugLog
//
//  Created by DaidoujiChen on 2015/8/26.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiDebugLogViewHelper.h"
#import <objc/runtime.h>
#import "UIView+DaiDebugLogEasyFrame.h"

#define labelGap 2.5f

@implementation DaiDebugLogViewHelper

#pragma mark - private class method

+ (UILabel *)defaultLabel {
    UILabel *defaultLabel = [UILabel new];
    defaultLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:8.0f];
    defaultLabel.backgroundColor = [UIColor blackColor];
    defaultLabel.textColor = [UIColor whiteColor];
    defaultLabel.layer.cornerRadius = 2.0f;
    defaultLabel.layer.masksToBounds = YES;
    return defaultLabel;
}

+ (void)renderView:(UIView *)view inContext:(CGContextRef)ctx {
    CGContextTranslateCTM(ctx, view.easy_left, view.easy_top);
    [view.layer renderInContext:ctx];
    CGContextTranslateCTM(ctx, -view.easy_left, -view.easy_top);
}

// code from FLEX
+ (NSArray *)allWindows {
    BOOL includeInternalWindows = YES;
    BOOL onlyVisibleWindows = NO;
    
    NSArray *allWindowsComponents = @[@"al", @"lWindo", @"wsIncl", @"udingInt", @"ernalWin", @"dows:o", @"nlyVisi", @"bleWin", @"dows:"];
    SEL allWindowsSelector = NSSelectorFromString([allWindowsComponents componentsJoinedByString:@""]);
    
    NSMethodSignature *methodSignature = [[UIWindow class] methodSignatureForSelector:allWindowsSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    
    invocation.target = [UIWindow class];
    invocation.selector = allWindowsSelector;
    [invocation setArgument:&includeInternalWindows atIndex:2];
    [invocation setArgument:&onlyVisibleWindows atIndex:3];
    [invocation invoke];
    
    __unsafe_unretained NSArray *windows = nil;
    [invocation getReturnValue:&windows];
    return windows;
}

// code from FLEX
+ (NSArray *)recursiveSubviewsAtPoint:(CGPoint)pointInView inView:(UIView *)view skipHiddenViews:(BOOL)skipHidden {
    NSMutableArray *subviewsAtPoint = [NSMutableArray array];
    for (UIView *subview in view.subviews) {
        BOOL isHidden = subview.hidden || subview.alpha < 0.01;
        if (skipHidden && isHidden) {
            continue;
        }
        
        BOOL subviewContainsPoint = CGRectContainsPoint(subview.frame, pointInView);
        if (subviewContainsPoint) {
            [subviewsAtPoint addObject:subview];
        }
        
        // If this view doesn't clip to its bounds, we need to check its subviews even if it doesn't contain the selection point.
        // They may be visible and contain the selection point.
        if (subviewContainsPoint || !subview.clipsToBounds) {
            CGPoint pointInSubview = [view convertPoint:pointInView toView:subview];
            [subviewsAtPoint addObjectsFromArray:[self recursiveSubviewsAtPoint:pointInSubview inView:subview skipHiddenViews:skipHidden]];
        }
    }
    return subviewsAtPoint;
}

#pragma mark - class method

+ (UIWindow *)currentWindowHandlePoint:(CGPoint)handlePoint exceptWindow:(UIWindow *)exceptWindow {
    UIWindow *windowForSelection = [[UIApplication sharedApplication] keyWindow];
    for (UIWindow *window in [[self allWindows] reverseObjectEnumerator]) {
        // Ignore the explorer's own window.
        if (window != exceptWindow) {
            if ([window hitTest:handlePoint withEvent:nil]) {
                windowForSelection = window;
                break;
            }
        }
    }
    return windowForSelection;
}

+ (UIImage *)drawView:(UIView *)view inWindow:(UIWindow *)window {
    
    // 設定需要用到的數字們
    CGRect convertFrame = [window convertRect:view.frame fromView:view.superview];
    UIView *dummyConvertView = [[UIView alloc] initWithFrame:convertFrame];
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat distanceToTop = dummyConvertView.easy_top;
    CGFloat distanceToBottom = screenHeight - dummyConvertView.easy_bottom;
    CGFloat distanceToLeft = dummyConvertView.easy_left;
    CGFloat distanceToRight = screenWidth - dummyConvertView.easy_right;
    
    // 準備開始畫畫
    UIImage *drawImage = nil;
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, 0, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 設定線條相關屬性
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, 2.0f);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    
    // 畫 view 的框框
    CGContextStrokeRect(ctx, convertFrame);
    
    // 離上距離
    UILabel *topLabel = [self defaultLabel];
    topLabel.text = [NSString stringWithFormat:@"%.1f", distanceToTop];
    [topLabel sizeToFit];
    topLabel.easy_top = labelGap;
    
    // 離下距離
    UILabel *bottomLabel = [self defaultLabel];
    bottomLabel.text = [NSString stringWithFormat:@"%.1f", distanceToBottom];
    [bottomLabel sizeToFit];
    bottomLabel.easy_bottom = screenHeight - labelGap;
    
    // 離左距離
    UILabel *leftLabel = [self defaultLabel];
    leftLabel.text = [NSString stringWithFormat:@"%.1f", distanceToLeft];
    [leftLabel sizeToFit];
    leftLabel.easy_left = labelGap;
    
    // 離右距離
    UILabel *rightLabel = [self defaultLabel];
    rightLabel.text = [NSString stringWithFormat:@"%.1f", distanceToRight];
    [rightLabel sizeToFit];
    rightLabel.easy_right = screenWidth - labelGap;
    
    // 寬標示
    UILabel *widthLabel = [self defaultLabel];
    widthLabel.text = [NSString stringWithFormat:@"%.1f", dummyConvertView.easy_width];
    [widthLabel sizeToFit];
    widthLabel.easy_midX = dummyConvertView.easy_midX;
    
    // 高標示
    UILabel *heightLabel = [self defaultLabel];
    heightLabel.text = [NSString stringWithFormat:@"%.1f", dummyConvertView.easy_height];
    [heightLabel sizeToFit];
    heightLabel.easy_midY = dummyConvertView.easy_midY;
    
    // 左邊的空間比較大, 切線畫在左邊, 反之畫右邊
    if (distanceToLeft > distanceToRight) {
        
        // 左切線
        CGContextMoveToPoint(ctx, dummyConvertView.easy_left, 0);
        CGContextAddLineToPoint(ctx, dummyConvertView.easy_left, screenHeight);
        
        topLabel.easy_right = dummyConvertView.easy_left - labelGap;
        bottomLabel.easy_right = dummyConvertView.easy_left - labelGap;
        
        if (topLabel.easy_left <= 0 || bottomLabel.easy_left <= 0) {
            topLabel.easy_left = dummyConvertView.easy_left + labelGap;
            bottomLabel.easy_left = dummyConvertView.easy_left + labelGap;
        }
        
        heightLabel.easy_right = dummyConvertView.easy_left - labelGap;
        if (heightLabel.easy_left <= 0) {
            heightLabel.easy_left = labelGap;
        }
    }
    else {
        
        // 右切線
        CGContextMoveToPoint(ctx, dummyConvertView.easy_right, 0);
        CGContextAddLineToPoint(ctx, dummyConvertView.easy_right, screenHeight);
        
        topLabel.easy_left = dummyConvertView.easy_right + labelGap;
        bottomLabel.easy_left = dummyConvertView.easy_right + labelGap;
        
        if (topLabel.easy_right >= screenWidth || bottomLabel.easy_right >= screenWidth) {
            topLabel.easy_right = dummyConvertView.easy_right - labelGap;
            bottomLabel.easy_right = dummyConvertView.easy_right - labelGap;
        }
        
        heightLabel.easy_left = dummyConvertView.easy_right + labelGap;
        if (heightLabel.easy_right >= screenWidth) {
            heightLabel.easy_right = screenWidth - labelGap;
        }
    }
    
    // 上面的空間比較大, 切線畫在上面, 反之畫下面
    if (distanceToTop > distanceToBottom) {
        
        // 上切線
        CGContextMoveToPoint(ctx, 0, dummyConvertView.easy_top);
        CGContextAddLineToPoint(ctx, screenWidth, dummyConvertView.easy_top);
        
        leftLabel.easy_bottom = dummyConvertView.easy_top - labelGap;
        rightLabel.easy_bottom = dummyConvertView.easy_top - labelGap;
        
        if (leftLabel.easy_top <= 0 || rightLabel.easy_top <= 0) {
            leftLabel.easy_top = dummyConvertView.easy_top + labelGap;
            rightLabel.easy_top = dummyConvertView.easy_top + labelGap;
        }
        
        widthLabel.easy_bottom = dummyConvertView.easy_top - labelGap;
        if (widthLabel.easy_top <= 0) {
            widthLabel.easy_top = labelGap;
        }
    }
    else {
        
        // 下切線
        CGContextMoveToPoint(ctx, 0, dummyConvertView.easy_bottom);
        CGContextAddLineToPoint(ctx, screenWidth, dummyConvertView.easy_bottom);
        
        leftLabel.easy_top = dummyConvertView.easy_bottom + labelGap;
        rightLabel.easy_top = dummyConvertView.easy_bottom + labelGap;
        
        if (leftLabel.easy_bottom >= screenHeight || rightLabel.easy_bottom >= screenHeight) {
            leftLabel.easy_bottom = dummyConvertView.easy_bottom - labelGap;
            rightLabel.easy_bottom = dummyConvertView.easy_bottom - labelGap;
        }
        
        widthLabel.easy_top = dummyConvertView.easy_bottom + labelGap;
        if (widthLabel.easy_bottom >= screenHeight) {
            widthLabel.easy_bottom = screenHeight - labelGap;
        }
    }
    
    // 畫
    CGContextStrokePath(ctx);
    [self renderView:topLabel inContext:ctx];
    [self renderView:bottomLabel inContext:ctx];
    [self renderView:leftLabel inContext:ctx];
    [self renderView:rightLabel inContext:ctx];
    [self renderView:widthLabel inContext:ctx];
    [self renderView:heightLabel inContext:ctx];
    
    drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return drawImage;
}

@end
