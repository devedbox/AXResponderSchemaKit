//
//  AXViewControllerShema.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

extern NSString *const kAXResponderSchemaModuleUIViewController;
extern NSString *const kAXResponderSchemaModuleUIControl;

/// Default schema identifiers.
extern NSString *const kAXResponderSchemaTabBarControllerIdentifier;

@interface AXResponderSchemaManager : NSObject
/// App schema.
@property(copy, nonatomic) NSString *appSchema;
/// Class for navigation controller.
@property(nullable, copy, nonatomic) Class navigationControllClass;
/// View controller to show the new added view controller.
@property(nullable, weak, nonatomic) UIViewController *viewController;
/// Tab bar controller to show selectd view controller.
@property(nullable, weak, nonatomic) UITabBarController *tabBarController;
/// Navigation controller to push new added view controller.
@property(nullable, weak, nonatomic) UINavigationController *navigationController;

+ (instancetype)sharedManager;

+ (void)registerSchema:(NSString *)schemaIdentifier forClass:(NSString *)classIdentifier;
+ (void)unregisterSchema:(NSString *)schemaIdentifier;
+ (Class _Nullable)classForSchema:(NSString *)schemaIdentifier;

- (BOOL)openURL:(NSURL *)url;
- (BOOL)openURL:(NSURL *)url completion:(NSURL * _Nullable)completion;
- (BOOL)canOpenURL:(NSURL *)url;
@end
NS_ASSUME_NONNULL_END
