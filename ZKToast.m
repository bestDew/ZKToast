//
//  ZKToast.m
//  ZKToastDemo
//
//  Created by bestdew on 2018/12/5.
//  Copyright © 2018 bestdew. All rights reserved.
//
//                      d*##$.
// zP"""""$e.           $"    $o
//4$       '$          $"      $
//'$        '$        J$       $F
// 'b        $k       $>       $
//  $k        $r     J$       d$
//  '$         $     $"       $~
//   '$        "$   '$E       $
//    $         $L   $"      $F ...
//     $.       4B   $      $$$*"""*b
//     '$        $.  $$     $$      $F
//      "$       R$  $F     $"      $
//       $k      ?$ u*     dF      .$
//       ^$.      $$"     z$      u$$$$e
//        #$b             $E.dW@e$"    ?$
//         #$           .o$$# d$$$$c    ?F
//          $      .d$$#" . zo$>   #$r .uF
//          $L .u$*"      $&$$$k   .$$d$$F
//           $$"            ""^"$$$P"$P9$
//          JP              .o$$$$u:$P $$
//          $          ..ue$"      ""  $"
//         d$          $F              $
//         $$     ....udE             4B
//          #$    """"` $r            @$
//           ^$L        '$            $F
//             RN        4N           $
//              *$b                  d$
//               $$k                 $F
//               $$b                $F
//                 $""               $F
//                 '$                $
//                  $L               $
//                  '$               $
//                   $               $

#import "ZKToast.h"

NSString * const ZKToastWillAppearNotification = @"ZKToastWillAppearNotification";
NSString * const ZKToastDidAppearNotification = @"ZKToastDidAppearNotification";
NSString * const ZKToastWillDisappearNotification = @"ZKToastWillDisappearNotification";
NSString * const ZKToastDidDisappearNotification = @"ZKToastDidDisappearNotification";
NSString * const ZKToastStatusUserInfoKey = @"ZKToastStatusUserInfoKey";

@interface ZKToast ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, assign) CGSize  minimumSize;
@property (nonatomic, assign) CGFloat minimumDismissTimeInterval;
@property (nonatomic, assign) ZKToastVerticalPosition position;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isNotchScreen;

@end

@implementation ZKToast

#pragma mark -- Init
+ (instancetype)sharedToast
{
    static ZKToast *toast;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toast = [[super allocWithZone:NULL] init];
    });
    return toast;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [ZKToast sharedToast];
}

- (instancetype)init
{
    if (self = [super init]) {
        
        [self initToast];
        [self addObserver];
    }
    return self;
}

#pragma mark -- Public Methods
+ (void)setMinimumSize:(CGSize)minimumSize
{
    [ZKToast sharedToast].minimumSize = minimumSize;
}

+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval
{
    [ZKToast sharedToast].minimumDismissTimeInterval = interval;
}

+ (void)setTextFont:(UIFont *)font
{
    [ZKToast sharedToast].statusLabel.font = font;
}

+ (void)setTextColor:(UIColor *)color
{
    [ZKToast sharedToast].statusLabel.textColor = color;
}

+ (void)setVerticalPosition:(ZKToastVerticalPosition)position
{
    [ZKToast sharedToast].position = position;
}

+ (void)setBackgroundColor:(UIColor *)bgColor
{
    [ZKToast sharedToast].contentView.layer.backgroundColor = bgColor.CGColor;
}

+ (void)setCornerRadius:(CGFloat)cornerRadius
{
    [ZKToast sharedToast].contentView.layer.cornerRadius = cornerRadius;
}

+ (void)setShadowColor:(UIColor *)color
{
    [ZKToast sharedToast].contentView.layer.shadowColor = color.CGColor;
}

+ (void)setShadowOffset:(CGSize)size
{
    [ZKToast sharedToast].contentView.layer.shadowOffset = size;
}

+ (void)setShadowOpacity:(CGFloat)opacity
{
    [ZKToast sharedToast].contentView.layer.shadowOpacity = opacity;
}

+ (void)showWithStatus:(NSString *)status
{
    [[ZKToast sharedToast] showWithStatus:status];
}

+ (void)dismiss
{
    [[ZKToast sharedToast] dismiss];
}

#pragma mark -- Private Methods
- (void)initToast
{
    _minimumSize = CGSizeMake(100.f, 30.f);
    _minimumDismissTimeInterval = 2.f;
    _position = ZKToastVerticalPositionCenter;
    if (@available(iOS 11.0, *)) {
        _isNotchScreen = (UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom > 0.f);
    }
    
    _contentView = [[UIView alloc] init];
    _contentView.alpha = 0.f;
    _contentView.layer.backgroundColor = [UIColor blackColor].CGColor;
    _contentView.layer.cornerRadius = 15.f;
    _contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    _contentView.layer.shadowOffset = CGSizeZero;
    _contentView.layer.shadowOpacity = 0.7;
    
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.numberOfLines = 0;
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.font = [UIFont systemFontOfSize:14.f];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:_statusLabel];
    
    [self updateLayout];
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    if (_isShowing) [self updateLayout];
}

