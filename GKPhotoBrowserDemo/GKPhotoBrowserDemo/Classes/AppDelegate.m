//
//  AppDelegate.m
//  GKPhotoBrowser
//
//  Created by QuintGao on 2017/10/20.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "AppDelegate.h"
#import "GKMainViewController.h"
#import "GKPhotoBrowserConfigure.h"
#import "GKTestVC.h"

@interface AppDelegate ()

@property (nonatomic, assign) BOOL enterBackground;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GKConfigure setupCustomConfigure:^(GKNavigationBarConfigure *configure) {
        configure.backgroundColor = [UIColor blackColor];
        configure.statusBarStyle  = UIStatusBarStyleLightContent;
        configure.backStyle       = GKNavigationBarBackStyleWhite;
        configure.titleColor      = [UIColor whiteColor];
        configure.titleFont       = [UIFont boldSystemFontOfSize:18.0];
        configure.gk_navItemLeftSpace   = 4;
        configure.gk_navItemRightSpace  = 4;
    }];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
//    self.window.rootViewController = [UINavigationController rootVC:[GKMainViewController new] translationScale:NO];
    self.window.rootViewController = [UINavigationController rootVC:[GKMainViewController new]];
    
    [self.window makeKeyAndVisible];
    
    BOOL statusBarAppearance = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"] boolValue];
    if (!statusBarAppearance) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
#pragma clang diagnostic pop
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    self.enterBackground = YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
//    if (!self.enterBackground) return;
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        GKTestVC *testVC = [GKTestVC new];
//        [GKConfigure.visibleViewController.navigationController pushViewController:testVC animated:YES];
////        testVC.modalPresentationStyle = UIModalPresentationFullScreen;
////        [GKConfigure.visibleViewController presentViewController:testVC animated:YES completion:nil];
//    });
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

@end
