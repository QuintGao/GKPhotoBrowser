//
//  UIScrollView+ZFPlayer.m
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFKVOController.h"

@interface ZFKVOEntry : NSObject
@property (nonatomic, weak)   NSObject *observer;
@property (nonatomic, copy) NSString *keyPath;

@end

@implementation ZFKVOEntry

@end

@interface ZFKVOController ()
@property (nonatomic, weak) NSObject *target;
@property (nonatomic, strong) NSMutableArray *observerArray;

@end

@implementation ZFKVOController

- (instancetype)initWithTarget:(NSObject *)target {
    self = [super init];
    if (self) {
        _target = target;
        _observerArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)safelyAddObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
                  options:(NSKeyValueObservingOptions)options
                  context:(void *)context {
    if (_target == nil) return;
    
    NSInteger indexEntry = [self indexEntryOfObserver:observer forKeyPath:keyPath];
    if (indexEntry != NSNotFound) {
        // duplicated register
        NSLog(@"duplicated observer");
    } else {
        @try {
            [_target addObserver:observer
                     forKeyPath:keyPath
                        options:options
                        context:context];
            
            ZFKVOEntry *entry = [[ZFKVOEntry alloc] init];
            entry.observer = observer;
            entry.keyPath  = keyPath;
            [_observerArray addObject:entry];
        } @catch (NSException *e) {
            NSLog(@"ZFKVO: failed to add observer for %@\n", keyPath);
        }
    }
}

- (void)safelyRemoveObserver:(NSObject *)observer
                  forKeyPath:(NSString *)keyPath {
    if (_target == nil) return;
    
    NSInteger indexEntry = [self indexEntryOfObserver:observer forKeyPath:keyPath];
    if (indexEntry == NSNotFound) {
        // duplicated register
        NSLog(@"duplicated observer");
    } else {
        [_observerArray removeObjectAtIndex:indexEntry];
        @try {
            [_target removeObserver:observer
                            forKeyPath:keyPath];
        } @catch (NSException *e) {
            NSLog(@"ZFKVO: failed to remove observer for %@\n", keyPath);
        }
    }
}

- (void)safelyRemoveAllObservers {
    if (_target == nil) return;
    [_observerArray enumerateObjectsUsingBlock:^(ZFKVOEntry *entry, NSUInteger idx, BOOL *stop) {
        if (entry == nil) return;
        NSObject *observer = entry.observer;
        if (observer == nil) return;
        @try {
            [_target removeObserver:observer
                        forKeyPath:entry.keyPath];
        } @catch (NSException *e) {
            NSLog(@"ZFKVO: failed to remove observer for %@\n", entry.keyPath);
        }
    }];
    
    [_observerArray removeAllObjects];
}

- (NSInteger)indexEntryOfObserver:(NSObject *)observer
                   forKeyPath:(NSString *)keyPath {
    __block NSInteger foundIndex = NSNotFound;
    [_observerArray enumerateObjectsUsingBlock:^(ZFKVOEntry *entry, NSUInteger idx, BOOL *stop) {
        if (entry.observer == observer &&
            [entry.keyPath isEqualToString:keyPath]) {
            foundIndex = idx;
            *stop = YES;
        }
    }];
    return foundIndex;
}

@end
