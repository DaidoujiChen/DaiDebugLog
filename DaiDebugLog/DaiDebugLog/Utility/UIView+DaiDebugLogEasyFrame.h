//
//  UIView+DaiDebugLogEasyFrame.h
//  DaiDebugLog
//
//  Created by DaidoujiChen on 2015/8/28.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DaiDebugLogEasyFrame)

#pragma mark - lazy

@property (nonatomic, readonly) NSString *easy_frameString;

#pragma mark - frame

@property (nonatomic, assign) CGFloat easy_x;
@property (nonatomic, assign) CGFloat easy_y;
@property (nonatomic, assign) CGFloat easy_width;
@property (nonatomic, assign) CGFloat easy_height;
@property (nonatomic, assign) CGSize easy_size;
@property (nonatomic, assign) CGPoint easy_origin;

#pragma mark - extend

@property (nonatomic, assign) CGFloat easy_top;
@property (nonatomic, assign) CGFloat easy_bottom;
@property (nonatomic, assign) CGFloat easy_left;
@property (nonatomic, assign) CGFloat easy_right;
@property (nonatomic, assign) CGFloat easy_midX;
@property (nonatomic, assign) CGFloat easy_midY;

#pragma mark - position

@property (nonatomic, assign) CGPoint easy_leftTop;
@property (nonatomic, assign) CGPoint easy_leftBottom;
@property (nonatomic, assign) CGPoint easy_rightTop;
@property (nonatomic, assign) CGPoint easy_rightBottom;

@end
