//
//  GKPhoto.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/20.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKPhoto.h"

@interface GKPhoto()
{
    NSOperationQueue *_requestQueue;
    dispatch_semaphore_t _lock;
}

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval accumulator;
@property (nonatomic, strong) UIImage *currentGifImage;

@property (nonatomic, assign) BOOL      isAnimation;

@end

@implementation GKPhoto

- (instancetype)init {
    if (self = [super init]) {
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = 1;
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - gif & 定时器
- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeKeyframe:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (void)changeKeyframe:(CADisplayLink *)displayLink {
    NSMutableDictionary *buffer = self.currentGifImage.gk_imageBuffer;
    if (self.currentGifImage.gk_totalFrameCount.intValue == 0) return;
    NSUInteger nextIndex = (self.currentGifImage.gk_handleIndex.intValue + 1) % self.currentGifImage.gk_totalFrameCount.intValue;
    BOOL bufferIsFull = NO;
    NSTimeInterval delay = 0;
    if (self.currentGifImage.bufferMiss.boolValue == NO) {
        self.accumulator += displayLink.duration;
        delay = [self.currentGifImage animatedImageDurationAtIndex:self.currentGifImage.gk_handleIndex.intValue];
        if (self.accumulator < delay) return;
        self.accumulator -= delay;
        delay = [self.currentGifImage animatedImageDurationAtIndex:(int)nextIndex];
        if (self.accumulator > delay) self.accumulator = delay;
    }
    UIImage *bufferedImage = buffer[@(nextIndex)];
    if (bufferedImage) {
        if (self.currentGifImage.needUpdateBuffer.boolValue) {
            [buffer removeObjectForKey:@(nextIndex)];
        }
        [self.currentGifImage gk_setHandleIndex:@(nextIndex)];
        self.imageView.image = bufferedImage;
        [self.currentGifImage gk_setBufferMiss:@(NO)];
        nextIndex = (self.currentGifImage.gk_handleIndex.intValue + 1) % self.currentGifImage.gk_totalFrameCount.intValue;
        if (buffer.count == self.currentGifImage.totalFrameCount.unsignedIntValue) {
            bufferIsFull = YES;
        }
    }else {
        [self.currentGifImage gk_setBufferMiss:@(YES)];
    }
    if (bufferIsFull == NO && _requestQueue.operationCount == 0) {
        GKPhotoDecoder *decoder = [GKPhotoDecoder new];
        decoder.nextIndex = nextIndex;
        decoder.curImage = self.currentGifImage;
        decoder.lock = _lock;
        [_requestQueue addOperation:decoder];
    }
}

- (void)startAnimation {
    if (self.isAnimation) return;
    self.isAnimation = YES;
    self.displayLink.paused = YES;
    self.currentGifImage = self.gifImage;
    if (!self.isGif) return;
    if (self.gifData.length == 0) return;
    [self.gifImage gk_animatedGIFData:self.gifData];
    self.accumulator = 0;
    self.displayLink.paused = NO;
}

- (void)stopAnimation {
    if (!self.isAnimation) return;
    self.isAnimation = NO;
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    
    self.imageView = nil;
    self.currentGifImage = nil;
    if (_requestQueue) {
        [_requestQueue cancelAllOperations];
    }
}

- (void)setCurrentGifImage:(UIImage *)currentGifImage {
    if (_currentGifImage == currentGifImage) {
        return;
    }
    LOCK([_currentGifImage imageViewShowFinished]);
    _currentGifImage = currentGifImage;
}

@end

@implementation GKPhotoDecoder

- (void)main {
    if ([self isCancelled]) return;
    int incrBufferCount = _curImage.gk_incrBufferCount.intValue;
    [_curImage gk_setIncrBufferCount:@(incrBufferCount + 1)];
    if (_curImage.gk_incrBufferCount.intValue > _curImage.gk_maxBufferCount.intValue) {
        [_curImage gk_setIncrBufferCount:_curImage.gk_maxBufferCount];
    }
    
    NSUInteger index = _nextIndex;
    NSUInteger max   = _curImage.gk_incrBufferCount.intValue;
    NSUInteger total = _curImage.gk_totalFrameCount.intValue;
    for (int i = 0; i < max; i++, index++) {
        @autoreleasepool {
            if (index >= total) index = 0;
            if ([self isCancelled]) break;
            LOCK(BOOL miss = (_curImage.gk_imageBuffer[@(index)]) == nil);
            if (miss) {
                if ([self isCancelled]) break;
                LOCK(UIImage *img = [_curImage animatedImageFrameAtIndex:(int)index]);
                if (img) {
                    LOCK([_curImage.gk_imageBuffer setObject:img forKey:@(index)]);
                }
            }
        }
    }
}

@end
