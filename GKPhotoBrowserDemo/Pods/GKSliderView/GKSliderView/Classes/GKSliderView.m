//
//  GKSliderView.m
//  GKSliderView
//
//  Created by QuintGao on 2017/9/6.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKSliderView.h"

/** 滑块的大小 */
#define kSliderBtnWH  19.0
/** 间距 */
#define kProgressMargin 2.0
/** 进度的宽度 */
#define kProgressW    self.frame.size.width - kProgressMargin * 2
/** 进度的高度 */
#define kProgressH    3.0

#define kLineLoadingDuration 0.75
#define kLineLoadingColor    [UIColor whiteColor]

@interface GKSliderButton()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation GKSliderButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicatorView.hidesWhenStopped       = NO;
        self.indicatorView.userInteractionEnabled = NO;
        self.indicatorView.frame     = CGRectMake(0, 0, 20, 20);
        self.indicatorView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        self.indicatorView.hidden = YES;
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.indicatorView.center = CGPointMake(self.gk_width * 0.5, self.gk_height * 0.5);
    self.indicatorView.transform = CGAffineTransformMakeScale(0.6, 0.6);
}

- (void)showActivityAnim {
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
}

- (void)hideActivityAnim {
    self.indicatorView.hidden = YES;
    [self.indicatorView stopAnimating];
}

- (CGRect)enlargedRect {
    return CGRectMake(self.bounds.origin.x - self.enlargeEdge.left,
                      self.bounds.origin.y - self.enlargeEdge.top,
                      self.bounds.size.width + self.enlargeEdge.left + self.enlargeEdge.right,
                      self.bounds.size.height + self.enlargeEdge.top + self.enlargeEdge.bottom);
}

// 重写此方法将按钮的点击范围扩大
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rect = [self enlargedRect];
    if (CGRectEqualToRect(rect, self.bounds)) {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point);
}

@end

@implementation GKLineLoadingView {
    CGFloat _lineHeight;
}

+ (void)showLoadingInView:(UIView *)view lineHeight:(CGFloat)lineHeight {
    GKLineLoadingView *loadingView = [[GKLineLoadingView alloc] initWithFrame:view.frame lineHeight:lineHeight];
    [view addSubview:loadingView];
    [loadingView startLoading];
}

