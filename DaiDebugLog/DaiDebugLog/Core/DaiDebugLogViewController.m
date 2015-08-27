//
//  DaiDebugLogViewController.m
//  DaiDebugLog
//
//  Created by DaidoujiChen on 2015/8/21.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiDebugLogViewController.h"
#import "UIView+DaiDebugLogEasyFrame.h"
#import "DaiDebugLogViewHelper.h"

typedef enum {
    DaiDebugLogModeDefault,
    DaiDebugLogModeAim
} DaiDebugLogMode;

typedef enum {
    DaiDebugLogSwipeDirectionLeft,
    DaiDebugLogSwipeDirectionRight
} DaiDebugLogSwipeDirection;

#define borderWidth 10.0f
#define limitCellHeight 40.0f

@interface DaiDebugLogViewController ()

@property (nonatomic, assign) DaiDebugLogMode mode;

@property (nonatomic, weak) UIView *originView;

@property (nonatomic, weak) UIView *aimView;
@property (nonatomic, weak) UIImageView *aimImageView;
@property (nonatomic, strong) UIView *targetView;

@property (nonatomic, weak) UIView *debugLogView;
@property (nonatomic, weak) UITableView *debugLogTableView;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) NSMutableArray *debugLogs;
@property (nonatomic, strong) NSMutableArray *debugLogSizes;

@end

@implementation DaiDebugLogViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.debugLogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.debugLogs[indexPath.row];
    if (self.selectIndex == indexPath.row) {
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
        cell.textLabel.textColor = [UIColor redColor];
    }
    else {
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSValue *size = self.debugLogSizes[indexPath.row];
    if (self.selectIndex == indexPath.row) {
        return size.CGSizeValue.height;
    }
    else {
        return MIN(size.CGSizeValue.height, limitCellHeight);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSValue *size = self.debugLogSizes[indexPath.row];
    if (size.CGSizeValue.height > limitCellHeight) {
        if (self.selectIndex != indexPath.row) {
            self.selectIndex = indexPath.row;
            [tableView reloadData];
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else {
            self.selectIndex = NSNotFound;
            [tableView reloadData];
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    }
}

#pragma mark - instance method

- (BOOL)shouldReceiveTouchAtWindowPoint:(CGPoint)pointInWindowCoordinates {
    BOOL shouldReceiveTouch = NO;
    CGPoint pointInLocalCoordinates = [self.view convertPoint:pointInWindowCoordinates fromView:nil];
    
    if (CGRectContainsPoint(self.debugLogView.frame, pointInLocalCoordinates)) {
        shouldReceiveTouch = YES;
    }
    else if (CGRectContainsPoint(self.originView.frame, pointInLocalCoordinates)) {
        shouldReceiveTouch = YES;
    }
    else if (CGRectContainsPoint(self.aimView.frame, pointInLocalCoordinates)) {
        shouldReceiveTouch = YES;
    }
    else if (self.mode == DaiDebugLogModeAim) {
        shouldReceiveTouch = YES;
    }
    return shouldReceiveTouch;
}

- (void)addLog:(NSString *)log {
    
    // 預先做好需要執行的 block
    __weak DaiDebugLogViewController *weakSelf = self;
    void (^refresh)(void) = ^{
        [weakSelf.debugLogs addObject:log];
        
        // 計算字數長度
        CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(weakSelf.originView.frame) - 20;
        UITextView *sizeTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 0)];
        sizeTextView.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];;
        sizeTextView.text = log;
        CGSize newSize = [sizeTextView sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
        [weakSelf.debugLogSizes addObject:[NSValue valueWithCGSize:newSize]];
        
        // 重載
        [weakSelf.debugLogTableView reloadData];
        if (weakSelf.debugLogView && weakSelf.selectIndex == NSNotFound) {
            [weakSelf.debugLogTableView scrollToRowAtIndexPath:[weakSelf lastIndexPath] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    };
    
    // 根據當前的 thread, 決定 block 可以直接跑或是要重新倒回 main thread 跑
    if ([NSThread isMainThread]) {
        refresh();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), refresh);
    }
}

#pragma mark - private instance method

#pragma mark * init

- (void)setupInitValues {
    self.selectIndex = NSNotFound;
    self.debugLogs = [NSMutableArray array];
    self.debugLogSizes = [NSMutableArray array];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = YES;
    self.mode = DaiDebugLogModeDefault;
}

// 設定微笑 D 按鈕
- (void)setupOriginView {
    
    // 微笑 D 的大小
    CGFloat originSize = 40.0f;
    UILabel *originLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, originSize, originSize)];
    originLabel.backgroundColor = [UIColor whiteColor];
    originLabel.text = @"D";
    originLabel.textAlignment = NSTextAlignmentCenter;
    
    // 橘色字
    originLabel.textColor = [UIColor colorWithRed:243.0f / 255.0f green:138.0f / 255.0f blue:20.0f / 255.0f alpha:1.0f];
    originLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:35.0f];
    originLabel.layer.cornerRadius = originSize / 2;
    originLabel.layer.masksToBounds = YES;
    originLabel.layer.transform = CATransform3DRotate(originLabel.layer.transform, M_PI_4, 0.0, 0.0, 1);
    
    // 陰影 view
    UIView *originView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetWidth([UIScreen mainScreen].bounds) / 3, originSize, originSize)];
    originView.backgroundColor = [UIColor clearColor];
    originView.userInteractionEnabled = YES;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:originView.bounds cornerRadius:originSize / 2];
    [self defaultShadow:originView.layer];
    originView.layer.shadowPath = shadowPath.CGPath;
    
    // 加手勢
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOriginAction)];
    [originView addGestureRecognizer:tapGestureRecognizer];
    
    // 放到畫面上
    [originView addSubview:originLabel];
    [self.view addSubview:originView];
    self.originView = originView;
    [self refreshDebugViewPosition];
}

