//
//  ViewController.m
//  LTYNavigationDropdownMenu
//
//  Created by 刘天宇 on 2018/10/16.
//  Copyright © 2018年 lty. All rights reserved.
//

#import "ViewController.h"
#import "LTYNavigationDropdownMenu.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    LTYNavigationDropdownMenu *dropdownMenu = [[LTYNavigationDropdownMenu alloc] initWithNavigationController:self.navigationController];
    self.navigationItem.titleView = dropdownMenu;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
