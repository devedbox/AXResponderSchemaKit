//
//  UIAlertController+Schema.h
//  AXResponderSchemaManager
//
//  Created by devedbox on 2016/10/13.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Schema.h"

extern NSString *const kAXResponderSchemaAlertSchemaTitleKey;
extern NSString *const kAXResponderSchemaAlertSchemaMessageKey;
extern NSString *const kAXResponderSchemaAlertSchemaStyleKey;

@interface UIAlertController (Schema)
+ (instancetype)viewControllerForSchemaWithParams:(NSDictionary **)params;
+ (Class)classForSchemaIdentifier:(NSString *_Nonnull)schemaIdentifier;
@end
