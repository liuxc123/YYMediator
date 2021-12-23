//
//  Target_A.m
//  YYMediator_Example
//
//  Created by liuxc on 2021/12/22.
//  Copyright © 2021 liuxc123. All rights reserved.
//

#import "Target_A.h"
#import "TargetAViewController.h"

typedef void (^YYUrlRouterCallbackBlock)(NSDictionary *info);

@implementation Target_A

- (id)Action_showAlert:(NSDictionary *)params
{
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        YYUrlRouterCallbackBlock callback = params[@"cancelAction"];
        if (callback) {
            callback(@{@"alertAction":action});
        }
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        YYUrlRouterCallbackBlock callback = params[@"confirmAction"];
        if (callback) {
            callback(@{@"alertAction":action});
        }
        void (^completion)(NSDictionary *params) = params[kYYMediatorParamsKeyCompletion];
        if (completion) {
            completion(nil);
        }
    }];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"alert from Module A" message:params[@"message"] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    return nil;
}

- (UIViewController *)Action_TargetAViewController:(NSDictionary *)params
{
    TargetAViewController *vc = [[TargetAViewController alloc] init];
    vc.title = params[@"title"];
    return vc;
}

@end