- (void)updateLayout
{
    CGFloat y = 0.f, width = 0.f, height = 0.f;
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGSize maxSize = CGSizeMake(screenSize.width - 100.f, 100.f);
    
    if (_statusLabel.text == nil) {
        width = _minimumSize.width;
        height = _minimumSize.height;
    } else {
        CGSize textSize = [_statusLabel sizeThatFits:maxSize];
        CGFloat tempWidth = textSize.width + 30.f;
        CGFloat tempHeight = textSize.height + 10.f;
        if (tempWidth < _minimumSize.width) {
            width = _minimumSize.width;
        } else {
            width = tempWidth;
        }
        if (tempHeight < _minimumSize.height) {
            height = _minimumSize.height;
        } else {
            height = tempHeight;
        }
    }
    
    CGFloat x = (screenSize.width - width) / 2;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    switch (_position) {
        case ZKToastVerticalPositionCenter:
            y = (screenSize.height - height) / 2;
            break;
        case ZKToastVerticalPositionTop:
            if (orientation == UIInterfaceOrientationPortrait ||
                orientation == UIInterfaceOrientationPortraitUpsideDown) { // 竖屏
                y = _isNotchScreen ? 90.f : 66.f;
            } else { // 横屏
                y = 34.f;
            }
            break;
        case ZKToastVerticalPositionBottom:
            if (orientation == UIInterfaceOrientationPortrait ||
                orientation == UIInterfaceOrientationPortraitUpsideDown) { // 竖屏
                y = screenSize.height - height - (_isNotchScreen ? 85.f : 51.f);
            } else { // 横屏
                y = screenSize.height - height - (_isNotchScreen ? 49.f : 34.f);
            }
            break;
    }
    _contentView.frame = CGRectMake(x, y, width, height);
    _statusLabel.frame = _contentView.bounds;
}

- (void)showWithStatus:(NSString *)status
{
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // 保证在主线程执行
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.isShowing = YES;
        
        // 先取消未执行的任务
        [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(dismiss) object:nil];
       
        strongSelf.statusLabel.text = status;
        [strongSelf updateLayout];
        
        // 保证 toast 显示在最上层
        UIWindow *window = UIApplication.sharedApplication.delegate.window;
        [window addSubview:strongSelf.contentView];
        [window bringSubviewToFront:strongSelf.contentView];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ZKToastWillAppearNotification
                                                            object:strongSelf
                                                          userInfo:[strongSelf notificationUserInfo]];
        
        [UIView animateWithDuration:0.15 delay:0.f options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            strongSelf.contentView.alpha = 1.f;
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ZKToastDidAppearNotification
                                                                object:strongSelf
                                                              userInfo:[strongSelf notificationUserInfo]];
        }];
        
        NSTimeInterval delay = strongSelf.minimumDismissTimeInterval;
        [strongSelf performSelector:@selector(dismiss) withObject:nil afterDelay:delay];
    }];
}

- (void)dismiss
{
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // 保证在主线程执行
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // 先取消未执行的任务
        [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(dismiss) object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ZKToastWillDisappearNotification
                                                            object:strongSelf
                                                          userInfo:[strongSelf notificationUserInfo]];
        
        [UIView animateWithDuration:0.15 delay:0.f options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            strongSelf.contentView.alpha = 0.f;
        } completion:^(BOOL finished) {
            strongSelf.isShowing = NO;
            [strongSelf.contentView removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZKToastDidDisappearNotification
                                                                object:strongSelf
                                                              userInfo:[strongSelf notificationUserInfo]];
        }];
    }];
}

- (void)setPosition:(ZKToastVerticalPosition)position
{
    _position = position;
    
    CGRect rect = _statusLabel.frame;
    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    switch (position) {
        case ZKToastVerticalPositionCenter:
            rect.origin.y = (screenHeight - rect.size.height) / 2;
            break;
        case ZKToastVerticalPositionTop:
            if (orientation == UIInterfaceOrientationPortrait ||
                orientation == UIInterfaceOrientationPortraitUpsideDown) { // 竖屏
                rect.origin.y = _isNotchScreen ? 90.f : 66.f;
            } else { // 横屏
                rect.origin.y = 34.f;
            }
            break;
        case ZKToastVerticalPositionBottom:
            if (orientation == UIInterfaceOrientationPortrait ||
                orientation == UIInterfaceOrientationPortraitUpsideDown) { // 竖屏
                rect.origin.y = screenHeight - rect.size.height - (_isNotchScreen ? 85.f : 51.f);
            } else { // 横屏
                rect.origin.y = screenHeight - rect.size.height - (_isNotchScreen ? 49.f : 34.f);
            }
            break;
    }
    _contentView.frame = rect;
}

- (NSDictionary*)notificationUserInfo
{
    return (_statusLabel.text) ? @{ZKToastStatusUserInfoKey:_statusLabel.text} : nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
