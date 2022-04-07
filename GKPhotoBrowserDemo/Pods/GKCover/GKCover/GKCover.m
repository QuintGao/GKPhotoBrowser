//
//  GKCover.m
//  GKCoverDemo
//
//  Created by QuintGao on 16/8/24.
//  Copyright © 2016年 QuintGao. All rights reserved.
//  GKCover-一个简单的遮罩视图，让你的弹窗更easy，支持自定义遮罩弹窗
//  github:https://github.com/QuintGao/GKCover

#import "GKCover.h"

#pragma mark - 内部记录
static GKCover          *_cover;          // 遮罩
static UIView           *_fromView;       // 显示在此视图上
static UIView           *_contentView;    // 显示的视图
static CGFloat          _margin;          // 遮罩距离父视图的间距
static BOOL             _animated;        // 是否需要动画
static showBlock        _showBlock;       // 显示时的回调block
static hideBlock        _hideBlock;       // 隐藏时的回调block
static BOOL             _notclick;        // 是否能点击的判断
static GKCoverStyle     _style;           // 遮罩类型
static GKCoverShowStyle _showStyle;       // 显示类型
static BOOL             _hasCover;        // 遮罩是否已经显示的判断值
static BOOL             _isHideStatusBar; // 遮罩是否遮盖状态栏
static CAAnimation      *_animation;      // 中间弹窗动画

// 分离动画类型
static GKCoverShowAnimStyle _showAnimStyle;
static GKCoverHideAnimStyle _hideAnimStyle;

static UIColor          *_bgColor;         // 背景色

@implementation GKCover

+ (void)coverFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle notClick:(BOOL)notClick
{
    [self coverFrom:fromView contentView:contentView style:style showStyle:showStyle showAnimStyle:showAnimStyle hideAnimStyle:hideAnimStyle notClick:notClick showBlock:nil hideBlock:nil];
}

+ (void)coverFrom:(UIView *)fromView contentView:(UIView *)contentView margin:(CGFloat)margin style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle notClick:(BOOL)notClick {
    [self coverFrom:fromView contentView:contentView margin:margin style:style showStyle:showStyle showAnimStyle:showAnimStyle hideAnimStyle:hideAnimStyle notClick:notClick showBlock:nil hideBlock:nil];
}

+ (void)coverFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle notClick:(BOOL)notClick showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock {
    [self coverFrom:fromView contentView:contentView margin:0 style:style showStyle:showStyle showAnimStyle:showAnimStyle hideAnimStyle:hideAnimStyle notClick:notClick showBlock:showBlock hideBlock:hideBlock];
}

+ (void)coverFrom:(UIView *)fromView contentView:(UIView *)contentView margin:(CGFloat)margin style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle notClick:(BOOL)notClick showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock {
    if ([self hasCover]) return;
    
    _fromView       = fromView;
    _contentView    = contentView;
    _margin         = margin;
    _style          = style;
    _showStyle      = showStyle;
    _showAnimStyle  = showAnimStyle;
    _hideAnimStyle  = hideAnimStyle;
    _notclick       = notClick;
    _showBlock      = showBlock;
    _hideBlock      = hideBlock;
    
    // 创建遮罩
    GKCover *cover = [self cover];
    CGRect frame = fromView.bounds;
    switch (showStyle) {
        case GKCoverShowStyleTop: {
            frame.origin.y = margin;
            frame.size.height -= margin;
            _contentView.gk_y = margin;
        }
            break;
        case GKCoverShowStyleBottom: {
            frame.size.height -= margin;
        }
            break;
        case GKCoverShowStyleLeft: {
            frame.origin.x = margin;
            frame.size.width -= margin;
            _contentView.gk_x = margin;
        }
            break;
        case GKCoverShowStyleRight: {
            frame.size.width -= margin;
        }
            break;
        default:
            break;
    }
    cover.frame = frame;
    [fromView addSubview:cover];
    _cover = cover;
    
    switch (style) {
        case GKCoverStyleTranslucent: // 半透明
            [self setupTranslucentCover:cover];
            break;
        case GKCoverStyleTransparent: // 全透明
            [self setupTransparentCover:cover];
            break;
        case GKCoverStyleBlur:        // 高斯模糊
            [self setupBlurCover:cover];
            break;
            
        default:
            break;
    }
    
    [self showCover];
}

