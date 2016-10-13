//
//  UIAlertController+Schema.m
//  AXResponderSchemaManager
//
//  Created by devedbox on 2016/10/13.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "UIAlertController+Schema.h"
#import "AXResponderSchemaComponents.h"

NSString *const kAXResponderSchemaAlertSchemaTitleKey = @"title";
NSString *const kAXResponderSchemaAlertSchemaMessageKey = @"message";
NSString *const kAXResponderSchemaAlertSchemaStyleKey = @"style";

@implementation UIAlertController(Schema)
+ (nullable instancetype)viewControllerForSchemaWithParams:(NSDictionary **)params {
    NSString *title = (*params)[kAXResponderSchemaAlertSchemaTitleKey];
    NSString *message = (*params)[kAXResponderSchemaAlertSchemaMessageKey];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_9_0) {
        title = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        message = [message stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } else {
        title = [title stringByRemovingPercentEncoding];
        message = [message stringByRemovingPercentEncoding];
    }
#pragma clang diagnostic pop
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(*params)[kAXResponderSchemaAlertSchemaStyleKey]?[(*params)[kAXResponderSchemaAlertSchemaStyleKey] integerValue]:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:NULL]];
    if ((*params)[kAXResponderSchemaNavigationKey]) {
        AXSchemaNavigation navigation = [(*params)[kAXResponderSchemaNavigationKey] integerValue];
        if (navigation != AXSchemaNavigationPresent) {
            NSMutableDictionary *dic = [(*params) mutableCopy];
            dic[kAXResponderSchemaNavigationKey] = @"1";
            (*params) = dic;
        }
    } else {
        NSMutableDictionary *dic = [(*params) mutableCopy];
        dic[kAXResponderSchemaNavigationKey] = @"1";
        (*params) = dic;
    }
    return alert;
}

+ (nullable Class)classForSchemaIdentifier:(NSString *_Nonnull)schemaIdentifier {
    if ([schemaIdentifier isEqualToString:@"alert"]) {
        return self.class;
    }
    return [super classForSchemaIdentifier:schemaIdentifier];
}
@end