+ (void)hideLoadingInView:(UIView *)view {
    NSEnumerator *subviewsEnum = view.subviews.reverseObjectEnumerator;
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:GKLineLoadingView.class]) {
            GKLineLoadingView *loadingView = (GKLineLoadingView *)subview;
            [loadingView stopLoading];
            [loadingView removeFromSuperview];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame lineHeight:(CGFloat)lineHeight {
    if (self = [super initWithFrame:frame]) {
        _lineHeight = lineHeight;
        self.backgroundColor = kLineLoadingColor;
        self.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
        self.bounds = CGRectMake(0, 0, 1.0f, lineHeight);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.superview.frame;
    self.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
    self.bounds = CGRectMake(0, 0, 1.0f, _lineHeight);
    
    CAAnimationGroup *animationGroup = [self.layer animationForKey:@"lineLoading"];
    CABasicAnimation *scaleAnimation = (CABasicAnimation *)animationGroup.animations.firstObject;
    if (!scaleAnimation) return;
    if ([scaleAnimation.toValue isEqual: @(1.0 * frame.size.width)]) return;
    scaleAnimation.toValue = @(1.0 * frame.size.width);
}

- (void)startLoading {
    [self stopLoading];
    
    self.hidden = NO;
    // 创建动画组
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = kLineLoadingDuration;
    animationGroup.beginTime = CACurrentMediaTime();
    animationGroup.repeatCount = MAXFLOAT;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // x轴缩放动画（transform.scale是以view的中心的为中心开始缩放的）
    CABasicAnimation *scaleAnimation = [CABasicAnimation animation];
    scaleAnimation.keyPath = @"transform.scale.x";
    scaleAnimation.fromValue = @(1.0f);
    scaleAnimation.toValue = @(1.0f * self.superview.frame.size.width);
    
    // 透明度渐变动画
    CABasicAnimation *alphaAnimation = [CABasicAnimation animation];
    alphaAnimation.keyPath = @"opacity";
    alphaAnimation.fromValue = @(1.0f);
    alphaAnimation.toValue = @(0.5f);
    
    animationGroup.animations = @[scaleAnimation, alphaAnimation];
    // 添加动画
    [self.layer addAnimation:animationGroup forKey:@"lineLoading"];
}

- (void)stopLoading {
    [self.layer removeAnimationForKey:@"lineLoading"];
    self.hidden = YES;
}

@end

@interface GKSliderView()

/** 进度背景 */
@property (nonatomic, strong) UIImageView *bgProgressView;
/** 缓存进度 */
@property (nonatomic, strong) UIImageView *bufferProgressView;
/** 滑动进度 */
@property (nonatomic, strong) UIImageView *sliderProgressView;

/** 滑块 */
@property (nonatomic, strong) GKSliderButton *sliderBtn;

/// 预览视图
@property (nonatomic, strong) UIView *preview;

/// 预览视图与滑块的间距
@property (nonatomic, assign) CGFloat previewToSliderMargin;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, assign) float touchValue;

@property (nonatomic, assign) BOOL isDragging;

@end

@implementation GKSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self addSubViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self addSubViews];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        if ([self.previewDelegate respondsToSelector:@selector(sliderViewSetupPreview:)]) {
            self.preview = [self.previewDelegate sliderViewSetupPreview:self];
            if (self.preview) {
                self.preview.hidden = YES;
                [newSuperview addSubview:self.preview];
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:GKLineLoadingView.class]) {
            CGPoint center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
            if (!CGPointEqualToPoint(obj.center, center)) {
                obj.frame = self.bounds;
            }
        }
    }];
    
    if (self.sliderBtn.hidden) {
        self.bgProgressView.gk_width   = self.gk_width;
    }else {
        self.bgProgressView.gk_width   = self.gk_width - kProgressMargin * 2;
    }
    
    self.bgProgressView.gk_centerY     = self.gk_height * 0.5;
    self.bufferProgressView.gk_centerY = self.gk_height * 0.5;
    self.sliderProgressView.gk_centerY = self.gk_height * 0.5;
    self.sliderBtn.gk_centerY          = self.gk_height * 0.5;
    
    self.value = self.value;
    self.bufferValue = self.bufferValue;
    
    CGFloat margin = 10;
    if ([self.previewDelegate respondsToSelector:@selector(sliderViewPreviewMargin:)]) {
        margin = [self.previewDelegate sliderViewPreviewMargin:self];
    }
    
    CGPoint point = [self convertPoint:self.sliderBtn.center toView:self.superview];
    if (!self.isPreviewChangePosition) {
        point.x = self.superview.frame.size.width * 0.5;
    }
    
    if (self.preview) {
        self.preview.gk_centerX = point.x;
        self.preview.gk_centerY = point.y - self.preview.gk_height - margin;
    }
}

/**
 添加子视图
 */
- (void)addSubViews {
    self.isSliderAllowTapped      = YES;
    self.isSliderBlockAllowTapped = YES;
    self.isPreviewChangePosition  = YES;
    self.sliderBlockEnlargeEdge   = UIEdgeInsetsMake(10, 10, 10, 10);
    self.sliderBtn.enlargeEdge = self.sliderBlockEnlargeEdge;
    
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.bgProgressView];
    [self addSubview:self.bufferProgressView];
    [self addSubview:self.sliderProgressView];
    [self addSubview:self.sliderBtn];
    
    // 初始化frame
    self.bgProgressView.frame     = CGRectMake(kProgressMargin, 0, 0, kProgressH);
    self.bufferProgressView.frame = self.bgProgressView.frame;
    self.sliderProgressView.frame = self.bgProgressView.frame;
    self.sliderBtn.frame          = CGRectMake(0, 0, kSliderBtnWH, kSliderBtnWH);
}

#pragma mark - Setter
- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    
    self.bgProgressView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    
    self.sliderProgressView.backgroundColor = minimumTrackTintColor;
}

