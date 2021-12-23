//
//  YYMediator+TargetAModule.h
//  YYMediator_Example
//
//  Created by liuxc on 2021/12/22.
//  Copyright © 2021 liuxc123. All rights reserved.
//

#import <YYMediator/YYMediator.h>

NS_ASSUME_NONNULL_BEGIN

@interface YYMediator (TargetAModule)

- (void)YYMediator_showAlertWithMessage:(NSString *)message cancelAction:(void(^)(NSDictionary *info))cancelAction confirmAction:(void(^)(NSDictionary *info))confirmAction;

- (UIViewController *)YYMediator_TargetAViewController:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
