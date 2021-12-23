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
    
    // 注册路由
    [YYMediator.sharedInstance registerURLPattern:@"app://showalert/:query" target:@"A" action:@"showAlert"];
    [YYMediator.sharedInstance registerURLPattern:@"app://showalert/controller/:query" target:@"A" action:@"showAlert"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 打开模块
    UIViewController *vc = [[YYMediator sharedInstance] YYMediator_TargetAViewController:@{@"title": @"custom title"}];
    [[YYMediator sharedInstance] pushViewController:vc animated:YES];
    
    // 执行路由
    [YYMediator.sharedInstance performURL:@"app://showalert/1?message=controller" completion:^(NSDictionary * _Nullable params) {
        NSLog(@"万能充");
    }];
    
    // 判断路由是否能打开
    NSLog(@"%@", [[YYMediator sharedInstance] canOpenURL:@"app://showalert/controller/1"] ? @"YES" : @"NO");
    
    // 拼接路由地址
    NSLog(@"%@", [[YYMediator sharedInstance] generateURLWithPattern:@"app://showalert/controller/:id/:detail_id" parameters:@[@1, @2]]);
}

@end