#pragma mark * generators

- (void)generateDebugLogView {
    
    // 裝所有東西的 container
    UIView *debugLogView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(self.originView.bounds) - borderWidth * 3, CGRectGetHeight([UIScreen mainScreen].bounds) / 3)];
    debugLogView.backgroundColor = [UIColor whiteColor];
    debugLogView.userInteractionEnabled = YES;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:debugLogView.bounds];
    [self defaultShadow:debugLogView.layer];
    debugLogView.layer.shadowPath = shadowPath.CGPath;
    
    // 顯示 log 的 table
    UITableView *debugLogTableView = [[UITableView alloc] initWithFrame:debugLogView.bounds style:UITableViewStylePlain];
    [debugLogTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    debugLogTableView.delegate = self;
    debugLogTableView.dataSource = self;
    
    // 放到畫面上
    [debugLogView addSubview:debugLogTableView];
    [self.view addSubview:debugLogView];
    self.debugLogTableView = debugLogTableView;
    self.debugLogView = debugLogView;
    [self refreshDebugLogViewPosition];
}

- (void)generateAimView {
    
    // A 的大小
    CGFloat aimSize = CGRectGetWidth(self.originView.bounds) * 0.8f;
    UILabel *aimLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, aimSize, aimSize)];
    aimLabel.backgroundColor = [UIColor whiteColor];
    aimLabel.text = @"A";
    aimLabel.textAlignment = NSTextAlignmentCenter;
    
    // 紅色字
    aimLabel.textColor = [UIColor redColor];
    aimLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:35.0f];
    aimLabel.layer.cornerRadius = aimSize / 2;
    aimLabel.layer.masksToBounds = YES;
    
    // 陰影 view
    UIView *aimView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetWidth([UIScreen mainScreen].bounds) / 3, aimSize, aimSize)];
    aimView.backgroundColor = [UIColor clearColor];
    aimView.userInteractionEnabled = YES;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:aimView.bounds cornerRadius:aimSize / 2];
    [self defaultShadow:aimView.layer];
    aimView.layer.shadowPath = shadowPath.CGPath;
    
    // 加手勢
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleAimAction)];
    [aimView addGestureRecognizer:tapGestureRecognizer];
    
    // 放到畫面上
    [aimView addSubview:aimLabel];
    [self.view addSubview:aimView];
    self.aimView = aimView;
    [self refreshAimViewPosition];
}

