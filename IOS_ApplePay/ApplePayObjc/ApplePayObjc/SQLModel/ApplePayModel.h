//
//  ApplePayModel.h
//  WildFireChat
//
//  Created by Hahn on 2020/6/9.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ApplePayModel : NSObject

@property (copy, nonatomic) NSString *orderId;                      // 订单ID
@property (copy, nonatomic) NSString *payData;                      // receiptData

@end

NS_ASSUME_NONNULL_END
