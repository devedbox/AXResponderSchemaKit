//
//  AppDelegate.m
//  AXViewControllerShema
//
//  Created by devedbox on 2016/10/11.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "AppDelegate.h"
#import "AXResponderSchemaKit.h"
#import "TableViewController.h"
#import "TabBarViewController.h"
#import "TableViewController.h"
#import "ViewController.h"
#import "ViewController1.h"
#import "ViewController2.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [AXResponderSchemaManager registerSchema:@"tabbar" forClass:TabBarViewController.class];
    [AXResponderSchemaManager registerSchema:@"tableview" forClass:TableViewController.class];
    [AXResponderSchemaManager registerSchema:@"viewcontroller" forClass:ViewController.class];
    [AXResponderSchemaManager registerSchema:@"viewcontroller1" forClass:ViewController1.class];
    [AXResponderSchemaManager registerSchema:@"viewcontroller2" forClass:ViewController2.class];
    
    NSLog(@"Tab bar controller: %@", NSStringFromClass([UIViewController classForSchemaIdentifier:@"tabbarviewcontroller"]));
    NSLog(@"Table view controller: %@", NSStringFromClass([UIViewController classForSchemaIdentifier:@"tableview"]));
    NSLog(@"View controller: %@", NSStringFromClass([UIViewController classForSchemaIdentifier:@"viewcontroller"]));
    NSLog(@"View controller1: %@", NSStringFromClass([UIViewController classForSchemaIdentifier:@"viewcontroller1"]));
    NSLog(@"View controller2: %@", NSStringFromClass([UIViewController classForSchemaIdentifier:@"viewcontroller2"]));
    
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
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
