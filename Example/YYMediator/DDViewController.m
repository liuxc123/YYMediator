//
//  DDViewController.m
//  YYMediator
//
//  Created by liuxc123 on 12/22/2021.
//  Copyright (c) 2021 liuxc123. All rights reserved.
//

#import "DDViewController.h"

@interface DDViewController2 : UIViewController

@end

@implementation DDViewController2

@end

@interface DDViewController ()

@end

@implementation DDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [YYMediator.sharedInstance registerURLPattern:@"app://showalert/:query" target:@"A" action:@"showAlert"];
    [YYMediator.sharedInstance registerURLPattern:@"app://showalert/controller/:query" target:@"A" action:@"showAlert"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
    [YYMediator.sharedInstance performURL:@"app://showalert/controller/1?message=controller" completion:^(NSDictionary * _Nullable params) {
        NSLog(@"万能充");
    }];
//    NSLog(@"%@", [[YYMediator sharedInstance] canOpenURL:@"app://showalert/controller/1"] ? @"YES" : @"NO");
    NSLog(@"%@", [[YYMediator sharedInstance] generateURLWithPattern:@"app://showalert/controller/:id/:detail_id" parameters:@[@1, @2]]);
}

@end
