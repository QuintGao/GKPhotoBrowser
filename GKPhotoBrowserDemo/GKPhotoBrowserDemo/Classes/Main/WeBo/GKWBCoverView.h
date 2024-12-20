//
//  GKWBCoverView.h
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2024/12/19.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GKPhotoBrowser/GKCoverViewProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKWBCoverView : NSObject<GKCoverViewProtocol>

- (void)willDisappear;
- (void)didAppear;

@end

NS_ASSUME_NONNULL_END
