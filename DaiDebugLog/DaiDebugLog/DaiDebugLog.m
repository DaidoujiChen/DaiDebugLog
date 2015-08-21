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
    [self backendDebugLogWindow].rootViewController = [self debugLogViewController];
    [[self backendDebugLogWindow] makeKeyAndVisible];
}

+ (void)addLog:(NSString *)log {
    [[self debugLogViewController] addLog:log];
}

#pragma mark - runtime objects

+ (DaiDebugLogWindow *)backendDebugLogWindow {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DaiDebugLogWindow *backendDebugLogWindow = [DaiDebugLogWindow new];
        backendDebugLogWindow.eventDelegate = (id <DaiDebugLogWindowDelegate>)self;
        objc_setAssociatedObject(self, _cmd, backendDebugLogWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