- (void)setBufferTrackTintColor:(UIColor *)bufferTrackTintColor {
    _bufferTrackTintColor = bufferTrackTintColor;
    
    self.bufferProgressView.backgroundColor = bufferTrackTintColor;
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage {
    _maximumTrackImage = maximumTrackImage;
    
    self.bgProgressView.image = maximumTrackImage;
    self.maximumTrackTintColor = [UIColor clearColor];
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage {
    _minimumTrackImage = minimumTrackImage;
    
    self.sliderProgressView.image = minimumTrackImage;
    
    self.minimumTrackTintColor = [UIColor clearColor];
}

- (void)setBufferTrackImage:(UIImage *)bufferTrackImage {
    _bufferTrackImage = bufferTrackImage;
    
    self.bufferProgressView.image = bufferTrackImage;
    
    self.bufferTrackTintColor = [UIColor clearColor];
}

- (void)setValue:(float)value {
    _value = value;

    CGFloat finishValue  = (self.bgProgressView.gk_width - 2 * self.ignoreMargin) * value + self.ignoreMargin;
    self.sliderProgressView.gk_width = finishValue;
    
    self.sliderBtn.gk_left = (self.gk_width - 2 * self.ignoreMargin - self.sliderBtn.gk_width) * value + self.ignoreMargin;
    
    [self setupSliderRoundCorner];
}

- (void)setBufferValue:(float)bufferValue {
    _bufferValue = bufferValue;
    
    CGFloat finishValue = (self.bgProgressView.gk_width - 2 * self.ignoreMargin) * bufferValue + self.ignoreMargin;
    self.bufferProgressView.gk_width = finishValue;
    
    [self setupBufferRoundCorner];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setBackgroundImage:image forState:state];
    
    [self.sliderBtn sizeToFit];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setImage:image forState:state];
    
    [self.sliderBtn sizeToFit];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    
    self.bgProgressView.layer.cornerRadius = cornerRadius;
    self.bgProgressView.layer.masksToBounds = YES;
    
    self.bufferProgressView.layer.cornerRadius = cornerRadius;
    self.bufferProgressView.layer.masksToBounds = YES;
    
    self.sliderProgressView.layer.cornerRadius = cornerRadius;
    self.sliderProgressView.layer.masksToBounds = YES;
}

- (void)setBgCornerRadius:(CGFloat)bgCornerRadius {
    _bgCornerRadius = bgCornerRadius;
    
    self.bgProgressView.layer.cornerRadius = bgCornerRadius;
    self.bgProgressView.layer.masksToBounds = YES;
    
    [self setupBufferRoundCorner];
    [self setupSliderRoundCorner];
}

- (void)showLoading {
    [self.sliderBtn showActivityAnim];
}

- (void)hideLoading {
    [self.sliderBtn hideActivityAnim];
}

- (void)showLineLoading {
    self.bgProgressView.hidden = YES;
    self.bufferProgressView.hidden = YES;
    self.sliderProgressView.hidden = YES;
    self.sliderBtn.hidden = YES;
    
    CGFloat lineHeight = self.lineHeight > 0 ? self.lineHeight : self.bgProgressView.gk_height;
    
    [GKLineLoadingView showLoadingInView:self lineHeight:lineHeight];
}

- (void)hideLineLoading {
    self.bgProgressView.hidden = NO;
    self.bufferProgressView.hidden = NO;
    self.sliderProgressView.hidden = NO;
    self.sliderBtn.hidden = NO;
    [GKLineLoadingView hideLoadingInView:self];
}

- (void)setIsSliderAllowTapped:(BOOL)isSliderAllowTapped {
    _isSliderAllowTapped = isSliderAllowTapped;
    
    if (isSliderAllowTapped) {
        [self addGestureRecognizer:self.tapGesture];
    }else {
        if ([self.gestureRecognizers containsObject:self.tapGesture]) {
            [self removeGestureRecognizer:self.tapGesture];
        }
    }
}

- (void)setIsSliderAllowDragged:(BOOL)isSliderAllowDragged {
    _isSliderAllowDragged = isSliderAllowDragged;
    
    if (isSliderAllowDragged) {
        self.sliderBtn.userInteractionEnabled = NO;
        [self addGestureRecognizer:self.panGesture];
    }else {
        if (self.isSliderBlockAllowTapped) {
            self.sliderBtn.userInteractionEnabled = YES;
        }
        if ([self.gestureRecognizers containsObject:self.panGesture]) {
            [self removeGestureRecognizer:self.panGesture];
        }
    }
}

- (void)setSliderHeight:(CGFloat)sliderHeight {
    _sliderHeight = sliderHeight;
    
    self.bgProgressView.gk_height     = sliderHeight;
    self.bufferProgressView.gk_height = sliderHeight;
    self.sliderProgressView.gk_height = sliderHeight;
}

- (void)setIsHideSliderBlock:(BOOL)isHideSliderBlock {
    _isHideSliderBlock = isHideSliderBlock;
    
    self.sliderBtn.hidden = isHideSliderBlock;
}

