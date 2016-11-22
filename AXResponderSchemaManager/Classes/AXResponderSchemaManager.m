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
#import "AXResponderSchemaConstant.h"
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
    return [self openURL:url completion:nil viewDidAppear:nil];
}

- (BOOL)openURL:(NSURL *)url completion:(NSURL *)completion {
    return [self openURL:url completion:completion viewDidAppear:nil];
}

- (BOOL)openURL:(NSURL *)url viewDidAppear:(NSURL *)viewDidAppear {
    return [self openURL:url completion:nil viewDidAppear:viewDidAppear];
}

- (BOOL)openURL:(NSURL *)url completion:(NSURL *)completion viewDidAppear:(NSURL *)viewDidAppear {
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
    
    return [self _openSchemaWithSchemaComponents:[AXResponderSchemaComponents componentsWithURL:url] completion:completion viewDidAppearSchema:viewDidAppear];
}

+ (void)registerSchema:(NSString *)schemaIdentifier forClass:(NSString *)classIdentifier {
    if ([self classForSchema:schemaIdentifier] != NULL || ![classIdentifier isKindOfClass:NSString.class]) return;
    [[NSUserDefaults standardUserDefaults] setObject:classIdentifier forKey:[NSString stringWithFormat:@"_axresponderschema_%@", schemaIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)unregisterSchema:(NSString *)schemaIdentifier {
    if ([self classForSchema:schemaIdentifier] == NULL || ![schemaIdentifier isKindOfClass:NSString.class]) return;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:[NSString stringWithFormat:@"_axresponderschema_%@", schemaIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (Class)classForSchema:(NSString *)schemaIdentifier {
    if (![schemaIdentifier isKindOfClass:NSString.class]) return NULL;
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
    Class schemaClass = NULL;
    
    if (components.schemaClassIdentifier) {// Get the specific class for class identifier in url params.
        schemaClass = [UIViewController classForSchemaIdentifier:components.schemaClassIdentifier];
        if (schemaClass == NULL) {// Get the class for the schema identifier.
            schemaClass = [UIViewController classForSchemaIdentifier:components.identifier];
        }
    } else {// Get the class for the schema identifier.
        schemaClass = [UIViewController classForSchemaIdentifier:components.identifier];
    }
    if (schemaClass == NULL) {
        schemaClass = [self.class classForSchema:components.identifier];
    } else {
        if (![schemaClass allowsForSchameIdentifier:components.identifier]) return NO;
    }
    
    if (class_isMetaClass(schemaClass)) return NO;
    if ((schemaClass == NULL || ![UIApplication sharedApplication].keyWindow.rootViewController) && ![components.identifier isEqualToString:kAXResponderSchemaTabBarControllerIdentifier]) return NO;
    // Handle the moudle.
    if ([components.module isEqualToString:kAXResponderSchemaModuleUIViewController]) { // View controller -> Show and hide.
        BOOL force = NO;
        if (components.params[kAXResponderSchemaForceKey]) {
            force = components.force;
        }
        
        if ([[self _topViewController] isMemberOfClass:schemaClass] && !force) return NO;
        // Get the new view controller with the methods.
        if (![schemaClass isSubclassOfClass:UIViewController.class]) {
            return NO;
        }
        // Set up params.
        NSMutableDictionary *params = [components.params mutableCopy];
        if (completionURL) [params setObject:completionURL forKey:kAXResponderSchemaCompletionURLKey];
        // Get the view controller.
        UIViewController *viewController = [schemaClass viewControllerForSchemaWithParams:&params];
        
        [components setValue:params forKeyPath:@"params"];
        
        if (![viewController isMemberOfClass:UIAlertController.class]) {
            viewController.viewDidAppearSchema = schema;
        }
        
        UIViewController *viewControllerToShow = _navigationController?:_viewController;
        
        BOOL animated = YES;
        if (components.params[kAXResponderSchemaAnimatedKey]) {
            animated = components.animated;
        }
        
        void(^_alertIssue)() = ^() {
            // Show the alert.
            [components setValue:@"alert" forKeyPath:@"identifier"];
            // Set title.
            NSString *title = AXResponderSchemaManagerLocalizedString(@"openfailed", @"Openfailed");
            // Set message.
            NSString *message = AXResponderSchemaManagerLocalizedString(@"openissue", @"Openissue");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_9_0) {
                title = [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                message = [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
            } else {
                NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
                NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
                title = [title stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
                message = [message stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
            }
#pragma clang diagnostic pop
            // Open alert controller.
            [self openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://viewcontroller/alert?title=%@&message=%@", components.scheme, title, message]]];
        };
        
        // Get the navitation.
        switch (components.navigation) {
            case AXSchemaNavigationPresent: {
                UIViewController *topViewController = [self _topViewController];

                if (!force) {
                    BOOL shouldResolveSchema=YES;
                    if ([topViewController isMemberOfClass:schemaClass]) {
                        
                        shouldResolveSchema = [topViewController shouldResolveSchemaWithParams:components.params];
                        
                        if (shouldResolveSchema) {
                            [topViewController resolveSchemaWithParams:components.params];
                            return YES;
                        }
                    }
                    if ([topViewController isKindOfClass:[UINavigationController class]]) {
                        if ([[(UINavigationController*)topViewController topViewController] isMemberOfClass:schemaClass]) {
                            
                            shouldResolveSchema = [[(UINavigationController*)topViewController topViewController] shouldResolveSchemaWithParams:components.params];
                            
                            if (shouldResolveSchema) {
                                [[(UINavigationController*)topViewController topViewController] resolveSchemaWithParams:components.params];
                                return YES;
                            }
                        }
                    }
                    if ([topViewController presentedViewController]) {
                        if ([[topViewController presentedViewController] isMemberOfClass:schemaClass]) {
                            
                            shouldResolveSchema = [[topViewController presentedViewController] shouldResolveSchemaWithParams:components.params];
                            
                            if (shouldResolveSchema) {
                                [[topViewController presentedViewController] resolveSchemaWithParams:components.params];
                                return YES;
                            }
                        }
                        if ([[topViewController presentedViewController] isKindOfClass:[UINavigationController class]]) {
                            if ([[(UINavigationController*)[topViewController presentedViewController] topViewController] isMemberOfClass:schemaClass]) {
                                
                                shouldResolveSchema = [[(UINavigationController*)[topViewController presentedViewController] topViewController] shouldResolveSchemaWithParams:components.params];
                                
                                if (shouldResolveSchema) {
                                    [[(UINavigationController*)[topViewController presentedViewController] topViewController] resolveSchemaWithParams:components.params];
                                    return YES;
                                }
                            }
                        }
                    }
                    if ([topViewController presentingViewController]) {
                        if ([[topViewController presentingViewController] isMemberOfClass:schemaClass]) {
                            
                            shouldResolveSchema = [[topViewController presentingViewController] shouldResolveSchemaWithParams:components.params];
                            
                            if (shouldResolveSchema) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [topViewController dismissViewControllerAnimated:animated completion:NULL];
                                });
                                [[topViewController presentingViewController] resolveSchemaWithParams:components.params];
                                return YES;
                            }
                        }
                        if ([[topViewController presentingViewController] isKindOfClass:[UINavigationController class]]) {
                            if ([[(UINavigationController*)[topViewController presentedViewController] topViewController] isMemberOfClass:schemaClass]) {
                                
                                shouldResolveSchema = [[(UINavigationController*)[topViewController presentedViewController] topViewController] shouldResolveSchemaWithParams:components.params];
                                
                                if (shouldResolveSchema) {
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [topViewController dismissViewControllerAnimated:animated completion:NULL];
                                    });
                                    [[(UINavigationController*)[topViewController presentedViewController] topViewController] resolveSchemaWithParams:components.params];
                                    return YES;
                                }
                            }
                        }
                    }
                }
                
                if (!viewControllerToShow) {
                    viewControllerToShow = topViewController;
                }
                
                // Show the alert.
                if (!viewController) {
                    _alertIssue();
                    return NO;
                }
                
                if ([viewController isKindOfClass:UINavigationController.class] || [viewController isKindOfClass:UIAlertController.class]) { // Presented with nagigation controller.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [viewControllerToShow presentViewController:viewController animated:animated completion:NULL];
                    });
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
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [viewControllerToShow presentViewController:navigationController animated:animated completion:NULL];
                    });
                }
                return YES;
            }
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
                    
                    BOOL shouldResolveSchema = [tabBarController shouldResolveSchemaWithParams:components.params];
                    
                    if (!shouldResolveSchema) {
                        return NO;
                    }
                    
                    [tabBarController resolveSchemaWithParams:components.params];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [tabBarController setSelectedIndex:components.selectedIndex];
                        
                        if ([[[tabBarController viewControllers] objectAtIndex:components.selectedIndex] isKindOfClass:[UINavigationController class]] && force) {
                            [(UINavigationController*)[[tabBarController viewControllers] objectAtIndex:components.selectedIndex] popToRootViewControllerAnimated:animated];
                        }
                    });
                }
                return YES;
            }
            default: {
                // Get the navigation controller.
                UINavigationController *navigationController = _navigationController ?: [self _rootNavigationController];
                
                if (!navigationController) return NO;
                
                if (force) {
                    if (!viewController) {
                        _alertIssue();
                        return NO;
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [navigationController pushViewController:viewController animated:animated];
                    });
                    return YES;
                }
                
                UIViewController *exitsViewController;
                
                NSInteger index = [self _indexOfClass:schemaClass inNavigationController:&navigationController exists:&exitsViewController animated:animated];
                
                if (index == -1) {
                    BOOL shouldResolveSchema = [exitsViewController shouldResolveSchemaWithParams:components.params];
                    
                    if (!shouldResolveSchema) {
                        if (!viewController) {
                            _alertIssue();
                            return NO;
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [navigationController pushViewController:viewController animated:animated];
                        });
                        return YES;
                    }
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [navigationController dismissViewControllerAnimated:animated completion:NULL];
                    });
                    [exitsViewController resolveSchemaWithParams:components.params];
                } else if (index == NSNotFound) {
                    if (!viewController) {
                        _alertIssue();
                        return NO;
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [navigationController pushViewController:viewController animated:animated];
                    });
                } else {
                    BOOL shouldResolveSchema = [exitsViewController shouldResolveSchemaWithParams:components.params];
                    
                    if (!shouldResolveSchema) {
                        if (!viewController) {
                            _alertIssue();
                            return NO;
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [navigationController pushViewController:viewController animated:animated];
                        });
                        return YES;
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [navigationController popToViewController:navigationController.viewControllers[index] animated:animated];
                    });
                    
                    [exitsViewController resolveSchemaWithParams:components.params];
                }
                return YES;
            }
        }
    } else if ([components.module isEqualToString:kAXResponderSchemaModuleUIControl]) { // UIControl -> Send actions.
        // Get the control object.
        if (![schemaClass isSubclassOfClass:UIViewController.class]) {
            return NO;
        }
        
        // Get the top view controller.
        UIViewController *topViewController = [self _topViewController];
        if ([topViewController isMemberOfClass:schemaClass]) {
            // Resolve the params.
            [topViewController resolveSchemaWithParams:components.params];
            // Get control.
            UIControl *control = [topViewController UIControlOfViewControllerForIdentifier:components.identifier];
            if (!control) return NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(components.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [control sendActionsForControlEvents:components.event];
            });
            return YES;
        } else {
            // Open view controller first.
            [components setValue:@"viewcontroller" forKeyPath:@"module"];
            NSMutableDictionary *params = [components.params mutableCopy];
            [params setObject:@(.0) forKey:@"delay"];
            [components setValue:[params copy] forKey:@"params"];
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
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self _topViewControllerWithRootViewController:topViewController];
}

