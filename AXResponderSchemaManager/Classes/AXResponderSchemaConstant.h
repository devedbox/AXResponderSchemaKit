//
//  AXResponderSchemaConstant.h
//  AXResponderSchemaManager
//
//  Created by devedbox on 2016/10/15.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#ifndef AXResponderSchemaConstant_h
#define AXResponderSchemaConstant_h

#import "AXResponderSchemaManager.h"

#ifndef AXResponderSchemaManagerLocalizedString
#define AXResponderSchemaManagerLocalizedString(key, comment) \
NSLocalizedStringFromTableInBundle(key, @"AXResponderSchemaManager", [NSBundle bundleWithPath:[[[NSBundle bundleForClass:[AXResponderSchemaManager class]] resourcePath] stringByAppendingPathComponent:@"AXResponderSchemaManager.bundle"]], comment)
#endif

#endif /* AXResponderSchemaConstant_h */
