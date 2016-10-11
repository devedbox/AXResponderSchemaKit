//
//  AXViewControllerShema.m
//  AXViewControllerShema
//
//  Created by devedbox on 2016/10/11.
//  Copyright © 2016年 devedbox. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "AXResponderSchemaManager.h"
#import "AXResponderSchemaComponents.h"
#import "UIViewController+Schema.h"
#import <objc/runtime.h>

NSString *const kAXResponderSchemaModuleUIViewController = @"viewcontroller";
NSString *const kAXResponderSchemaModuleUIControl = @"control";

NSString *const kAXResponderSchemaTabBarControllerIdentifier = @"tabbar";

NSString *const kAXResponderSchemaCompletionURLKey = @"completion";

@implementation AXResponderSchemaManager
+ (instancetype)sharedManager {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Public
- (BOOL)canOpenURL:(NSURL *)url {
    return [self _canOpenURL:url]?:[[UIApplication sharedApplication] canOpenURL:url];;
}

- (BOOL)openURL:(NSURL *)url {
    return [self openURL:url completion:nil];
}

- (BOOL)openURL:(NSURL *)url completion:(NSURL *)completion {
    if (![self canOpenURL:url]) return NO;
    if (![self _canOpenURL:url]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_9_4) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:NULL];
                return YES;
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                return [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
            }
        }
    }
    
    return [self _openSchemaWithSchemaComponents:[AXResponderSchemaComponents componentsWithURL:url] completion:completion viewDidAppearSchema:nil];
}

+ (void)registerSchema:(NSString *)schemaIdentifier forClass:(NSString *)classIdentifier {
    if ([self classForSchema:schemaIdentifier] != NULL) return;
    [[NSUserDefaults standardUserDefaults] setObject:classIdentifier forKey:[NSString stringWithFormat:@"_axresponderschema_%@", schemaIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)unregisterSchema:(NSString *)schemaIdentifier {
    if ([self classForSchema:schemaIdentifier] == NULL) return;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:[NSString stringWithFormat:@"_axresponderschema_%@", schemaIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (Class)classForSchema:(NSString *)schemaIdentifier {
    NSString *classIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"_axresponderschema_%@", schemaIdentifier]];
    return NSClassFromString(classIdentifier);
}
#pragma mark - Private
- (BOOL)_canOpenURL:(NSURL *)url {
    if (!url) return NO;
    return [self _isAppSchema:[AXResponderSchemaComponents componentsWithURL:url]];
}

- (BOOL)_isAppSchema:(AXResponderSchemaComponents *)schema {
    return [[schema scheme] isEqualToString:_appSchema?:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] lowercaseString]];
}

- (BOOL)_openSchemaWithSchemaComponents:(AXResponderSchemaComponents *)components completion:(NSURL *)completionURL viewDidAppearSchema:(NSURL *)schema {
    Class schemaClass = [self.class classForSchema:components.identifier];
    
    if (class_isMetaClass(schemaClass)) return NO;
    if ((schemaClass == NULL || ![UIApplication sharedApplication].keyWindow.rootViewController) && ![components.identifier isEqualToString:kAXResponderSchemaTabBarControllerIdentifier]) return NO;
    // Handle the moudle.
    if ([components.module isEqualToString:kAXResponderSchemaModuleUIViewController]) { // View controller -> Show and hide.
        if ([[self _topViewController] isMemberOfClass:schemaClass]) return NO;
        // Get the new view controller with the methods.
        if (![schemaClass isSubclassOfClass:UIViewController.class]) {
            return NO;
        }
        // Set up params.
        NSMutableDictionary *params = [components.params mutableCopy];
        if (completionURL) [params setObject:completionURL forKey:kAXResponderSchemaCompletionURLKey];
        // Get the view controller.
        UIViewController *viewController = [schemaClass viewControllerForSchemaWithParams:params];
        
        viewController.viewDidAppearSchema = schema;
        
        UIViewController *viewControllerToShow = _navigationController?:_viewController;
        // Get the navitation.
        switch (components.navigation) {
            case AXSchemaNavigationPresent:
                if (!viewControllerToShow) {
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
                        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
                        if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
                            rootViewController = (UINavigationController *)tabBarController.selectedViewController;
                        }
                    }
                    
                    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
                        viewControllerToShow = [(UINavigationController *)rootViewController topViewController];
                    } else if ([rootViewController isKindOfClass:[UIViewController class]]) {
                        viewControllerToShow = rootViewController.navigationController;
                    }
                }
                if ([viewController isKindOfClass:UINavigationController.class]) { // Presented with nagigation controller.
                    [viewControllerToShow presentViewController:viewController animated:components.animated completion:NULL];
                } else {
                    // Get navigation class.
                    Class navigationClass = class_respondsToSelector(schemaClass, @selector(classForNavigationController))?[schemaClass classForNavigationController]:_navigationControllClass?:UINavigationController.class;
                    // Verify class.
                    if (class_isMetaClass(navigationClass)) return NO;
                    if (![navigationClass isSubclassOfClass:UINavigationController.class]) {
                        return NO;
                    }
                    // Initialize a navigation controller.
                    UINavigationController *navigationController = [[navigationClass alloc] initWithRootViewController:viewController];
                    [viewControllerToShow presentViewController:navigationController animated:components.animated completion:NULL];
                }
                return YES;
            case AXSchemaNavigationSelectedIndex: {
                // Get tab bar controller.
                UITabBarController *tabBarController = _tabBarController;
                if (!tabBarController) {
                    // Get the root view controller.
                    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
                    if ([vc isKindOfClass:[UITabBarController class]]) {
                        tabBarController = (UITabBarController*)vc;
                    }
                }
                if (!tabBarController) {
                    return NO;
                } else {
                    if (components.selectedIndex > tabBarController.viewControllers.count-1) {
                        return NO;
                    }
                    [tabBarController setSelectedIndex:components.selectedIndex];
                }
                return YES;
            }
            default: {
                // Get the navigation controller.
                UINavigationController *navigationController = _navigationController ?: [self _rootNavigationController];
                
                if (!navigationController) return NO;
                
                [navigationController pushViewController:viewController animated:components.animated];
                return YES;
            }
        }
    } else if ([components.module isEqualToString:kAXResponderSchemaModuleUIControl]) { // UIControl -> Send actions.
        // Get the control object.
        if (![schemaClass isSubclassOfClass:UIViewController.class]) {
            return NO;
        }
        //TODO: Implemente UIControl.
        // Get the top view controller.
        UIViewController *topViewController = [self _topViewController];
        if ([topViewController isMemberOfClass:schemaClass]) {
            // Get control.
            UIControl *control = [topViewController UIControlOfViewControllerForIdentifier:components.identifier];
            if (!control) return NO;
            [control sendActionsForControlEvents:components.event];
            return YES;
        } else {
            // Open view controller first.
            [components setValue:@"viewcontroller" forKeyPath:@"module"];
            return [self _openSchemaWithSchemaComponents:components completion:nil viewDidAppearSchema:components.URL];
            return YES;
        }
    }
    return NO;
}

#pragma mark - Private
- (UINavigationController *)_rootNavigationController {
    return [[self _topViewController] navigationController];
}

- (UIViewController *)_topViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
            rootViewController = (UINavigationController *)tabBarController.selectedViewController;
        }
    }
    
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)rootViewController topViewController];
    } else if ([rootViewController isKindOfClass:[UIViewController class]]) {
        return rootViewController.navigationController;
    }
    return nil;
}
@end
