//
//  Target_A.h
//  YYMediator_Example
//
//  Created by liuxc on 2021/12/22.
//  Copyright © 2021 liuxc123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Target_A : NSObject

- (id)Action_showAlert:(NSDictionary *)params;

- (UIViewController *)Action_TargetAViewController:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
