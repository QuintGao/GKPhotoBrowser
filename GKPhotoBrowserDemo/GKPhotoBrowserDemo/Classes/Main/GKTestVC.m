//
//  GKTestVC.m
//  GKPhotoBrowserDemo
//
//  Created by QuintGao on 2021/4/20.
//  Copyright © 2021 QuintGao. All rights reserved.
//

#import "GKTestVC.h"

@implementation GKTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.gk_navRightBarButtonItem = [UIBarButtonItem gk_itemWithTitle:@"关闭" target:self action:@selector(close)];
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
