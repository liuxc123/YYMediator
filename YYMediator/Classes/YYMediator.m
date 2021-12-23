//
//  YYMediator.m
//  YYMediator
//
//  Created by liuxc on 2021/12/22.
//

#import "YYMediator.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>

static NSString * const YYMEDIATOR_ROUTER_WILDCARD_CHARACTER = @"~";

NSString * const kYYMediatorParamsKeySwiftTargetModuleName  = @"kYYMediatorParamsKeySwiftTargetModuleName";
NSString * const kYYMediatorParamsKeyURL                    = @"kYYMediatorParamsKeyURL";
NSString * const kYYMediatorParamsKeyCompletion             = @"kYYMediatorParamsKeyCompletion";

@interface YYMediator ()

@property (nonatomic, strong) NSMutableDictionary *cachedTarget;
@property (nonatomic, strong) NSMutableDictionary *cachedRoute;

@end

@implementation YYMediator

#pragma mark - public methods

+ (instancetype)sharedInstance
{
    static YYMediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[YYMediator alloc] init];
        [mediator cachedTarget];    // 同时把cachedTarget初始化，避免多线程重复初始化
        [mediator cachedRoute];     // 同时把cachedRoute初始化，避免多线程重复初始化
    });
    return mediator;
}

- (void)registerURLPattern:(NSString *)URLPattern target:(NSString *)targetName action:(NSString *)actionName
{
    [self addURLPattern:URLPattern target:targetName action:actionName];
}

- (id)performURL:(NSString *)URL
{
    return [self performURL:URL withExtraParams:nil completion:nil];
}

- (id)performURL:(NSString *)URL completion:(void (^)(NSDictionary * _Nullable))completion
{
    return [self performURL:URL withExtraParams:nil completion:completion];
}

- (id)performURL:(NSString *)URL withExtraParams:(NSDictionary *)extraParams completion:(void (^)(NSDictionary * _Nullable))completion
{
    URL = [URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableDictionary *parameters = [self extractParametersFromURL:URL];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            parameters[key] = [obj stringByRemovingPercentEncoding];
        }
    }];
    
    if (parameters) {
        NSDictionary *handler = parameters[@"handler"];
        if (extraParams) {
            [extraParams enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
                parameters[key] = obj;
            }];
        }
        if (completion) {
            parameters[kYYMediatorParamsKeyCompletion] = completion;
        }
        if (handler) {
            [parameters removeObjectForKey:@"handler"];
            NSString *targetName = handler[@"target"];
            NSString *actionName = handler[@"action"];
            return [self performTarget:targetName action:actionName params:parameters shouldCacheTarget:NO];
        }
    }
    
    [self NoTargetActionResponseWithURL:URL originParams:parameters];
    return nil;
}

