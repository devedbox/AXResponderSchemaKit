//
//  ViewController1.m
//  AXViewControllerShema
//
//  Created by devedbox on 2016/10/11.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "ViewController1.h"
#import "UIViewController+Schema.h"
#import "AXResponderSchemaManager.h"

@interface ViewController1 ()

@end

@implementation ViewController1

+ (Class)classForSchemaIdentifier:(NSString *)schemaIdentifier {
    if ([schemaIdentifier  isEqual: @"viewcontroller1"]) {
        return self;
    }
    return [super classForSchemaIdentifier:schemaIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
+ (instancetype)viewControllerForSchemaWithParams:(NSDictionary **)params {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"kViewController1Identifier"];
}
+ (Class)classForNavigationController {
    return [UINavigationController class];
}

- (UIControl *)UIControlOfViewControllerForIdentifier:(NSString *)controlIdentifier {
    return _switcha;
}

- (IBAction)switchaaa:(id)sender {
    [_switcha setOn:!_switcha.on animated:YES];
}

- (IBAction)sendSwitch:(id)sender {
    [[AXResponderSchemaManager sharedManager] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"axviewcontrollerschema://control/switch?navigation=0&animated=1&action=%@", @(1 << 12)]]];
}

- (IBAction)showViewController2:(id)sender {
    [[AXResponderSchemaManager sharedManager] openURL:[NSURL URLWithString:@"axviewcontrollerschema://viewcontroller/show2?navigation=1&animated=1&class=ViewController2"]];
}

- (IBAction)showTableViewController:(id)sender {
    [[AXResponderSchemaManager sharedManager] openURL:[NSURL URLWithString:@"axviewcontrollerschema://viewcontroller/table?navigation=0&animated=1&class=TableViewController"]];
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
