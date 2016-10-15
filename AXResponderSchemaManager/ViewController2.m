//
//  ViewController2.m
//  AXViewControllerShema
//
//  Created by devedbox on 2016/10/11.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "ViewController2.h"
#import "AXResponderSchemaManager.h"
#import "UIViewController+Schema.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)viewControllerForSchemaWithParams:(NSDictionary **)params {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"kViewController2Identifier"];
}

- (IBAction)showViewController1:(id)sender {
    [kAXResponderSchemaManager openURL:[NSURL URLWithString:@"axviewcontrollerschema://viewcontroller/viewcontroller1?navigation=0&animated=1"]];
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
