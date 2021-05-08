//
//  GKCover.m
//  GKCoverDemo
//
//  Created by 高坤 on 16/8/24.
//  Copyright © 2016年 高坤. All rights reserved.
//  GKCover-一个简单的遮罩视图，让你的弹窗更easy，支持自定义遮罩弹窗
//  github:https://github.com/QuintGao/GKCover

#import "GKCover.h"

#pragma mark - 内部记录
static GKCover          *_cover;          // 遮罩
static UIView           *_fromView;       // 显示在此视图上
static UIView           *_contentView;    // 显示的视图
static BOOL             _animated;        // 是否需要动画
static showBlock        _showBlock;       // 显示时的回调block
static hideBlock        _hideBlock;       // 隐藏时的回调block
static BOOL             _notclick;        // 是否能点击的判断
static GKCoverStyle     _style;           // 遮罩类型
static GKCoverShowStyle _showStyle;       // 显示类型
static GKCoverAnimStyle _animStyle;       // 动画类型
static BOOL             _hasCover;        // 遮罩是否已经显示的判断值
static BOOL             _isHideStatusBar; // 遮罩是否遮盖状态栏
static CAAnimation      *_animation;      // 中间弹窗动画

// 分离动画类型
static GKCoverShowAnimStyle _showAnimStyle;
static GKCoverHideAnimStyle _hideAnimStyle;

static UIColor          *_bgColor;         // 背景色

@implementation GKCover

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 自动伸缩
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _animated = NO;
    }
    return self;
}

+ (instancetype)cover
{
    // cover一经初始化就存在
    _hasCover = YES;
    return [[self alloc] init];
}

#pragma makr - 自定义遮罩 - (可实现固定遮罩的效果)
/**
 *  半透明遮罩构造方法
 */
+ (instancetype)translucentCoverWithTarget:(id)target action:(SEL)action
{
    GKCover *cover = [self cover];
    cover.backgroundColor = _bgColor ? _bgColor : [UIColor blackColor];
    cover.alpha = kAlpha;
    [cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:action]];
    
    return cover;
}

/**
 *  全透明遮罩构造方法
 */
+ (instancetype)transparentCoverWithTarget:(id)target action:(SEL)action
{
    GKCover *cover = [self cover];
    cover.backgroundColor = [UIColor clearColor];
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.gk_size = CGSizeMake(KScreenW, KScreenH);
    bgView.userInteractionEnabled = YES;
    [bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:action]];
    [cover addSubview:bgView];
    
    return cover;
}

#pragma mark - 固定遮罩-屏幕底部弹窗

+ (void)translucentCoverFrom:(UIView *)fromView content:(UIView *)contentView animated:(BOOL)animated
{
    [self translucentCoverFrom:fromView content:contentView animated:animated notClick:NO];
}

+ (void)changeAlpha:(CGFloat)alpha
{
    _cover.alpha = alpha;
}

+ (void)transparentCoverFrom:(UIView *)fromView content:(UIView *)contentView animated:(BOOL)animated
{
    [self transparentCoverFrom:fromView content:contentView animated:animated notClick:NO];
}

#pragma mark - 固定遮罩-屏幕中间弹窗

+ (void)translucentWindowCenterCoverContent:(UIView *)contentView animated:(BOOL)animated
{
    [self translucentWindowCenterCoverContent:contentView animated:animated notClick:NO];
}

+ (void)transparentWindowCenterCoverContent:(UIView *)contentView animated:(BOOL)animated
{
    [self transparentWindowCenterCoverContent:contentView animated:animated notClick:NO];
}

#pragma mark - v1.0.5 新增功能
#pragma makr - 新增弹窗显示和隐藏时的block

/**
 *  半透明遮罩-底部弹窗，添加显示和隐藏的block
 */
