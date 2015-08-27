//
//  DaiDebugLogWindow.h
//  DaiDebugLog
//
//  Created by DaidoujiChen on 2015/8/21.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DaiDebugLogWindowDelegate;

@interface DaiDebugLogWindow : UIWindow

@property (nonatomic, weak) id <DaiDebugLogWindowDelegate> eventDelegate;

@end

@protocol DaiDebugLogWindowDelegate <NSObject>
@required
- (BOOL)shouldHandleTouchAtPoint:(CGPoint)point;

@end
