//
//  DaiDebugLog.m
//  DaiDebugLog
//
//  Created by DaidoujiChen on 2015/8/21.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiDebugLog.h"
#import <objc/runtime.h>
#import "DaiDebugLogWindow.h"
#import "DaiDebugLogViewController.h"

@implementation DaiDebugLog

#pragma mark - BackendDebugLogWindowDelegate

+ (BOOL)shouldHandleTouchAtPoint:(CGPoint)point {
    return [[self debugLogViewController] shouldReceiveTouchAtWindowPoint:point];
}

#pragma mark - class method

+ (void)show {
    [self debugLogWindow].rootViewController = [self debugLogViewController];
    [[self debugLogWindow] makeKeyAndVisible];
}

+ (void)addLog:(NSString *)log {
    [[self debugLogViewController] addLog:log];
}

#pragma mark - runtime objects

+ (DaiDebugLogWindow *)debugLogWindow {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DaiDebugLogWindow *debugLogWindow = [[DaiDebugLogWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        debugLogWindow.eventDelegate = (id <DaiDebugLogWindowDelegate>)self;
        objc_setAssociatedObject(self, _cmd, debugLogWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

+ (DaiDebugLogViewController *)debugLogViewController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [DaiDebugLogViewController new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

@end
