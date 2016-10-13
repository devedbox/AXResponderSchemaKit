//
//  TabBarViewController.m
//  AXViewControllerShema
//
//  Created by devedbox on 2016/10/11.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "TabBarViewController.h"
#import "AXResponderSchemaManager.h"
#import "UIViewController+Schema.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController
+ (Class)classForSchemaIdentifier:(NSString *)schemaIdentifier {
    if ([schemaIdentifier  isEqual: @"tabbar"]) {
        return self;
    }
    return [super classForSchemaIdentifier:schemaIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [AXResponderSchemaManager registerSchema:kAXResponderSchemaTabBarControllerIdentifier forClass:@"TabBarViewController"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