- (UIViewController *)_topViewControllerWithRootViewController:(UIViewController *_Nullable)rootViewCoontroller {
    UIViewController *topViewController = rootViewCoontroller;
    // Find the view controller hierarchy if class is `UITabBarController`.
    if ([topViewController isKindOfClass:[UITabBarController class]]) {
        // Get the tab bar controller.
        UITabBarController *tabBarController = (UITabBarController *)topViewController;
        // Find the view controller hierarchy if class is still `UITabBarController` or `UINavigationController`.
        if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]] || [tabBarController.selectedViewController isKindOfClass:[UITabBarController class]]) {
            topViewController = [self _topViewControllerWithRootViewController:tabBarController.selectedViewController];
        }  else {
            if ([tabBarController.selectedViewController.presentedViewController isKindOfClass:[UINavigationController class]] || [tabBarController.selectedViewController.presentedViewController isKindOfClass:[UITabBarController class]]) {
                topViewController = [self _topViewControllerWithRootViewController:tabBarController.selectedViewController.presentedViewController];
            }
            topViewController = tabBarController.selectedViewController.presentedViewController?:tabBarController.selectedViewController;
        }
    }
    // Resolve the navigation class.
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)topViewController;
        if (navigationController.presentedViewController) {
            if ([navigationController.presentedViewController isKindOfClass:[UINavigationController class]] || [navigationController.presentedViewController isKindOfClass:[UITabBarController class]]) {
                return [self _topViewControllerWithRootViewController:navigationController.presentedViewController];
            }
            return navigationController.presentedViewController;
        } else if (navigationController.topViewController) {
            if (navigationController.topViewController.presentedViewController) {
                if ([navigationController.topViewController.presentedViewController isKindOfClass:[UINavigationController class]] || [navigationController.topViewController.presentedViewController isKindOfClass:[UITabBarController class]]) {
                    return [self _topViewControllerWithRootViewController:navigationController.topViewController.presentedViewController];
                }
                return navigationController.topViewController.presentedViewController;
            } else {
                if ([navigationController.topViewController isKindOfClass:[UINavigationController class]] || [navigationController.topViewController isKindOfClass:[UITabBarController class]]) {
                    return [self _topViewControllerWithRootViewController:navigationController.topViewController];
                }
                return navigationController.topViewController;
            }
        } else {
            return navigationController;
        }
    } else if ([topViewController isKindOfClass:[UIViewController class]]) {
        if (topViewController.presentedViewController) {
            if ([topViewController.presentedViewController isKindOfClass:[UINavigationController class]] || [topViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
                return [self _topViewControllerWithRootViewController:topViewController.presentedViewController];
            }
            return topViewController.presentedViewController;
        }
        return topViewController;
    } else {
        return topViewController;
    }
}

