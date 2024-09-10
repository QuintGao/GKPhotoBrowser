//
//  GKVideoViewCell.m
//  GKVideoScrollView
//
//  Created by QuintGao on 2023/4/14.
//

#import "GKVideoViewCell.h"

@interface GKVideoViewCell()

@property (nonatomic, copy) IBInspectable NSString *reuseIdentifier;

@end

@implementation GKVideoViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:UIScreen.mainScreen.bounds]) {
        self.reuseIdentifier = reuseIdentifier;
    }
    return self;
}

- (void)prepareForReuse {
    
}

@end