+ (void)translucentCoverFrom:(UIView *)fromView content:(UIView *)contentView animated:(BOOL)animated showBlock:(showBlock)show hideBlock:(hideBlock)hide
{
    [self translucentCoverFrom:fromView content:contentView animated:animated notClick:NO showBlock:show hideBlock:hide];
}

/**
 *  全透明遮罩-底部弹窗，添加显示和隐藏的block
 */
+ (void)transparentCoverFrom:(UIView *)fromView content:(UIView *)contentView animated:(BOOL)animated showBlock:(showBlock)show hideBlock:(hideBlock)hide
{
    [self transparentCoverFrom:fromView content:contentView animated:animated notClick:NO showBlock:show hideBlock:hide];
}

/**
 *  半透明遮罩-中间弹窗，添加显示和隐藏的block
 */
+ (void)translucentWindowCenterCoverContent:(UIView *)contentView animated:(BOOL)animated showBlock:(showBlock)show hideBlock:(hideBlock)hide
{
    UIWindow *window = [self getKeyWindow];
    
    [self translucentCoverFrom:window content:contentView animated:animated notClick:NO showBlock:show hideBlock:hide];
}

/**
 *  全透明遮罩-中间弹窗，添加显示和隐藏的block
 */
+ (void)transparentWindowCenterCoverContent:(UIView *)contentView animated:(BOOL)animated showBlock:(showBlock)show hideBlock:(hideBlock)hide
{
    UIWindow *window = [self getKeyWindow];
    
    [self transparentCoverFrom:window content:contentView animated:animated notClick:NO showBlock:show hideBlock:hide];
}

#pragma mark - v2.0.2新增方法,使用更加方便
#pragma makr - 新增功能:增加点击遮罩时是否消失的判断,canClick是否可以点击,默认是YES

+ (void)translucentCoverFrom:(UIView *)fromView content:(UIView *)contentView animated:(BOOL)animated notClick:(BOOL)click
{
    [self translucentCoverFrom:fromView content:contentView animated:animated notClick:click showBlock:nil hideBlock:nil];
}

+ (void)transparentCoverFrom:(UIView *)fromView content:(UIView *)contentView animated:(BOOL)animated notClick:(BOOL)click
{
    [self transparentCoverFrom:fromView content:contentView animated:animated notClick:click showBlock:nil hideBlock:nil];
}

+ (void)translucentWindowCenterCoverContent:(UIView *)contentView animated:(BOOL)animated notClick:(BOOL)click
{
    UIWindow *window = [self getKeyWindow];

    [self translucentCoverFrom:window content:contentView animated:animated notClick:click showBlock:nil hideBlock:nil];
}

+ (void)transparentWindowCenterCoverContent:(UIView *)contentView animated:(BOOL)animated notClick:(BOOL)click
{
    UIWindow *window = [self getKeyWindow];
    
    [self transparentCoverFrom:window content:contentView animated:animated notClick:click showBlock:nil hideBlock:nil];
}

#pragma mark - v2.1.0
#pragma mark - 新增毛玻璃遮罩效果

+ (void)blurCoverFrom:(UIView *)fromView contentView:(UIView *)contentView animated:(BOOL)animated notClick:(BOOL)notClick style:(UIBlurEffectStyle)style
{
    [self blurCoverFrom:fromView contentView:contentView animated:animated notClick:notClick style:style showBlock:nil hideBlock:nil];
}

+ (void)blurCoverFrom:(UIView *)fromView contentView:(UIView *)contentView animated:(BOOL)animated style:(UIBlurEffectStyle)style showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock
{
    [self blurCoverFrom:fromView contentView:contentView animated:animated notClick:NO style:style showBlock:showBlock hideBlock:hideBlock];
}

+ (void)blurWindowCenterCoverContent:(UIView *)contentView animated:(BOOL)animated notClick:(BOOL)notClick style:(UIBlurEffectStyle)style
{
    UIWindow *window = [self getKeyWindow];
    
    [self blurCoverFrom:window contentView:contentView animated:animated notClick:notClick style:style showBlock:nil hideBlock:nil];
}