- (BOOL)canOpenURL:(NSString *)URL
{
    URL = [URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableDictionary *parameters = [self extractParametersFromURL:URL];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            parameters[key] = [obj stringByRemovingPercentEncoding];
        }
    }];
    
    if (parameters) {
        NSDictionary *handler = parameters[@"handler"];
        if (handler) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters
{
    NSInteger startIndexOfColon = 0;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSInteger parameterIndex = 0;
    
    for (int i = 0; i < pattern.length; i++) {
        NSString *character = [NSString stringWithFormat:@"%c", [pattern characterAtIndex:i]];
        if ([character isEqualToString:@":"]) {
            startIndexOfColon = i;
        }
        if (([@[@"/", @"?", @"&"] containsObject:character] || (i == pattern.length - 1 && startIndexOfColon) ) && startIndexOfColon) {
            if (i > (startIndexOfColon + 1)) {
                [items addObject:[NSString stringWithFormat:@"%@%@", [pattern substringWithRange:NSMakeRange(0, startIndexOfColon)], parameters[parameterIndex++]]];
                pattern = [pattern substringFromIndex:i];
                i = 0;
            }
            startIndexOfColon = 0;
        }
    }
    
    return [items componentsJoinedByString:@""];
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget
{
    if (targetName == nil || actionName == nil) {
        return nil;
    }
    
    NSString *swiftModuleName = params[kYYMediatorParamsKeySwiftTargetModuleName];
    
    // generate target
    NSString *targetClassString = nil;
    if (swiftModuleName.length > 0) {
        targetClassString = [NSString stringWithFormat:@"%@.Target_%@", swiftModuleName, targetName];
    } else {
        targetClassString = [NSString stringWithFormat:@"Target_%@", targetName];
    }
    NSObject *target = [self safeFetchCachedTarget:targetClassString];
    if (target == nil) {
        Class targetClass = NSClassFromString(targetClassString);
        target = [[targetClass alloc] init];
    }

    // generate action
    NSString *actionString = [NSString stringWithFormat:@"Action_%@:", actionName];
    SEL action = NSSelectorFromString(actionString);
    
    if (target == nil) {
        // 这里是处理无响应请求的地方之一，这个demo做得比较简单，如果没有可以响应的target，就直接return了。实际开发过程中是可以事先给一个固定的target专门用于在这个时候顶上，然后处理这种请求的
        [self NoTargetActionResponseWithTargetString:targetClassString selectorString:actionString originParams:params];
        return nil;
    }
    
    if (shouldCacheTarget) {
        [self safeSetCachedTarget:target key:targetClassString];
    }

    if ([target respondsToSelector:action]) {
        return [self safePerformAction:action target:target params:params];
    } else {
        // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理
        SEL action = NSSelectorFromString(@"notFound:");
        if ([target respondsToSelector:action]) {
            return [self safePerformAction:action target:target params:params];
        } else {
            // 这里也是处理无响应请求的地方，在notFound都没有的时候，这个demo是直接return了。实际开发过程中，可以用前面提到的固定的target顶上的。
            [self NoTargetActionResponseWithTargetString:targetClassString selectorString:actionString originParams:params];
            @synchronized (self) {
                [self.cachedTarget removeObjectForKey:targetClassString];
            }
            return nil;
        }
    }
}

- (void)releaseCachedTargetWithFullTargetName:(NSString *)fullTargetName
{
    /*
     fullTargetName在oc环境下，就是Target_XXXX。要带上Target_前缀。在swift环境下，就是XXXModule.Target_YYY。不光要带上Target_前缀，还要带上模块名。
     */
    if (fullTargetName == nil) {
        return;
    }
    @synchronized (self) {
        [self.cachedTarget removeObjectForKey:fullTargetName];
    }
}

#pragma mark - private methods

- (void)NoTargetActionResponseWithURL:(NSString *)url originParams:(NSDictionary *)originParams
{
    SEL action = NSSelectorFromString(@"Action_urlResponse:");
    NSObject *target = [[NSClassFromString(@"Target_NoTargetAction") alloc] init];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"originParams"] = originParams;
    params[@"url"] = url;

    [self safePerformAction:action target:target params:params];
}

- (void)NoTargetActionResponseWithTargetString:(NSString *)targetString selectorString:(NSString *)selectorString originParams:(NSDictionary *)originParams
{
    SEL action = NSSelectorFromString(@"Action_response:");
    NSObject *target = [[NSClassFromString(@"Target_NoTargetAction") alloc] init];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"originParams"] = originParams;
    params[@"targetString"] = targetString;
    params[@"selectorString"] = selectorString;
    
    [self safePerformAction:action target:target params:params];
}

- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params
{
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        return nil;
    }
    const char* retType = [methodSig methodReturnType];

    if (strcmp(retType, @encode(void)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    }

    if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(BOOL)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(CGFloat)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

- (NSMutableDictionary *)extractParametersFromURL:(NSString *)url
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[kYYMediatorParamsKeyURL] = url;
    
    NSMutableDictionary* subRoutes = self.cachedRoute;
    NSArray* pathComponents = [self pathComponentsFromURL:url];
    
    // borrowed from HHRouter(https://github.com/Huohua/HHRouter)
    for (NSString* pathComponent in pathComponents) {
        BOOL found = NO;
        
        // 对 key 进行排序，这样可以把 ~ 放到最后
        NSArray *subRoutesKeys =[subRoutes.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        
        for (NSString* key in subRoutesKeys) {
            if ([key isEqualToString:pathComponent] || [key isEqualToString:YYMEDIATOR_ROUTER_WILDCARD_CHARACTER]) {
                found = YES;
                subRoutes = subRoutes[key];
                break;
            } else if ([key hasPrefix:@":"]) {
                found = YES;
                subRoutes = subRoutes[key];
                parameters[[key substringFromIndex:1]] = pathComponent;
                break;
            }
        }
        // 如果没有找到该 pathComponent 对应的 handler，则以上一层的 handler 作为 fallback
        if (!found && !subRoutes[@"_"]) {
            return nil;
        }
    }
    
    // Extract Params From Query.
    NSArray* pathInfo = [url componentsSeparatedByString:@"?"];
    if (pathInfo.count > 1) {
        NSString* parametersString = [pathInfo objectAtIndex:1];
        NSArray* paramStringArr = [parametersString componentsSeparatedByString:@"&"];
        for (NSString* paramString in paramStringArr) {
            NSArray* paramArr = [paramString componentsSeparatedByString:@"="];
            if (paramArr.count > 1) {
                NSString* key = [paramArr objectAtIndex:0];
                NSString* value = [paramArr objectAtIndex:1];
                parameters[key] = value;
            }
        }
    }
    
    if (subRoutes[@"_"]) {
        parameters[@"handler"] = [subRoutes[@"_"] copy];
    }
    
    return parameters;
}

- (void)addURLPattern:(NSString *)URLPattern target:(NSString *)targetName action:(NSString *)actionName
{
    NSArray *pathComponents = [self pathComponentsFromURL:URLPattern];
    
    NSInteger index = 0;
    NSMutableDictionary* subRoutes = self.cachedRoute;
    
    while (index < pathComponents.count) {
        NSString* pathComponent = pathComponents[index];
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[pathComponent];
        index++;
    }
    
    subRoutes[@"_"] = @{@"target": targetName, @"action": actionName};
    @synchronized(self) {
        
    }
}

- (NSArray*)pathComponentsFromURL:(NSString*)URL
{
    NSMutableArray *pathComponents = [NSMutableArray array];
    if ([URL rangeOfString:@"://"].location != NSNotFound) {
        NSArray *pathSegments = [URL componentsSeparatedByString:@"://"];
        // 如果 URL 包含协议，那么把协议作为第一个元素放进去
        [pathComponents addObject:pathSegments[0]];
        
        // 如果只有协议，那么放一个占位符
        if ((pathSegments.count == 2 && ((NSString *)pathSegments[1]).length) || pathSegments.count < 2) {
            [pathComponents addObject:YYMEDIATOR_ROUTER_WILDCARD_CHARACTER];
        }
        
        URL = [URL substringFromIndex:[URL rangeOfString:@"://"].location + 3];
    }
    
    for (NSString *pathComponent in [[NSURL URLWithString:URL] pathComponents]) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
        [pathComponents addObject:pathComponent];
    }
    return [pathComponents copy];
}

#pragma mark - getters and setters

- (NSMutableDictionary *)cachedTarget
{
    if (_cachedTarget == nil) {
        _cachedTarget = [[NSMutableDictionary alloc] init];
    }
    return _cachedTarget;
}

- (NSObject *)safeFetchCachedTarget:(NSString *)key {
    @synchronized (self) {
        return self.cachedTarget[key];
    }
}

- (void)safeSetCachedTarget:(NSObject *)target key:(NSString *)key {
    @synchronized (self) {
        self.cachedTarget[key] = target;
    }
}

- (NSMutableDictionary *)cachedRoute
{
    if (_cachedRoute == nil) {
        _cachedRoute = [[NSMutableDictionary alloc] init];
    }
    return _cachedRoute;
}

@end
