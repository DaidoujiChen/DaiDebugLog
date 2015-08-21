//
//  DaiDebugLogWindow.m
//  DaiDebugLog
//
//  Created by DaidoujiChen on 2015/8/21.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiDebugLogWindow.h"

@implementation DaiDebugLogWindow

#pragma mark - method to override

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return [self.eventDelegate shouldHandleTouchAtPoint:point];
}

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert - 1;
    }
    return self;
}

@end
