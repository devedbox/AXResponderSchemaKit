//
//  UIViewController+Schema.m
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

#import "UIViewController+Schema.h"
#import "AXResponderSchemaManager.h"
#import <objc/runtime.h>

@implementation UIViewController (Schema)

+ (void)ax_exchangeClassOriginalMethod:(SEL)original swizzledMethod:(SEL)swizzled {
    Method _method1 = class_getInstanceMethod(self, original);
    if (_method1 == NULL) return;
    method_exchangeImplementations(_method1, class_getClassMethod(self, swizzled));
}

+ (void)ax_exchangeInstanceOriginalMethod:(SEL)original swizzledMethod:(SEL)swizzled {
    Method _method1 = class_getInstanceMethod(self, original);
    if (_method1 == NULL) return;
    method_exchangeImplementations(_method1, class_getInstanceMethod(self, swizzled));
}

+ (void)load {
    [self ax_exchangeInstanceOriginalMethod:@selector(viewDidAppear:) swizzledMethod:@selector(ax_viewDidAppear:)];
}

+ (instancetype)viewControllerForSchemaWithParams:(NSDictionary *)params {
    return nil;
}

+ (Class)classForNavigationController {
    return UINavigationController.class;
}

- (void)ax_viewDidAppear:(BOOL)animated {
    [self ax_viewDidAppear:animated];
    if (self.viewDidAppearSchema) {
        [[AXResponderSchemaManager sharedManager] openURL:self.viewDidAppearSchema];
    }
}

- (UIControl *)UIControlOfViewControllerForIdentifier:(NSString *)controlIdentifier {
    return nil;
}

- (NSURL *)viewDidAppearSchema {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setViewDidAppearSchema:(NSURL *)viewDidAppearSchema {
    objc_setAssociatedObject(self, @selector(viewDidAppearSchema), viewDidAppearSchema, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
