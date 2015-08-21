//
//  DaiDebugLogViewController.m
//  DaiDebugLog
//
//  Created by DaidoujiChen on 2015/8/21.
//  Copyright (c) 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiDebugLogViewController.h"

#define borderWidth 10.0f
#define limitCellHeight 40.0f

@interface DaiDebugLogViewController ()

@property (nonatomic, weak) UIView *debugView;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UITableView *debugTableView;
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
    
    if (CGRectContainsPoint(self.containerView.frame, pointInLocalCoordinates)) {
        shouldReceiveTouch = YES;
    }
    else if (CGRectContainsPoint(self.debugView.frame, pointInLocalCoordinates)) {
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
        CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(weakSelf.debugView.frame) - 20;
        UITextView *sizeTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 0)];
        sizeTextView.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];;
        sizeTextView.text = log;
        CGSize newSize = [sizeTextView sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
        [weakSelf.debugLogSizes addObject:[NSValue valueWithCGSize:newSize]];
        
        // 重載
        [weakSelf.debugTableView reloadData];
        if (weakSelf.containerView && weakSelf.selectIndex == NSNotFound) {
            [weakSelf.debugTableView scrollToRowAtIndexPath:[weakSelf lastIndexPath] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
}

// 設定微笑 D 按鈕
- (void)setupDebugView {
    
    // 微笑 D 的大小
    CGFloat buttonSize = 40.0f;
    UILabel *debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, buttonSize, buttonSize)];
    debugLabel.backgroundColor = [UIColor whiteColor];
    debugLabel.text = @"D";
    debugLabel.textAlignment = NSTextAlignmentCenter;
    
    // 橘色字
    debugLabel.textColor = [UIColor colorWithRed:243.0f / 255.0f green:138.0f / 255.0f blue:20.0f / 255.0f alpha:1.0f];
    debugLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:35.0f];
    debugLabel.layer.cornerRadius = buttonSize / 2;
    debugLabel.layer.masksToBounds = YES;
    debugLabel.layer.transform = CATransform3DRotate(debugLabel.layer.transform, M_PI_4, 0.0, 0.0, 1);
    
    // 陰影 view
    UIView *debugView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetWidth([UIScreen mainScreen].bounds) / 3, buttonSize, buttonSize)];
    debugView.backgroundColor = [UIColor clearColor];
    debugView.userInteractionEnabled = YES;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:debugView.bounds cornerRadius:buttonSize / 2];
    debugView.layer.masksToBounds = NO;
    debugView.layer.shadowColor = [UIColor blackColor].CGColor;
    debugView.layer.shadowOffset = CGSizeZero;
    debugView.layer.shadowOpacity = 1.0f;
    debugView.layer.shadowRadius = 2.0f;
    debugView.layer.shadowPath = shadowPath.CGPath;
    
    // 加手勢
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleAction)];
    [debugView addGestureRecognizer:tapGestureRecognizer];
    
    // 放到畫面上
    [debugView addSubview:debugLabel];
    [self.view addSubview:debugView];
    self.debugView = debugView;
    self.debugView.center = [self newDebugViewCenter];
}

- (void)setupContainerView {
    
    // 裝所有東西的 container
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(self.debugView.bounds) - borderWidth * 3, CGRectGetHeight([UIScreen mainScreen].bounds) / 3)];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.userInteractionEnabled = YES;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:containerView.bounds];
    containerView.layer.masksToBounds = NO;
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOffset = CGSizeZero;
    containerView.layer.shadowOpacity = 1.0f;
    containerView.layer.shadowRadius = 2.0f;
    containerView.layer.shadowPath = shadowPath.CGPath;
    
    // 顯示 log 的 table
    UITableView *debugTableView = [[UITableView alloc] initWithFrame:containerView.bounds style:UITableViewStylePlain];
    [debugTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    debugTableView.delegate = self;
    debugTableView.dataSource = self;
    
    // 放到畫面上
    [containerView addSubview:debugTableView];
    [self.view addSubview:containerView];
    self.debugTableView = debugTableView;
    self.containerView = containerView;
    self.containerView.frame = [self newContainerViewFrame];
}

#pragma mark * action