+ (void)coverHideStatusBarWithContentView:(UIView *)contentView style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle notClick:(BOOL)notClick showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock {
    
    if ([self hasCover]) return;
    
    _isHideStatusBar = YES;
    
    _style         = style;
    _showStyle     = showStyle;
    _showAnimStyle = showAnimStyle;
    _hideAnimStyle = hideAnimStyle;
    _contentView   = contentView;
    _margin        = 0;
    _notclick      = notClick;
    _showBlock     = showBlock;
    _hideBlock     = hideBlock;
    
    UIWindow *fromView   = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    fromView.windowLevel = UIWindowLevelAlert;
    fromView.hidden      = NO;
    [fromView makeKeyAndVisible];
    
    _fromView = fromView;
    
    // 创建遮罩
    GKCover *cover = [self cover];
    // 设置大小和颜色
    cover.frame = fromView.bounds;
    // 添加遮罩
    [fromView addSubview:cover];
    _cover = cover;
    
    switch (style) {
        case GKCoverStyleTranslucent: // 半透明
            [self setupTranslucentCover:cover];
            break;
        case GKCoverStyleTransparent: // 全透明
            [self setupTransparentCover:cover];
            break;
        case GKCoverStyleBlur:        // 高斯模糊
            [self setupBlurCover:cover];
            break;
            
        default:
            break;
    }
    
    [self showCover];
}

+ (void)showAlertViewFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style animation:(CAAnimation *)animation notClick:(BOOL)notClick {
    [self showAlertViewFrom:fromView contentView:contentView style:style animation:animation notClick:notClick showBlock:nil hideBlock:nil];
}

+ (void)showAlertViewFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style animation:(CAAnimation *)animation notClick:(BOOL)notClick showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock {
    _animation = animation;
    [self coverFrom:fromView contentView:contentView style:style showStyle:GKCoverShowStyleCenter showAnimStyle:GKCoverShowAnimStyleCenter hideAnimStyle:GKCoverHideAnimStyleCenter notClick:notClick showBlock:showBlock hideBlock:hideBlock];
}

+ (instancetype)cover {
    // cover一经初始化就存在
    _hasCover = YES;
    return [[self alloc] init];
}

+ (BOOL)hasCover {
    if (!_cover) {
        _hasCover = NO;
    }
    return _hasCover;
}

+ (void)changeAlpha:(CGFloat)alpha {
    _cover.alpha = alpha;
}

+ (void)changeCoverBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    _cover.backgroundColor = bgColor;
}

+ (void)hideCoverWithHideBlock:(hideBlock)hideBlock {
    _hideBlock = hideBlock;
    [GKCover hideCover];
}

+ (void)hideCoverWithoutAnimation {
    if (!_cover) {
        _hasCover = NO;
        return;
    }
    if (!_hasCover) return;
    // 这里为了防止动画未完成导致的不能及时判断cover是否存在，实际上cover再这里并没有销毁
    _hasCover = NO;
    [self remove];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 自动伸缩
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _animated = NO;
    }
    return self;
}