+ (void)blurWindowCenterCoverContent:(UIView *)contentView animated:(BOOL)animated style:(UIBlurEffectStyle)style showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock
{
    UIWindow *window = [self getKeyWindow];
    
    [self translucentCoverFrom:window content:contentView animated:animated notClick:NO showBlock:showBlock hideBlock:hideBlock];
}


#pragma mark - 私有方法
#pragma mark - 增加内部私有方法，v2.0.0新增
/**
 *  显示一个半透明遮罩
 *
 *  @param fromView          显示在此view上
 *  @param contentView       遮罩上面显示的内容view
 *  @param animated          是否有动画 ：默认是NO
 *  @param notClick          是否不能点击：默认是NO，即能点击
 *  @param showBlock         显示时的block
 *  @param hideBlock         隐藏时的block
 */
+ (void)translucentCoverFrom:(UIView *)fromView content:(UIView *)contentView animated:(BOOL)animated notClick:(BOOL)notClick showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock
{
    if ([self hasCover]) return;
    // 创建遮罩
    GKCover *cover = [self cover];
    // 设置大小和颜色
    cover.frame = fromView.bounds;
    cover.backgroundColor = _bgColor ? _bgColor : [UIColor blackColor];
    cover.alpha = kAlpha;
    // 添加遮罩
    [fromView addSubview:cover];
    _cover = cover;
    
    // 如果遮罩能点
    if (!notClick) {
        [cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    }
    
    // 赋值
    _fromView  = fromView;
    _contentView = contentView;
    _animated  = animated;
    _notclick  = notClick;
    _showBlock = showBlock;
    _hideBlock = hideBlock;
    
    // 显示内容view
    [self showContentView];
}

/**
 *  全透明遮罩
 *
 *  @param fromView    显示在此view上
 *  @param contentView 遮罩上面显示的内容view
 *  @param animated    是否有显示动画
 *  @param notClick    是否不能点击，默认是NO，即能点击
 *  @param showBlock   显示时的block
 *  @param hideBlock   隐藏时的block
 */
+ (void)transparentCoverFrom:(UIView *)fromView content:(UIView *)contentView animated:(BOOL)animated notClick:(BOOL)notClick showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock
{
    if ([self hasCover]) return;
    // 创建遮罩
    GKCover *cover = [self cover];
    cover.frame = fromView.bounds;
    cover.backgroundColor = [UIColor clearColor];
    [fromView addSubview:cover];
    _cover = cover;
    
    // 赋值
    _fromView  = fromView;
    _contentView = contentView;
    _animated  = animated;
    _notclick  = notClick;
    _showBlock = showBlock;
    _hideBlock = hideBlock;
    // 添加透明背景
    [cover addSubview:[self transparentBgView]];
    
    // 显示内容view
    [self showContentView];
}

+ (void)blurCoverFrom:(UIView *)fromView contentView:(UIView *)contentView animated:(BOOL)animated notClick:(BOOL)notClick style:(UIBlurEffectStyle)style showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock
{
    if ([self hasCover]) return;
    // 创建遮罩
    GKCover *cover = [self cover];
    cover.frame = fromView.bounds;
    cover.backgroundColor = [UIColor clearColor];
    [fromView addSubview:cover];
    _cover = cover;
    
    // 添加手势
    if (!notClick) {
        [cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    }
    
    // 添加高斯模糊效果,添加毛玻璃效果
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:style];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = cover.bounds;
    
    [cover addSubview:effectview];
    
    // 赋值
    _fromView    = fromView;
    _contentView = contentView;
    _animated    = animated;
    _notclick    = notClick;
    _showBlock   = showBlock;
    _hideBlock   = hideBlock;
    
    // 显示内容view
    [self showContentView];
}


/**
 *  透明背景
 */
+ (UIView *)transparentBgView
{
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.gk_size = _cover.gk_size;
    bgView.userInteractionEnabled = YES;
    if (!_notclick) {
        [bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    }
    return bgView;
}

+ (UIWindow *)getKeyWindow
{
    return [UIApplication sharedApplication].keyWindow;
}

+ (void)showContentView
{
    if ([_fromView isKindOfClass:[UIWindow class]]) {
        _contentView.center = _fromView.center;
        [_fromView addSubview:_contentView];
        if (_animated) {
            [self animationAlert:_contentView];
        }
    }else{
        [_fromView addSubview:_contentView];
        
        [self show];
    }
}

/**
 *  中间弹窗动画
 */
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

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (_animation) {
        _animation = nil;
    }
    !_showBlock ? : _showBlock();
}

/**
 *  显示
 */
+ (void)show
{
    if (_animated) {
        _contentView.gk_y = KScreenH;
        [UIView animateWithDuration:kAnimDuration animations:^{
            _contentView.gk_y = KScreenH - _contentView.gk_height;
        }completion:^(BOOL finished) {
            !_showBlock ? : _showBlock();
        }];
    }else{
        !_showBlock ? : _showBlock();
        _contentView.gk_y = KScreenH - _contentView.gk_height;
    }
}
/**
 *  隐藏
 */
+ (void)hide{
    _hasCover = NO;
    
    if (_animated && ![_fromView isKindOfClass:[UIWindow class]]) {
        
        [UIView animateWithDuration:kAnimDuration animations:^{
            _contentView.gk_y = KScreenH;
        }completion:^(BOOL finished) {
            [_cover removeFromSuperview];
            [_contentView removeFromSuperview];
            !_hideBlock ? : _hideBlock();
        }];
    }else{
        [_cover removeFromSuperview];
        [_contentView removeFromSuperview];
        !_hideBlock ? : _hideBlock();
    }
}

#pragma mark - v2.2.0
#pragma mark - 全新定义构造方法，根据不同类型，显示不同遮罩

// 常见遮罩
+ (void)topCover:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style notClick:(BOOL)notClick animated:(BOOL)animated
{
    GKCoverAnimStyle animStyle;
    if (animated) {
        animStyle = GKCoverAnimStyleTop;
    }else{
        animStyle = GKCoverAnimStyleNone;
    }
    
    [self coverFrom:fromView contentView:contentView style:style showStyle:GKCoverShowStyleTop animStyle:animStyle notClick:notClick];
}

+ (void)bottomCoverFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style notClick:(BOOL)notClick animated:(BOOL)animated
{
    GKCoverAnimStyle animStyle;
    if (animated) {
        animStyle = GKCoverAnimStyleBottom;
    }else{
        animStyle = GKCoverAnimStyleNone;
    }
    
    [self coverFrom:fromView contentView:contentView style:style showStyle:GKCoverShowStyleBottom animStyle:animStyle notClick:notClick];
}

+ (void)centerCover:(UIView *)contentView style:(GKCoverStyle)style notClick:(BOOL)notClick animated:(BOOL)animated
{
    GKCoverAnimStyle animStyle;
    if (animated) {
        animStyle = GKCoverAnimStyleCenter;
    }else{
        animStyle = GKCoverAnimStyleNone;
    }
    
    [self coverFrom:[self getKeyWindow] contentView:contentView style:style showStyle:GKCoverShowStyleCenter animStyle:animStyle notClick:notClick];
}

/**
 显示遮罩
 
 @param fromView    显示的视图上
 @param contentView 显示的视图
 @param style       遮罩类型
 @param showStyle   显示类型
 @param animStyle   动画类型
 @param notClick    是否不可点击
 */
+ (void)coverFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle animStyle:(GKCoverAnimStyle)animStyle notClick:(BOOL)notClick
{
    [self coverFrom:fromView contentView:contentView style:style showStyle:showStyle animStyle:animStyle notClick:notClick showBlock:nil hideBlock:nil];
}

+ (void)coverFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle animStyle:(GKCoverAnimStyle)animStyle notClick:(BOOL)notClick showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock
{
    if ([self hasCover]) return;
    
    _style       = style;
    _showStyle   = showStyle;
    _animStyle   = animStyle;
    _fromView    = fromView;
    _contentView = contentView;
    _notclick    = notClick;
    _showBlock   = showBlock;
    _hideBlock   = hideBlock;
    
    // 创建遮罩
    GKCover *cover = [self cover];
    // 设置大小和颜色
    cover.frame = fromView.bounds;
    // 添加遮罩
    [fromView addSubview:cover];
    _cover = cover;
    
    if (style == GKCoverStyleTranslucent) { // 半透明
        cover.backgroundColor = _bgColor ? _bgColor : [UIColor blackColor];
        cover.alpha = kAlpha;
        [self addTap:cover];
    }else if (style == GKCoverStyleTransparent){  // 全透明
        cover.backgroundColor = [UIColor clearColor];
        [cover addSubview:[self gk_transparentBgView]];
    }else{ // 毛玻璃，高斯模糊
        cover.backgroundColor = [UIColor clearColor];
        [self addTap:cover];
        // 添加高斯模糊效果,添加毛玻璃效果
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectview.frame = cover.bounds;
        
        [cover addSubview:effectview];
    }
    
    [self showView];
}

+ (void)showAlertViewFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style animation:(CAAnimation *)animation notClick:(BOOL)notClick {
    [self showAlertViewFrom:fromView contentView:contentView style:style animation:animation notClick:notClick showBlock:nil hideBlock:nil];
}

+ (void)showAlertViewFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style animation:(CAAnimation *)animation notClick:(BOOL)notClick showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock {
    _animation = animation;
    [self coverFrom:fromView contentView:contentView style:style showStyle:GKCoverShowStyleCenter showAnimStyle:GKCoverShowAnimStyleCenter hideAnimStyle:GKCoverHideAnimStyleCenter notClick:notClick showBlock:showBlock hideBlock:hideBlock];
}

/**
 *  透明图片
 */
+ (UIView *)gk_transparentBgView
{
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.gk_size = _cover.gk_size;
    bgView.userInteractionEnabled = YES;
    [self addTap:bgView];
    return bgView;
}

+ (UIView *)gk_coverTransparentBgView
{
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.gk_size = _cover.gk_size;
    bgView.userInteractionEnabled = YES;
    [self coverAddTap:bgView];
    return bgView;
}

+ (void)showView
{
    [_fromView addSubview:_contentView];
    
    if (_showStyle == GKCoverShowStyleTop) {
        _contentView.gk_centerX = _fromView.gk_centerX;
        if (_animStyle == GKCoverAnimStyleTop) {
            _contentView.gk_y = -_contentView.gk_height;
            [UIView animateWithDuration:kAnimDuration animations:^{
                _contentView.gk_y = 0;
            }completion:^(BOOL finished) {
                !_showBlock ? : _showBlock();
            }];
        }else{
            !_showBlock ? : _showBlock();
            _contentView.gk_y = 0;
        }
    }else if (_showStyle == GKCoverShowStyleCenter){
        _contentView.gk_centerX = _fromView.gk_centerX;
        if (_animStyle == GKCoverAnimStyleTop) { // 上进下出
            _contentView.gk_y = -_contentView.gk_height;
            [UIView animateWithDuration:kAnimDuration animations:^{
                _contentView.center = _fromView.center;
            }completion:^(BOOL finished) {
                !_showBlock ? : _showBlock();
            }];
        }else if (_animStyle == GKCoverAnimStyleCenter) { // 中间动画
            _contentView.center = _fromView.center;
            [self animationAlert:_contentView];
        }else if (_animStyle == GKCoverAnimStyleBottom) { // 下进上出
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
    }else if (_showStyle == GKCoverShowStyleBottom){
        _contentView.gk_centerX = _fromView.gk_centerX;
        if (_animStyle == GKCoverAnimStyleBottom) {
            _contentView.gk_y = _fromView.gk_height;
            [UIView animateWithDuration:kAnimDuration animations:^{
                _contentView.gk_y = _fromView.gk_height - _contentView.gk_height;
            }completion:^(BOOL finished) {
                !_showBlock ? : _showBlock();
            }];
        }else{
            !_showBlock ? : _showBlock();
            _contentView.gk_y = _fromView.gk_height - _contentView.gk_height;
        }
    }else if (_showStyle == GKCoverShowStyleLeft) {
        _contentView.gk_centerY = _fromView.gk_height * 0.5f;
        if (_showAnimStyle == GKCoverShowStyleLeft) {
            _contentView.gk_x = -_contentView.gk_width;
            [UIView animateWithDuration:kAnimDuration animations:^{
                _contentView.gk_x = 0;
            }completion:^(BOOL finished) {
                !_showBlock ? : _showBlock();
            }];
        }else {
            !_showBlock ? : _showBlock();
            _contentView.gk_x = 0;
        }
    }else if (_showStyle == GKCoverShowStyleRight) {
        _contentView.gk_centerY = _fromView.gk_height * 0.5f;
        if (_showAnimStyle == GKCoverShowAnimStyleRight) {
            _contentView.gk_x = _fromView.gk_width;
            [UIView animateWithDuration:kAnimDuration animations:^{
                _contentView.gk_x = _fromView.gk_width - _contentView.gk_width;
            }completion:^(BOOL finished) {
                !_showBlock ? : _showBlock();
            }];
        }else {
            !_showBlock ? : _showBlock();
            _contentView.gk_x = _fromView.gk_width - _contentView.gk_width;
        }
    }
}

+ (void)hideView
{
    // 这里为了防止动画未完成导致的不能及时判断cover是否存在，实际上cover再这里并没有销毁
    _hasCover = NO;
    
    if (_showStyle == GKCoverShowStyleTop) {
        if (_animStyle == GKCoverAnimStyleTop) { // 上进上出
            [UIView animateWithDuration:kAnimDuration animations:^{
                _contentView.gk_y = -_contentView.gk_height;
            }completion:^(BOOL finished) {
                [self remove];
            }];
        }else{
            _contentView.gk_y = -_contentView.gk_height;
            [self remove];
        }
    }else if (_showStyle == GKCoverShowStyleCenter){
        if (_animStyle == GKCoverAnimStyleTop) { // 上进下出
            [UIView animateWithDuration:kAnimDuration animations:^{
                _contentView.gk_y = _fromView.gk_height;
            }completion:^(BOOL finished) {
                [self remove];
            }];
        }else if (_animStyle == GKCoverAnimStyleCenter) { // 中间动画
            [self remove];
        }else if (_animStyle == GKCoverAnimStyleBottom) { // 下进上出
            [UIView animateWithDuration:kAnimDuration animations:^{
                _contentView.gk_y = -_contentView.gk_height;
            }completion:^(BOOL finished) {
                [self remove];
            }];
        }else{ // 无动画
            _contentView.center = _fromView.center;
            [self remove];
        }
    }else if (_showStyle == GKCoverShowStyleBottom){
        if (_animStyle == GKCoverAnimStyleBottom) {  // 下进下出
            [UIView animateWithDuration:kAnimDuration animations:^{
                _contentView.gk_y = _fromView.gk_height;
            }completion:^(BOOL finished) {
                [self remove];
            }];
        }else{
            _contentView.gk_y = _fromView.gk_height;
            [self remove];
        }
    }else if (_showStyle == GKCoverShowStyleLeft) { // 左进左出
        if (_hideAnimStyle == GKCoverAnimStyleLeft) {
            [UIView animateWithDuration:kAnimDuration animations:^{
                _contentView.gk_x = -_contentView.gk_width;
            }completion:^(BOOL finished) {
                [self remove];
            }];
        }else{
            _contentView.gk_x = -_contentView.gk_width;
            [self remove];
        }
    }else if (_showStyle == GKCoverShowStyleRight) { // 右进右出
        if (_hideAnimStyle == GKCoverHideAnimStyleRight) {
            [UIView animateWithDuration:kAnimDuration animations:^{
                _contentView.gk_x = _fromView.gk_width;
            }completion:^(BOOL finished) {
                [self remove];
            }];
        }else{
            _contentView.gk_x = _fromView.gk_width;
            [self remove];
        }
    }
}

#pragma mark - v2.3.1
#pragma mark - 增加判断是否已经有cover的方法

+ (BOOL)hasCover
{
    return _hasCover;
}

#pragma mark - v2.4.0
#pragma mark - 分离弹出和隐藏时的动画
+ (void)coverFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle notClick:(BOOL)notClick
{
    [self coverFrom:fromView contentView:contentView style:style showStyle:showStyle showAnimStyle:showAnimStyle hideAnimStyle:hideAnimStyle notClick:notClick showBlock:nil hideBlock:nil];
}

+ (void)coverFrom:(UIView *)fromView contentView:(UIView *)contentView style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle notClick:(BOOL)notClick showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock
{
    if ([self hasCover]) return;
    
    _style         = style;
    _showStyle     = showStyle;
    _showAnimStyle = showAnimStyle;
    _hideAnimStyle = hideAnimStyle;
    _fromView      = fromView;
    _contentView   = contentView;
    _notclick      = notClick;
    _showBlock     = showBlock;
    _hideBlock     = hideBlock;
    
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

+ (void)coverHideStatusBarWithContentView:(UIView *)contentView style:(GKCoverStyle)style showStyle:(GKCoverShowStyle)showStyle showAnimStyle:(GKCoverShowAnimStyle)showAnimStyle hideAnimStyle:(GKCoverHideAnimStyle)hideAnimStyle notClick:(BOOL)notClick showBlock:(showBlock)showBlock hideBlock:(hideBlock)hideBlock {
    
    if ([self hasCover]) return;
    
    _isHideStatusBar = YES;
    
    _style         = style;
    _showStyle     = showStyle;
    _showAnimStyle = showAnimStyle;
    _hideAnimStyle = hideAnimStyle;
    _contentView   = contentView;
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

+ (void)showCover {
    [_fromView addSubview:_contentView];
    
    switch (_showStyle) {
        case GKCoverShowStyleTop: {  // 显示在顶部
            _contentView.gk_centerX = _fromView.gk_centerX;
            if (_showAnimStyle == GKCoverShowAnimStyleTop) {
                _contentView.gk_y = -_contentView.gk_height;
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_y = 0;
                }completion:^(BOOL finished) {
                    !_showBlock ? : _showBlock();
                }];
            }else{
                !_showBlock ? : _showBlock();
                _contentView.gk_y = 0;
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
            _contentView.gk_centerX = _fromView.gk_centerX;
            if (_showAnimStyle == GKCoverShowAnimStyleBottom) {
                _contentView.gk_y = _fromView.gk_height;
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_y = _fromView.gk_height - _contentView.gk_height;
                }completion:^(BOOL finished) {
                    !_showBlock ? : _showBlock();
                }];
            }else{
                !_showBlock ? : _showBlock();
                _contentView.gk_y = _fromView.gk_height - _contentView.gk_height;
            }
        }
            break;
        case GKCoverShowStyleLeft: { // 显示在左侧
            _contentView.gk_centerY = _fromView.gk_height * 0.5f;
            if (_showAnimStyle == GKCoverShowAnimStyleLeft) {
                _contentView.gk_x = -_contentView.gk_width;
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_x = 0;
                }completion:^(BOOL finished) {
                    !_showBlock ? : _showBlock();
                }];
            }else {
                !_showBlock ? : _showBlock();
                _contentView.gk_x = 0;
            }
        }
            break;
        case GKCoverShowStyleRight: { // 显示在右侧
            _contentView.gk_centerY = _fromView.gk_height * 0.5f;
            if (_showAnimStyle == GKCoverShowAnimStyleRight) {
                _contentView.gk_x = _fromView.gk_width;
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_x = _fromView.gk_width - _contentView.gk_width;
                }completion:^(BOOL finished) {
                    !_showBlock ? : _showBlock();
                }];
            }else {
                !_showBlock ? : _showBlock();
                _contentView.gk_x = _fromView.gk_width - _contentView.gk_width;
            }
        }
            break;
            
        default:
            break;
    }
}

