//
//  YYMediator+Navigation.h
//  YYMediator
//
//  Created by liuxc on 2021/12/22.
//

#import "YYMediator.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YYMediator (Navigation)

- (nullable UIViewController *)topViewController;

- (nullable UIViewController *)topMostViewController:(nullable UIViewController *)viewController;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated;

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^ __nullable)(void))completion;

- (void)moveToViewController:(UIViewController *)viewController completion:(void (^ __nullable)(UIViewController *))completion;

- (void)moveToViewControllerClass:(NSString *)className completion:(void (^ __nullable)(UIViewController *))completion;

@end

NS_ASSUME_NONNULL_END