+ (void)showCover {
    [_fromView addSubview:_contentView];
    
    switch (_showStyle) {
        case GKCoverShowStyleTop: {  // 显示在顶部
            _contentView.gk_centerX = _cover.gk_centerX;
            if (_showAnimStyle == GKCoverShowAnimStyleTop) {
                _contentView.gk_y = -_contentView.gk_height;
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_y = _margin;
                }completion:^(BOOL finished) {
                    !_showBlock ? : _showBlock();
                }];
            }else{
                !_showBlock ? : _showBlock();
                _contentView.gk_y = _margin;
            }
        }
            break;
        case GKCoverShowStyleCenter: {  // 显示在中间
            _contentView.gk_centerX = _fromView.gk_centerX;
            if (_showAnimStyle == GKCoverShowAnimStyleTop) { // 上进
                _contentView.gk_y = -_contentView.gk_height;
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.center = _fromView.center;
                }completion:^(BOOL finished) {
                    !_showBlock ? : _showBlock();
                }];
            }else if (_showAnimStyle == GKCoverShowAnimStyleCenter) { // 中间动画
                _contentView.center = _fromView.center;
                [self animationAlert:_contentView];
            }else if (_showAnimStyle == GKCoverShowAnimStyleBottom) { // 下进
                _contentView.gk_y = _fromView.gk_height;
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.center = _fromView.center;
                }completion:^(BOOL finished) {
                    !_showBlock ? : _showBlock();
                }];
            }else{ // 无动画
                _contentView.center = _fromView.center;
                !_showBlock ? : _showBlock();
            }
        }
            break;
        case GKCoverShowStyleBottom: { // 显示在底部
            _contentView.gk_centerX = _cover.gk_centerX;
            if (_showAnimStyle == GKCoverShowAnimStyleBottom) {
                _contentView.gk_y = _cover.gk_height;
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_y = _cover.gk_height - _contentView.gk_height;
                }completion:^(BOOL finished) {
                    !_showBlock ? : _showBlock();
                }];
            }else{
                !_showBlock ? : _showBlock();
                _contentView.gk_y = _cover.gk_height - _contentView.gk_height;
            }
        }
            break;
        case GKCoverShowStyleLeft: { // 显示在左侧
            _contentView.gk_centerY = _cover.gk_height * 0.5f;
            if (_showAnimStyle == GKCoverShowAnimStyleLeft) {
                _contentView.gk_x = -_contentView.gk_width;
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_x = _margin;
                }completion:^(BOOL finished) {
                    !_showBlock ? : _showBlock();
                }];
            }else {
                !_showBlock ? : _showBlock();
                _contentView.gk_x = _margin;
            }
        }
            break;
        case GKCoverShowStyleRight: { // 显示在右侧
            _contentView.gk_centerY = _cover.gk_height * 0.5f;
            if (_showAnimStyle == GKCoverShowAnimStyleRight) {
                _contentView.gk_x = _fromView.gk_width;
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_x = _cover.gk_width - _contentView.gk_width;
                }completion:^(BOOL finished) {
                    !_showBlock ? : _showBlock();
                }];
            }else {
                !_showBlock ? : _showBlock();
                _contentView.gk_x = _cover.gk_width - _contentView.gk_width;
            }
        }
            break;
            
        default:
            break;
    }
}

