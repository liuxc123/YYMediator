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
    
//    UIViewController *vc = [[YYMediator sharedInstance] YYMediator_TargetAViewController:@{ @"title": @"custom title" }];
//    [[YYMediator sharedInstance] pushViewController:vc animated:YES];
    
//    for (int i = 0; i < 10; i++) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((0.5 * i) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (i == 3) {
//                DDViewController2 *vc = [DDViewController2 new];
//                vc.view.backgroundColor = [UIColor yellowColor];
//                [YYMediator.sharedInstance presentViewController:vc animated:YES completion:nil];
//            } if (i % 2) {
//                UIViewController *vc = [UIViewController new];
//                vc.title = [NSString stringWithFormat:@"页面%d", i];
//                vc.view.backgroundColor = [UIColor redColor];
//                [YYMediator.sharedInstance presentViewController:vc animated:YES completion:nil];
//            } else {
//                [YYMediator.sharedInstance YYMediator_showAlertWithMessage:@"message" cancelAction:^(NSDictionary * _Nonnull info) {
//
//                } confirmAction:^(NSDictionary * _Nonnull info) {
//
//                }];
//            }
//        });
//
//    }
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[YYMediator sharedInstance] moveToViewControllerClass:@"DDViewController" completion:^(UIViewController * vc) {
//            NSLog(@"%@", NSStringFromClass([vc class]));
//        }];
//    });
}

@end