- (void)setIsSliderBlockAllowTapped:(BOOL)isSliderBlockAllowTapped {
    _isSliderBlockAllowTapped = isSliderBlockAllowTapped;
    
    if (self.isSliderAllowDragged) {
        self.sliderBtn.userInteractionEnabled = NO;
    }else {
        self.sliderBtn.userInteractionEnabled = isSliderBlockAllowTapped;
    }
}

- (void)setSliderBlockEnlargeEdge:(UIEdgeInsets)sliderBlockEnlargeEdge {
    _sliderBlockEnlargeEdge = sliderBlockEnlargeEdge;
    
    self.sliderBtn.enlargeEdge = sliderBlockEnlargeEdge;
}

- (void)setupBufferRoundCorner {
    CGFloat cornerRadius = self->_bgCornerRadius;
    if (cornerRadius == 0) return;
    
    float value = self->_bufferValue;
    
    UIRectCorner corner = value == 1 ? UIRectCornerAllCorners : (UIRectCornerTopLeft | UIRectCornerBottomLeft);
    CGRect frame = self.bgProgressView.bounds;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:corner cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    self.bufferProgressView.layer.mask = maskLayer;
}

- (void)setupSliderRoundCorner {
    CGFloat cornerRadius = self->_bgCornerRadius;
    if (cornerRadius == 0) return;
    
    float value = self->_value;
    
    UIRectCorner corner = value == 1 ? UIRectCornerAllCorners : (UIRectCornerTopLeft | UIRectCornerBottomLeft);
    CGRect frame = self.bgProgressView.bounds;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:corner cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    self.sliderProgressView.layer.mask = maskLayer;
}

- (void)setPreviewDelegate:(id<GKSliderViewPreviewDelegate>)previewDelegate {
    _previewDelegate = previewDelegate;
    
    if (!self.superview) return;
    if ([previewDelegate respondsToSelector:@selector(sliderViewSetupPreview:)]) {
        self.preview = [previewDelegate sliderViewSetupPreview:self];
        if (self.preview) {
            self.preview.hidden = YES;
            [self.superview addSubview:self.preview];
        }
    }
}

#pragma mark - User Action
- (void)sliderBtnTouchBegin:(UIButton *)btn event:(UIEvent *)event {
    self.touchPoint = [event.allTouches.anyObject locationInView:self];
    [self sliderTouchBegin:btn];
}

- (void)sliderBtnTouchEnded:(UIButton *)btn {
    [self sliderTouchEnded:btn];
}

- (void)sliderBtnDragMoving:(UIButton *)btn event:(UIEvent *)event {
    // 点击的位置
    CGPoint point = [event.allTouches.anyObject locationInView:self];
    // 修复真机测试时按下就触发移动方法，导致的bug
    if (CGPointEqualToPoint(self.touchPoint, point)) return;
    
    // 获取进度值 由于btn是从 0-(self.width - btn.width)
    float value = (point.x - self.ignoreMargin - btn.gk_width * 0.5) / (self.gk_width - 2 * self.ignoreMargin - btn.gk_width);
    [self sliderTouchMovingWithValue:value];
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    if (CGRectContainsPoint(self.sliderBtn.frame, point)) return;
    
    // 获取进度
    float value = (point.x - self.ignoreMargin - self.bgProgressView.gk_left) * 1.0 / (self.bgProgressView.gk_width - 2 * self.ignoreMargin);
    value = value >= 1.0 ? 1.0 : value <= 0 ? 0 : value;
    
    [self setValue:value];
    
    if ([self.delegate respondsToSelector:@selector(sliderView:tapped:)]) {
        [self.delegate sliderView:self tapped:value];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint location = [pan locationInView:pan.view];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.touchPoint = location;
            self.touchValue = self.value;
            [self sliderTouchBegin:self.sliderBtn];
            break;
        case UIGestureRecognizerStateChanged: {
            // 差值
            CGFloat diff = (location.x - self.touchPoint.x) / pan.view.frame.size.width;
            CGFloat value = self.touchValue + diff;
            [self sliderTouchMovingWithValue:value];
        }
            break;
        case UIGestureRecognizerStateEnded:
            [self sliderTouchEnded:self.sliderBtn];
            break;
        default:
            break;
    }
}

