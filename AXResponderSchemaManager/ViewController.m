//
//  ViewController.m
//  AXViewControllerShema
//
//  Created by devedbox on 2016/10/11.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+Schema.h"
#import "AXResponderSchemaManager.h"

@interface ViewController ()

@end

@implementation ViewController

+ (Class)classForSchemaIdentifier:(NSString *)schemaIdentifier {
    if ([schemaIdentifier  isEqual: @"viewcontroller"]) {
        return self;
    }
    return [super classForSchemaIdentifier:schemaIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [AXResponderSchemaManager registerSchema:@"viewcontroller1" forClass:@"ViewController1"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)viewControllerForSchema {
    return [[self alloc] init];
}

- (IBAction)show:(id)sender {
    [[AXResponderSchemaManager sharedManager] openURL:[NSURL URLWithString:@"axviewcontrollerschema://viewcontroller/viewcontroller1?navigation=1&animated=1&delay=0.5"]];
}
@end
