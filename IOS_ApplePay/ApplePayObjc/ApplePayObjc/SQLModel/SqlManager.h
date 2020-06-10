//
//  SqlManager.h
//  WildFireChat
//
//  Created by Hahn on 2020/6/9.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ApplePayModel;

/// 数据库存储
@interface SqlManager : NSObject

+ (instancetype)sharedManager;

/**
 * 保存数据到SQL
 */
- (void)saveApplePayModel:(ApplePayModel *)model;

/**
 * 读取全部数据
 */
- (NSArray <ApplePayModel *>*)getAllApplePayModel;

/**
 * 删除指定的数据
 */
- (void)removeMotionModel:(ApplePayModel *)model;
@end

NS_ASSUME_NONNULL_END
