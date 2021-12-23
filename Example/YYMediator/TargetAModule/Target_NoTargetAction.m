//
//  Target_NoTargetAction.m
//  YYMediator_Example
//
//  Created by liuxc on 2021/12/23.
//  Copyright © 2021 liuxc123. All rights reserved.
//

#import "Target_NoTargetAction.h"

@implementation Target_NoTargetAction

- (void)Action_response:(NSDictionary*)params {
    NSLog(@"Notfound action: %@", params);
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        void (^completion)(NSDictionary *params) = params[kYYMediatorParamsKeyCompletion];
        if (completion) {
            completion(nil);
        }
    }];
    
    NSString *message = [NSString stringWithFormat:@"%@\n%@\n%@", params[@"targetString"], params[@"selectorString"], params[@"originParams"]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法执行Target-Action" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:confirmAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)Action_urlResponse:(NSDictionary*)params {
    NSLog(@"Notfound url: %@", params);
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        void (^completion)(NSDictionary *params) = params[kYYMediatorParamsKeyCompletion];
        if (completion) {
            completion(nil);
        }
    }];
    
    NSString *message = [NSString stringWithFormat:@"%@\n%@", params[@"url"], params[@"originParams"]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法执行路由" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:confirmAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end