- (NSInteger)_indexOfClass:(Class)schemaClass inNavigationController:(UINavigationController **)navigationController exists:(UIViewController **)viewController animated:(BOOL)animated {
    // Find the index of schema class if exits.
    NSInteger index = [(*navigationController).viewControllers indexOfObjectPassingTest:^BOOL(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isMemberOfClass:schemaClass]) {
            *stop = YES;
            return YES;
        } else {
            return NO;
        }
    }];
    if (index != NSNotFound) {
        (*viewController) = [(*navigationController).viewControllers objectAtIndex:index];
        return index;
    }
    if ((*navigationController).presentingViewController) {
        // Handle with presenting view controller.
        if ([(*navigationController).presentingViewController isMemberOfClass:schemaClass]) {
            // If current top view controller is member of schema class, return -1 to dismiss the presented controller.
            (*viewController) = (*navigationController).presentingViewController;
            return -1;
        } else if ([(*navigationController).presentingViewController isKindOfClass:UINavigationController.class]) {
            // Get navigation controller.
            UINavigationController *navi = (UINavigationController *)((*navigationController).presentingViewController);
            // Dismiss the navigation controller above.
            [(*navigationController) dismissViewControllerAnimated:animated completion:NULL];
            // Set the navigation controller blow.
            *navigationController = navi;
            // Call mthods again.
            return [self _indexOfClass:schemaClass inNavigationController:&navi exists:viewController animated:animated];
            // Handle with tab bar controller.
        } else if ([(*navigationController).presentingViewController isKindOfClass:UITabBarController.class]) {
            // Get tab bar controller.
            UITabBarController *tabBarController = (UITabBarController *)(*navigationController).presentingViewController;
            // Handle navigation controller if selected controller of tab bar controller is class of `UINavigationController`.
            if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
                // Get the selected navigation controller.
                UINavigationController *navi = (UINavigationController *)tabBarController.selectedViewController;
                // Get the index of schema in the selected navigation controller.
                NSInteger index = [self _indexOfClass:schemaClass inNavigationController:&navi exists:viewController animated:animated];
                // Verify index of schema class.
                if (index != NSNotFound) {
                    // If index found, dismiss the navigation controller.
                    // Set to new.
                    (*navigationController) = navi;
                    // Dismiss.
                    [(*navigationController) dismissViewControllerAnimated:animated completion:NULL];
                }
                return index;
            }
        } else if ((*navigationController).presentingViewController.navigationController) {// Handle with the navigation controller of presenting controller.
            // Get the navigation controller.
            UINavigationController *navi = (*navigationController).presentingViewController.navigationController;
            // Dismiss the navigation controller.
            [(*navigationController) dismissViewControllerAnimated:animated completion:NULL];
            // Set the new.
            *navigationController = navi;
            // Call self.
            return [self _indexOfClass:schemaClass inNavigationController:&navi exists:viewController animated:animated];
        }
    }
    return NSNotFound;
}
@end