#pragma mark * gesture action

- (void)toggleOriginAction {
    switch (self.mode) {
        case DaiDebugLogModeDefault:
        {
            if (!self.debugLogView) {
                
                // log 內容畫面設置
                [self generateDebugLogView];
                [self generateAimView];
                
                // 顯示內容與顯示最後一項內容
                [self.debugLogTableView reloadData];
                if (self.debugLogs.count) {
                    [self.debugLogTableView scrollToRowAtIndexPath:[self lastIndexPath] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }
                
                // container 彈出動畫
                CGRect originalFrame = self.debugLogView.frame;
                [self containerViewOutsidePosition];
                [self aimViewOutsidePosition];
                
                __weak DaiDebugLogViewController *weakSelf = self;
                [UIView animateWithDuration:0.25f animations: ^{
                    weakSelf.debugLogView.frame = originalFrame;
                    [weakSelf refreshAimViewPosition];
                }];
            }
            else {
                // log 內容畫面設置
                self.selectIndex = NSNotFound;
                
                // container 彈回動畫
                __weak DaiDebugLogViewController *weakSelf = self;
                [UIView animateWithDuration:0.25f animations: ^{
                    [weakSelf containerViewOutsidePosition];
                    [weakSelf aimViewOutsidePosition];
                } completion: ^(BOOL finished) {
                    [weakSelf.debugLogView removeFromSuperview];
                    [weakSelf.aimView removeFromSuperview];
                }];
            }
            break;
        }
            
        case DaiDebugLogModeAim:
        {
            self.mode = DaiDebugLogModeDefault;
            [self.aimImageView removeFromSuperview];
            
            // container 彈回動畫
            __weak DaiDebugLogViewController *weakSelf = self;
            [UIView animateWithDuration:0.25f animations: ^{
                [weakSelf aimViewOutsidePosition];
            } completion: ^(BOOL finished) {
                [weakSelf.aimView removeFromSuperview];
            }];
            break;
        }
    }
}

- (void)toggleAimAction {
    switch (self.mode) {
        case DaiDebugLogModeDefault:
        {
            self.mode = DaiDebugLogModeAim;
            self.selectIndex = NSNotFound;
            
            // container 彈回動畫
            __weak DaiDebugLogViewController *weakSelf = self;
            [UIView animateWithDuration:0.25f animations: ^{
                [weakSelf containerViewOutsidePosition];
            } completion: ^(BOOL finished) {
                [weakSelf.debugLogView removeFromSuperview];
            }];
            break;
        }
            
        case DaiDebugLogModeAim:
        {
            // log 內容畫面設置
            [self generateDebugLogView];
            
            self.mode = DaiDebugLogModeDefault;
            for (UIGestureRecognizer *gestureRecognizer in self.view.gestureRecognizers) {
                [self.view removeGestureRecognizer:gestureRecognizer];
            };
            [self.aimImageView removeFromSuperview];
            
            // 顯示內容與顯示最後一項內容
            [self.debugLogTableView reloadData];
            if (self.debugLogs.count) {
                [self.debugLogTableView scrollToRowAtIndexPath:[self lastIndexPath] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            
            // container 彈出動畫
            CGRect originalFrame = self.debugLogView.frame;
            [self containerViewOutsidePosition];
            
            __weak DaiDebugLogViewController *weakSelf = self;
            [UIView animateWithDuration:0.25f animations: ^{
                weakSelf.debugLogView.frame = originalFrame;
            }];
            break;
        }
    }
}

#pragma mark * position calculate

// 檢查 debugView 在畫面的左邊右邊
- (BOOL)isDebugViewAtLeftSide {
    if (self.originView.center.x < CGRectGetWidth([UIScreen mainScreen].bounds) / 2) {
        return YES;
    }
    else {
        return NO;
    }
}

// 計算 debugview 位置
- (void)refreshDebugViewPosition {
    if ([self isDebugViewAtLeftSide]) {
        self.originView.easy_left = borderWidth;
    }
    else {
        self.originView.easy_right = CGRectGetWidth([UIScreen mainScreen].bounds) - borderWidth;
    }
}

// 計算 aimview 位置
- (void)refreshAimViewPosition {
    self.aimView.easy_midX = self.originView.easy_midX;
    self.aimView.easy_bottom = self.originView.easy_top - borderWidth;
}

// 計算 aimview 在畫面外的位置
- (void)aimViewOutsidePosition {
    self.aimView.easy_midX = self.originView.easy_midX;
    self.aimView.easy_bottom = 0;
}

// 計算 containerview 位置
- (void)refreshDebugLogViewPosition {
    self.debugLogView.easy_midY = self.originView.easy_midY;
    
    if ([self isDebugViewAtLeftSide]) {
        self.debugLogView.easy_left = self.originView.easy_right + borderWidth;
    }
    else {
        self.debugLogView.easy_right = self.originView.easy_left - borderWidth;
    }
    
    if (self.debugLogView.easy_top <= borderWidth) {
        self.debugLogView.easy_top = borderWidth;
    }
    else if (self.debugLogView.easy_bottom >= CGRectGetHeight([UIScreen mainScreen].bounds) - borderWidth) {
        self.debugLogView.easy_bottom = CGRectGetHeight([UIScreen mainScreen].bounds) - borderWidth;
    }
}

// 計算 containerview 在畫面外的位置
- (void)containerViewOutsidePosition {
    if ([self isDebugViewAtLeftSide]) {
        self.debugLogView.easy_midX += CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    else {
        self.debugLogView.easy_midX -= CGRectGetWidth([UIScreen mainScreen].bounds);
    }
}

#pragma mark * misc

- (NSIndexPath *)lastIndexPath {
    return [NSIndexPath indexPathForRow:self.debugLogs.count - 1 inSection:0];
}

- (void)defaultShadow:(CALayer *)layer {
    layer.masksToBounds = NO;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeZero;
    layer.shadowOpacity = 1.0f;
    layer.shadowRadius = 2.0f;
}

#pragma mark * touch event

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (self.mode) {
        case DaiDebugLogModeDefault:
        {
            UITouch *aTouch = [touches anyObject];
            
            if (aTouch.view == self.originView) {
                CGPoint currentLocation = [aTouch locationInView:self.view];
                CGPoint prevLocation = [aTouch previousLocationInView:self.view];
                float deltaX = currentLocation.x - prevLocation.x;
                float deltaY = currentLocation.y - prevLocation.y;
                CGPoint newCenter = self.originView.center;
                newCenter.x += deltaX;
                newCenter.y += deltaY;
                self.originView.center = newCenter;
                [self refreshAimViewPosition];
                [self refreshDebugLogViewPosition];
            }
            break;
        }
            
        case DaiDebugLogModeAim:
            break;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    
    switch (self.mode) {
        case DaiDebugLogModeDefault:
        {
            if (aTouch.view == self.originView) {
                
                __weak DaiDebugLogViewController *weakSelf = self;
                [UIView animateWithDuration:0.25f delay:0 usingSpringWithDamping:0.45 initialSpringVelocity:0.55 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
                    [weakSelf refreshDebugViewPosition];
                    [weakSelf refreshAimViewPosition];
                    [weakSelf refreshDebugLogViewPosition];
                } completion:nil];
            }
            break;
        }
            
        case DaiDebugLogModeAim:
        {
            CGPoint currentLocation = [aTouch locationInView:self.view];

            UIWindow *currentWindow = [DaiDebugLogViewHelper currentWindowHandlePoint:currentLocation exceptWindow:self.view.window];
            self.targetView = [[DaiDebugLogViewHelper recursiveSubviewsAtPoint:currentLocation inView:currentWindow skipHiddenViews:YES] lastObject];
            if (!self.aimImageView) {
                UIImageView *aimImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
                aimImageView.userInteractionEnabled = NO;
                [self.view addSubview:aimImageView];
                self.aimImageView = aimImageView;
            }
            self.aimImageView.image = [DaiDebugLogViewHelper drawView:self.targetView inWindow:self.view.window];
            break;
        }
    }
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValues];
    [self setupOriginView];
}

@end