- (void)toggleAction {
    if (!self.containerView) {
        
        // log 內容畫面設置
        [self setupContainerView];
        
        // 顯示內容與顯示最後一項內容
        [self.debugTableView reloadData];
        if (self.debugLogs.count) {
            [self.debugTableView scrollToRowAtIndexPath:[self lastIndexPath] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        
        // container 彈出動畫
        CGRect originalFrame = self.containerView.frame;
        self.containerView.frame = [self containerViewOutsideFrame];
        
        __weak DaiDebugLogViewController *weakSelf = self;
        [UIView animateWithDuration:0.25f animations: ^{
            weakSelf.containerView.frame = originalFrame;
        }];
    }
    else {
        // log 內容畫面設置
        self.selectIndex = NSNotFound;
        
        // container 彈回動畫
        __weak DaiDebugLogViewController *weakSelf = self;
        [UIView animateWithDuration:0.25f animations: ^{
            weakSelf.containerView.frame = [weakSelf containerViewOutsideFrame];
        } completion: ^(BOOL finished) {
            [weakSelf.containerView removeFromSuperview];
        }];
    }
}

#pragma mark * position calculate

// 檢查 debugView 在畫面的左邊右邊
- (BOOL)isDebugViewAtLeftSide {
    if (self.debugView.center.x < CGRectGetWidth([UIScreen mainScreen].bounds) / 2) {
        return YES;
    }
    else {
        return NO;
    }
}

// 計算 debugview 位置
- (CGPoint)newDebugViewCenter {
    CGPoint newCenter = self.debugView.center;
    CGFloat gap = CGRectGetWidth(self.debugView.bounds) / 2 + borderWidth;
    if ([self isDebugViewAtLeftSide]) {
        newCenter.x = gap;
    }
    else {
        newCenter.x = CGRectGetWidth([UIScreen mainScreen].bounds) - gap;
    }
    return newCenter;
}

// 計算 containerview 位置
- (CGRect)newContainerViewFrame {
    CGPoint newCenter = self.containerView.center;
    newCenter.y = self.debugView.center.y;
    self.containerView.center = newCenter;
    
    CGRect newFrame = self.containerView.frame;
    if ([self isDebugViewAtLeftSide]) {
        newFrame.origin.x = CGRectGetMaxX(self.debugView.frame) + borderWidth;
    }
    else {
        newFrame.origin.x = CGRectGetMinX(self.debugView.frame) - (CGRectGetWidth(newFrame) + borderWidth);
    }
    
    if (CGRectGetMinY(newFrame) <= borderWidth) {
        newFrame.origin.y = borderWidth;
    }
    else if (CGRectGetMaxY(newFrame) >= CGRectGetHeight([UIScreen mainScreen].bounds) - borderWidth) {
        newFrame.origin.y = CGRectGetHeight([UIScreen mainScreen].bounds) - borderWidth - CGRectGetHeight(newFrame);
    }
    return newFrame;
}

// 計算 containerview 在畫面外的位置
- (CGRect)containerViewOutsideFrame {
    CGRect outsideFrame = self.containerView.frame;
    if ([self isDebugViewAtLeftSide]) {
        outsideFrame.origin.x += CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    else {
        outsideFrame.origin.x -= CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    return outsideFrame;
}

#pragma mark * misc

- (NSIndexPath *)lastIndexPath {
    return [NSIndexPath indexPathForRow:self.debugLogs.count - 1 inSection:0];
}

#pragma mark * touch event

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    
    if (aTouch.view == self.debugView) {
        CGPoint currentLocation = [aTouch locationInView:self.view];
        CGPoint prevLocation = [aTouch previousLocationInView:self.view];
        float deltaX = currentLocation.x - prevLocation.x;
        float deltaY = currentLocation.y - prevLocation.y;
        CGPoint newCenter = self.debugView.center;
        newCenter.x += deltaX;
        newCenter.y += deltaY;
        self.debugView.center = newCenter;
        self.containerView.frame = [self newContainerViewFrame];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    
    if (aTouch.view == self.debugView) {
        CGPoint newCenter = [self newDebugViewCenter];
        
        __weak DaiDebugLogViewController *weakSelf = self;
        [UIView animateWithDuration:0.25f delay:0 usingSpringWithDamping:0.45 initialSpringVelocity:0.55 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
            weakSelf.debugView.center = newCenter;
            CGRect newFrame = [weakSelf newContainerViewFrame];
            weakSelf.containerView.frame = newFrame;
        } completion:nil];
    }
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValues];
    [self setupDebugView];
}

@end