+ (void)hideCover {
    if (!_cover) {
        _hasCover = NO;
        return;
    }
    if (!_hasCover) return;
    // 这里为了防止动画未完成导致的不能及时判断cover是否存在，实际上cover再这里并没有销毁
    _hasCover = NO;
    
    switch (_showStyle) {
        case GKCoverShowStyleTop: { // 显示在顶部
            if (_hideAnimStyle == GKCoverHideAnimStyleTop) {
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_y = -_contentView.gk_height;
                }completion:^(BOOL finished) {
                    [self remove];
                }];
            }else{
                _contentView.gk_y = -_contentView.gk_height;
                [self remove];
            }
        }
            break;
        case GKCoverShowStyleCenter: { // 显示在中间
            if (_hideAnimStyle == GKCoverHideAnimStyleTop) { // 上出
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_y = -_contentView.gk_height;
                }completion:^(BOOL finished) {
                    [self remove];
                }];
            }else if (_hideAnimStyle == GKCoverHideAnimStyleCenter) { // 中间动画
                [self remove];
            }else if (_hideAnimStyle == GKCoverHideAnimStyleBottom) { // 下出
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_y = _cover.gk_height;
                }completion:^(BOOL finished) {
                    [self remove];
                }];
            }else{ // 无动画
                _contentView.center = _cover.center;
                [self remove];
            }
        }
            break;
        case GKCoverShowStyleBottom: { // 显示在底部
            if (_hideAnimStyle == GKCoverHideAnimStyleBottom) {
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_y = _cover.gk_height;
                }completion:^(BOOL finished) {
                    [self remove];
                }];
            }else{
                _contentView.gk_y = _cover.gk_height;
                [self remove];
            }
        }
            break;
        case GKCoverShowStyleLeft: { // 显示在左侧
            if (_hideAnimStyle == GKCoverHideAnimStyleLeft) {
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_x = -_contentView.gk_width;
                }completion:^(BOOL finished) {
                    [self remove];
                }];
            }else{
                _contentView.gk_x = -_contentView.gk_width;
                [self remove];
            }
        }
            break;
        case GKCoverShowStyleRight: { // 显示在右侧
            if (_hideAnimStyle == GKCoverHideAnimStyleRight) {
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_x = _cover.gk_width;
                }completion:^(BOOL finished) {
                    [self remove];
                }];
            }else{
                _contentView.gk_x = _cover.gk_width;
                [self remove];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Private Method
/// 半透明遮罩
+ (void)setupTranslucentCover:(UIView *)cover {
    cover.backgroundColor = _bgColor ? _bgColor : [UIColor blackColor];
    cover.alpha = kAlpha;
    [self coverAddTap:cover];
}

/// 全透明遮罩
+ (void)setupTransparentCover:(UIView *)cover {
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.gk_size = cover.gk_size;
    bgView.userInteractionEnabled = YES;
    [self coverAddTap:bgView];
    
    cover.backgroundColor = [UIColor clearColor];
    [cover addSubview:bgView];
}

/// 高斯模糊遮罩
+ (void)setupBlurCover:(UIView *)cover {
    cover.backgroundColor = [UIColor clearColor];
    [self coverAddTap:cover];
    // 添加高斯模糊效果,添加毛玻璃效果
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = cover.bounds;
    
    [cover addSubview:effectview];
}

/// 中间弹窗动画
+ (void)animationAlert:(UIView *)view {
    if (_animation) {
        if (!_animation.delegate) {
            _animation.delegate = _cover;
        }
        [view.layer addAnimation:_animation forKey:nil];
    }else {
        CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.duration = 0.5;
        animation.delegate = _cover;
        
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        animation.values = values;
        
        [view.layer addAnimation:animation forKey:nil];
    }
}

+ (void)coverAddTap:(UIView *)cover {
    if (!_notclick) {
        [cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCover)]];
    }
}

+ (void)remove {
    [_cover removeFromSuperview];
    [_contentView removeFromSuperview];
    if (_isHideStatusBar) {
        _isHideStatusBar = NO;
        
        UIWindow *coverWindow = (UIWindow *)_fromView;
        coverWindow.hidden = YES;
        [coverWindow resignKeyWindow];
        coverWindow = nil;
    }
    
    _cover       = nil;
    _hasCover    = NO;
    _fromView    = nil;
    _contentView = nil;
    
    // 隐藏block放到最后，修复多个cover不能隐藏的bug
    !_hideBlock ? : _hideBlock();
}

+ (void)layoutSubViews {
    
    _contentView.gk_centerX = _fromView.gk_centerX;
    
    switch (_showStyle) {
        case GKCoverShowStyleTop: {
            _contentView.gk_y = _margin;
        }
            break;
        case GKCoverShowStyleCenter: {
            _contentView.center = _fromView.center;
        }
            break;
        case GKCoverShowStyleBottom: {
            _contentView.gk_y = _fromView.gk_height - _contentView.gk_height;
        }
            break;
        case GKCoverShowStyleLeft: {
            _contentView.gk_x = _margin;
        }
            break;
        case GKCoverShowStyleRight: {
            _contentView.gk_x = _fromView.gk_width - _contentView.gk_width;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (_animation) {
        _animation = nil;
    }
    !_showBlock ? : _showBlock();
}

@end
