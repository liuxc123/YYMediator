//
//  DDAppDelegate.m
//  YYMediator
//
//  Created by liuxc123 on 12/22/2021.
//  Copyright (c) 2021 liuxc123. All rights reserved.
//

#import "DDAppDelegate.h"

@implementation DDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[[YYMediator sharedInstance] performURL:[url absoluteString]] boolValue];
}

@end
