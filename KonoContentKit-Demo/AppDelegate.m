//
//  AppDelegate.m
//  KonoContentKit-Demo
//
//  Created by raymond on 2017/6/13.
//  Copyright © 2017年 kono. All rights reserved.
//

#import "AppDelegate.h"
#import "KEArticleLandscapeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    KCService *contentManager = [KCService contentManager];
    [contentManager initializeApiURL:PROD_SERVER];
    [contentManager initializeBundleDecryptSecret:@"But when you call me baby I know I'm not the only one"];
    [contentManager initializeHTMLDecryptSecret:@"My anaconda don't want none unless you got bunz"];
    [contentManager loginTestingUser:^{
        
    }];
    
    return YES;
}

#pragma mark - appdelegate function - orientation

- (UIInterfaceOrientationMask)application:(UIApplication *)application
  supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    UIViewController *currentVC = [KEUtil getCurrentViewController];
    
    //We make the landscape viewcontroller, and all the viewcontroller linked by landscape viewcontroller can rotate
    if( [currentVC isKindOfClass:[KEArticleLandscapeViewController class]] ||
       [[self.window.rootViewController presentedViewController]
        isKindOfClass:[KEArticleLandscapeViewController class]] ){
           return UIInterfaceOrientationMaskAllButUpsideDown;
       }
    
    
    return UIInterfaceOrientationMaskPortrait;
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
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
