//
//  YYMediator.h
//  YYMediator
//
//  Created by liuxc on 2021/12/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kYYMediatorParamsKeySwiftTargetModuleName;
extern NSString * const kYYMediatorParamsKeyCompletion;
extern NSString * const kYYMediatorParamsKeyURL;

@interface YYMediator : NSObject

/// 全局单利
+ (instancetype)sharedInstance;


/// 注册 URLPattern 对应的 Target-Action
/// @param URLPattern 带上 scheme，如 app://beauty/:id
/// @param targetName 模块名
/// @param actionName 方法名
- (void)registerURLPattern:(NSString *)URLPattern target:(NSString *)targetName action:(NSString *)actionName;

/// 打开URL方法
/// @param URL URL地址
- (nullable id)performURL:(nullable NSString *)URL;

/// 打开URL方法
/// @param URL URL地址
/// @param completion URL 处理完成后的 callback，完成的判定跟具体的业务相关
- (nullable id)performURL:(nullable NSString *)URL completion:(void (^ __nullable)(NSDictionary * __nullable))completion;

/// 打开URL方法
/// @param URL URL地址
/// @param extraParams 附加参数
/// @param completion URL 处理完成后的 callback，完成的判定跟具体的业务相关
- (nullable id)performURL:(nullable NSString *)URL withExtraParams:(nullable NSDictionary *)extraParams completion:(void (^ __nullable)(NSDictionary * __nullable))completion;

/// 打开本地组件
/// @param targetName 模块名
/// @param actionName 方法名
/// @param params 参数
/// @param shouldCacheTarget 是否缓存模块
- (nullable id)performTarget:(nullable NSString *)targetName action:(nullable NSString *)actionName params:(nullable NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget;

/// 删除缓存模块
/// @param fullTargetName 模块名字
- (void)releaseCachedTargetWithFullTargetName:(nullable NSString *)fullTargetName;

/// 是否可以打开URL
/// @param URL URL地址
- (BOOL)canOpenURL:(NSString *)URL;

/// 调用此方法来拼接 urlpattern 和 parameters
/// @param pattern url pattern 比如 @"beauty/:id"
/// @param parameters 一个数组，数量要跟 pattern 里的变量一致
- (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters;

@end

NS_ASSUME_NONNULL_END