+ (void)hideCover {
    if (!_cover) return;
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
                    _contentView.gk_y = _fromView.gk_height;
                }completion:^(BOOL finished) {
                    [self remove];
                }];
            }else{ // 无动画
                _contentView.center = _fromView.center;
                [self remove];
            }
        }
            break;
        case GKCoverShowStyleBottom: { // 显示在底部
            if (_hideAnimStyle == GKCoverHideAnimStyleBottom) {
                [UIView animateWithDuration:kAnimDuration animations:^{
                    _contentView.gk_y = _fromView.gk_height;
                }completion:^(BOOL finished) {
                    [self remove];
                }];
            }else{
                _contentView.gk_y = _fromView.gk_height;
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
                    _contentView.gk_x = _fromView.gk_width;
                }completion:^(BOOL finished) {
                    [self remove];
                }];
            }else{
                _contentView.gk_x = _fromView.gk_width;
                [self remove];
            }
        }
            break;
            
        default:
            break;
    }
}

+ (void)hideCoverWithoutAnimation {
    if (!_cover) return;
    if (!_hasCover) return;
    // 这里为了防止动画未完成导致的不能及时判断cover是否存在，实际上cover再这里并没有销毁
    _hasCover = NO;
    [self remove];
}

#pragma mark - Private Method

