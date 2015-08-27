//
//  DaiDebugLogViewController.h
//  DaiDebugLog
//
//  Created by DaidoujiChen on 2015/8/21.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DaiDebugLogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (BOOL)shouldReceiveTouchAtWindowPoint:(CGPoint)pointInWindowCoordinates;
- (void)addLog:(NSString *)log;

@end
