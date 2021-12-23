//
//  YYMediator+Navigation.m
//  YYMediator
//
//  Created by liuxc on 2021/12/22.
//

#import "YYMediator+Navigation.h"

@implementation YYMediator (Navigation)

- (UIViewController *)topViewController
{
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    return [self topMostViewController:rootController];
}

- (UIViewController *)topMostViewController:(UIViewController *)viewController
{
    // presented view controller
    if (viewController.presentedViewController != nil) {
        UIViewController *presentedViewController = viewController.presentedViewController;
        if (presentedViewController) {
            return [self topMostViewController:presentedViewController];
        }
    }
    
    // UITabBarController
    if ([viewController isKindOfClass: [UITabBarController class]]) {
        UIViewController *selectedViewController = ((UITabBarController *)viewController).selectedViewController;
        if (selectedViewController) {
            return [self topMostViewController:selectedViewController];
        }
    }
    
    // UINavigationController
    if ([viewController isKindOfClass: [UINavigationController class]]) {
        UIViewController *visibleViewController = ((UINavigationController *)viewController).visibleViewController;
        if (visibleViewController) {
            return [self topMostViewController:visibleViewController];
        }
    }
    
    // UIPageController
    if ([viewController isKindOfClass: [UIPageViewController class]]) {
        if (((UIPageViewController *)viewController).viewControllers.count == 1) {
            return [self topMostViewController:((UIPageViewController *)viewController).viewControllers.firstObject];
        }
    }
    
    // child view controller
    for (UIView *subview in viewController.view.subviews) {
        if ([subview.nextResponder isKindOfClass: [UIViewController class]]) {
            UIViewController *childViewController = (UIViewController *)subview.nextResponder;
            return [self topMostViewController:childViewController];
        }
    }
    
    return viewController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UINavigationController *navigationController = [[self topViewController] navigationController];
    
    if (navigationController) {
        [navigationController pushViewController:viewController animated:animated];
    }
}

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UINavigationController *navigationController = [[self topViewController] navigationController];
    
    if (navigationController) {
        return [navigationController popViewControllerAnimated:animated];
    }
    
    return nil;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^ __nullable)(void))completion
{
    UIViewController *viewController = [self topViewController];
    
    if (viewController) {
        [viewController presentViewController:viewControllerToPresent animated:animated completion:completion];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^ __nullable)(void))completion
{
    UIViewController *viewController = [self topViewController];
    
    if (viewController) {
        [viewController dismissViewControllerAnimated:animated completion:completion];
    }
}

- (void)moveToViewController:(UIViewController *)viewController completion:(void (^)(UIViewController *))completion
{
    UIViewController *topViewController = [self topViewController];
    
    if ([topViewController isEqual:viewController]) {
        if (completion) { completion(viewController); }
        return;
    }
    
    UIViewController *parentViewController = topViewController.parentViewController;
    
    if ([parentViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navigationController = (UINavigationController *)parentViewController;
        
        if ([navigationController isEqual:viewController]) {
            if (completion) { completion(navigationController); }
            return;
        }
        
        if ([navigationController.viewControllers.firstObject isEqual:navigationController.visibleViewController]) {
            [navigationController popViewControllerAnimated:NO];
            [self moveToViewController:viewController completion:completion];
            return;
        }
    }
    
    else if ([parentViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)parentViewController;
        
        if ([tabBarController isEqual:viewController]) {
            if (completion) { completion(tabBarController); }
            return;
        }
    }
    
    else if ([parentViewController isKindOfClass:[UIPageViewController class]]) {
        
        UIPageViewController *pageController = (UIPageViewController *)parentViewController;
        
        if ([pageController isEqual:viewController]) {
            if (completion) { completion(pageController); }
            return;
        }
    }
    
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navigationController = (UINavigationController *)topViewController;
        
        if ([navigationController isEqual:viewController]) {
            if (completion) { completion(navigationController); }
            return;
        }
        
        if ([navigationController.viewControllers.firstObject isEqual:navigationController.visibleViewController]) {
            [navigationController popViewControllerAnimated:NO];
            [self moveToViewController:viewController completion:completion];
            return;
        }
    }
    
    else if ([topViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)topViewController;
        
        if ([tabBarController isEqual:viewController]) {
            if (completion) { completion(tabBarController); }
            return;
        }
    }
    
    [topViewController dismissViewControllerAnimated:NO completion:^{
        [[YYMediator sharedInstance] moveToViewController:viewController completion:completion];
    }];
    
}

- (void)moveToViewControllerClass:(NSString *)className completion:(void (^ __nullable)(UIViewController *))completion
{
    UIViewController *topViewController = [self topViewController];
    
    if ([topViewController isKindOfClass:NSClassFromString(className)]) {
        if (completion) { completion(topViewController); }
        return;
    }
    
    UIViewController *parentViewController = topViewController.parentViewController;
    
    if ([parentViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navigationController = (UINavigationController *)parentViewController;
        
        if ([navigationController isKindOfClass:NSClassFromString(className)]) {
            if (completion) { completion(navigationController); }
            return;
        }
        
        if (![navigationController.viewControllers.firstObject isEqual:navigationController.visibleViewController]) {
            [navigationController popViewControllerAnimated:NO];
            [self moveToViewControllerClass:className completion:completion];
            return;
        }
    }
    
    else if ([parentViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)parentViewController;
        
        if ([tabBarController isKindOfClass:NSClassFromString(className)]) {
            if (completion) { completion(tabBarController); }
            return;
        }
    }
    
    else if ([parentViewController isKindOfClass:[UIPageViewController class]]) {
        
        UIPageViewController *pageController = (UIPageViewController *)parentViewController;
        
        if ([pageController isKindOfClass:NSClassFromString(className)]) {
            if (completion) { completion(pageController); }
            return;
        }
    }
    
    if (topViewController.navigationController) {
        
        UINavigationController *navigationController = topViewController.navigationController;
        
        if ([navigationController isKindOfClass:NSClassFromString(className)]) {
            if (completion) { completion(navigationController); }
            return;
        }
        
        if (![navigationController.viewControllers.firstObject isEqual:navigationController.visibleViewController]) {
            [navigationController popViewControllerAnimated:NO];
            [self moveToViewControllerClass:className completion:completion];
            return;
        }
    }
    
    else if (topViewController.tabBarController) {
        
        UITabBarController *tabBarController = (UITabBarController *)topViewController.tabBarController;
        
        if ([tabBarController isKindOfClass:NSClassFromString(className)]) {
            if (completion) { completion(tabBarController); }
            return;
        }
    }
    
    if (topViewController.presentingViewController) {
        [topViewController dismissViewControllerAnimated:NO completion:^{
            [[YYMediator sharedInstance] moveToViewControllerClass:className completion:completion];
        }];
    }
}

@end