- (void)sliderTouchBegin:(UIButton *)btn {
    self.isDragging = YES;
    
    if ([self.delegate respondsToSelector:@selector(sliderView:touchBegan:)]) {
        [self.delegate sliderView:self touchBegan:self.value];
    }
    
    if (self.preview) {
        self.preview.hidden = NO;
    }
}

- (void)sliderTouchMovingWithValue:(float)value {
    // value的值需在0-1之间
    value = MIN(MAX(0, value), 1);
    
    [self setValue:value];
    
    if ([self.delegate respondsToSelector:@selector(sliderView:valueChanged:)]) {
        [self.delegate sliderView:self valueChanged:value];
    }
    
    if ([self.previewDelegate respondsToSelector:@selector(sliderView:preview:valueChanged:)]) {
        [self.previewDelegate sliderView:self preview:self.preview valueChanged:value];
    }
}

- (void)sliderTouchEnded:(UIButton *)btn {
    self.isDragging = NO;
    
    if ([self.delegate respondsToSelector:@selector(sliderView:touchEnded:)]) {
        [self.delegate sliderView:self touchEnded:self.value];
    }
    
    if (self.preview) {
        self.preview.hidden = YES;
    }
}

#pragma mark - 懒加载
- (UIImageView *)bgProgressView {
    if (!_bgProgressView) {
        _bgProgressView = [UIImageView new];
        _bgProgressView.backgroundColor = [UIColor grayColor];
        _bgProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bgProgressView.clipsToBounds = YES;
    }
    return _bgProgressView;
}

- (UIImageView *)bufferProgressView {
    if (!_bufferProgressView) {
        _bufferProgressView = [UIImageView new];
        _bufferProgressView.backgroundColor = [UIColor whiteColor];
        _bufferProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bufferProgressView.clipsToBounds = YES;
    }
    return _bufferProgressView;
}

- (UIImageView *)sliderProgressView {
    if (!_sliderProgressView) {
        _sliderProgressView = [UIImageView new];
        _sliderProgressView.backgroundColor = [UIColor redColor];
        _sliderProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _sliderProgressView.clipsToBounds = YES;
    }
    return _sliderProgressView;
}

- (GKSliderButton *)sliderBtn {
    if (!_sliderBtn) {
        _sliderBtn = [GKSliderButton new];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchBegin:event:) forControlEvents:UIControlEventTouchDown];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchCancel];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
        [_sliderBtn addTarget:self action:@selector(sliderBtnDragMoving:event:) forControlEvents:UIControlEventTouchDragInside];
        [_sliderBtn addTarget:self action:@selector(sliderBtnDragMoving:event:) forControlEvents:UIControlEventTouchDragOutside];
    }
    return _sliderBtn;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    }
    return _panGesture;
}

@end

@implementation UIView (GKFrame)

- (void)setGk_left:(CGFloat)gk_left{
    CGRect f = self.frame;
    f.origin.x = gk_left;
    self.frame = f;
}

- (CGFloat)gk_left {
    return self.frame.origin.x;
}

- (void)setGk_top:(CGFloat)gk_top {
    CGRect f = self.frame;
    f.origin.y = gk_top;
    self.frame = f;
}

- (CGFloat)gk_top {
    return self.frame.origin.y;
}

- (void)setGk_right:(CGFloat)gk_right {
    CGRect f = self.frame;
    f.origin.x = gk_right - f.size.width;
    self.frame = f;
}

- (CGFloat)gk_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setGk_bottom:(CGFloat)gk_bottom {
    CGRect f = self.frame;
    f.origin.y = gk_bottom - f.size.height;
    self.frame = f;
}

- (CGFloat)gk_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setGk_width:(CGFloat)gk_width {
    CGRect f = self.frame;
    f.size.width = gk_width;
    self.frame = f;
}

- (CGFloat)gk_width {
    return self.frame.size.width;
}

- (void)setGk_height:(CGFloat)gk_height {
    CGRect f = self.frame;
    f.size.height = gk_height;
    self.frame = f;
}

- (CGFloat)gk_height {
    return self.frame.size.height;
}

- (void)setGk_centerX:(CGFloat)gk_centerX {
    CGPoint c = self.center;
    c.x = gk_centerX;
    self.center = c;
}

- (CGFloat)gk_centerX {
    return self.center.x;
}

- (void)setGk_centerY:(CGFloat)gk_centerY {
    CGPoint c = self.center;
    c.y = gk_centerY;
    self.center = c;
}

- (CGFloat)gk_centerY {
    return self.center.y;
}

@end

