//
//  AppDelegate.m
//  DaiDebugLog
//
//  Created by DaidoujiChen on 2015/8/21.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "DaiDebugLog.h"

@implementation AppDelegate

#pragma mark - private instance method

- (void)randomAddLog {
    static NSArray *randomLogs = nil;
    if (!randomLogs) {
        randomLogs = @[ @"hello", @"I'm Daidouji", @"it is a longlonglonglonglonglonglonglonglonglonglong log", @"where", @"is", @"the", @"log" ];
    }
    [DaiDebugLog addLog:randomLogs[arc4random()%randomLogs.count]];
}

#pragma mark - app life cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DaiDebugLog show];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(randomAddLog) userInfo:nil repeats:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [MainViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
