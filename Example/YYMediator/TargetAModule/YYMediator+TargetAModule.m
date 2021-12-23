//
//  YYMediator+TargetAModule.m
//  YYMediator_Example
//
//  Created by liuxc on 2021/12/22.
//  Copyright © 2021 liuxc123. All rights reserved.
//

#import "YYMediator+TargetAModule.h"

NSString * const kYYMediatorTargetA = @"A";
NSString * const kYYMediatorActionShowAlert = @"showAlert";

@implementation YYMediator (TargetAModule)

- (void)YYMediator_showAlertWithMessage:(NSString *)message cancelAction:(void(^)(NSDictionary *info))cancelAction confirmAction:(void(^)(NSDictionary *info))confirmAction
{
    NSMutableDictionary *paramsToSend = [[NSMutableDictionary alloc] init];
    if (message) {
        paramsToSend[@"message"] = message;
    }
    if (cancelAction) {
        paramsToSend[@"cancelAction"] = cancelAction;
    }
    if (confirmAction) {
        paramsToSend[@"confirmAction"] = confirmAction;
    }
    [self performTarget:kYYMediatorTargetA
                 action:kYYMediatorActionShowAlert
                 params:paramsToSend
      shouldCacheTarget:NO];
}

- (UIViewController *)YYMediator_TargetAViewController:(NSDictionary *)params {
    return [self performTarget:kYYMediatorTargetA action:@"TargetAViewController" params:params shouldCacheTarget:NO];
}

@end