/**
 半透明遮罩
 */
+ (void)setupTranslucentCover:(UIView *)cover
{
    cover.backgroundColor = _bgColor ? _bgColor : [UIColor blackColor];
    cover.alpha = kAlpha;
    [self coverAddTap:cover];
}

/**
 全透明遮罩
 */
+ (void)setupTransparentCover:(UIView *)cover
{
    cover.backgroundColor = [UIColor clearColor];
    [cover addSubview:[self gk_coverTransparentBgView]];
}

/**
 高斯模糊遮罩
 */
+ (void)setupBlurCover:(UIView *)cover
{
    cover.backgroundColor = [UIColor clearColor];
    [self coverAddTap:cover];
    // 添加高斯模糊效果,添加毛玻璃效果
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = cover.bounds;
    
    [cover addSubview:effectview];
}

+ (void)addTap:(UIView *)view
{
    if (!_notclick) {
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)]];
    }
}

+ (void)coverAddTap:(UIView *)cover
{
    if (!_notclick) {
        [cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCover)]];
    }
}

+ (void)remove
{
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
    _fromView    = nil;
    _contentView = nil;
    
    // 隐藏block放到最后，修复多个cover不能隐藏的bug
    !_hideBlock ? : _hideBlock();
}

+ (void)layoutSubViews {
    
    _contentView.gk_centerX = _fromView.gk_centerX;
    
    switch (_showStyle) {
        case GKCoverShowStyleTop: {
            _contentView.gk_y = 0;
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
            _contentView.gk_x = 0;
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

#pragma mark - 2.5.2
+ (void)hideCoverWithHideBlock:(hideBlock)hideBlock {
    _hideBlock = hideBlock;
    
    [GKCover hideCover];
}

+ (void)changeCoverBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    
    _cover.backgroundColor = bgColor;
}

@end
