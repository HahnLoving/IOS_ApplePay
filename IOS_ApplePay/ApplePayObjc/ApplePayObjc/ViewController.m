//
//  ViewController.m
//  ApplePayObjc
//
//  Created by Hahn on 2020/6/9.
//  Copyright © 2020 Hahn. All rights reserved.
//

#import "ViewController.h"
#import "SqlManager.h"
#import "ApplePayModel.h"

#import <StoreKit/StoreKit.h>

@interface ViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property (nonatomic, strong) SKProductsRequest * request;
@end

@implementation ViewController

- (void)dealloc {

    NSLog(@"释放充值");
    if (self.request)
    {
        [self.request cancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray *array = [[SqlManager sharedManager] getAllApplePayModel];
    NSLog(@"数据库里面的数据 = %@",array);
    if (array.count > 0) {
        for (ApplePayModel *model in array) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
            [dict setObject:model.payData forKey:@"receiptData"];
            /**
             * 内购校验的Api(你的应用的api)
             */
        }
    }
}

# pragma mark 购买
- (IBAction)buyBtn:(id)sender {
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    if([SKPaymentQueue canMakePayments]){
        // 你的itunesConnect的商品ID
        [self getProductInfowithprotectId:@""];
    }else{
        NSLog(@"不允许程序内付费");
    }
    

}


#pragma mark -- 苹果内购服务，下面的ProductId应该是事先在itunesConnect中添加好的，已存在的付费项目。否则查询会失败。
- (void)getProductInfowithprotectId:(NSString *)proId
{
    NSMutableArray *proArr = [NSMutableArray new];
    [proArr addObject:proId];
    NSSet * set = [NSSet setWithArray:proArr];
    
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    self.request.delegate = self;
    [self.request start];
    
    NSLog(@"%@",set);
    NSLog(@"请求开始请等待...");
}




//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"--------------收到产品反馈消息---------------------");
    
    NSArray *product = response.products;
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    if(product.count==0){
        NSLog(@"查找不到商品信息");
        return;
    }

    SKProduct *p = nil;
    for(SKProduct *pro in product) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        if([pro.productIdentifier isEqualToString: [pro productIdentifier]]){
            p = pro;
        }
    }
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    NSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"支付失败");
}

- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"支付调用完成");
}

//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    for(SKPaymentTransaction *tran in transaction){

        switch(tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{ // 购买成功，此时要提供给用户相应的内容

                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                
                NSLog(@"购买成功 = %@", tran);
                
                NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
                NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
                NSString *receiptString = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                
                // 保存订单信息到数据库
                ApplePayModel *model = [ApplePayModel new];
                // 这里把订单ID写死了
                model.orderId = @"12345";
                model.payData = receiptString;
                
                [[SqlManager sharedManager] saveApplePayModel:model];

                    
                /**
                 * 请求校验API 请求完成删除数据库对应数据
                 */
//              [[SqlManager sharedManager] removeMotionModel:model];

                
                
                
            }
                break;
            case SKPaymentTransactionStatePurchasing: // 购买中，此时可更新UI来展现购买的过程
                break;
            case SKPaymentTransactionStateRestored:{ //恢复已购产品，此时需要将已经购买的商品恢复给用户
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                
            }
                break;
            case SKPaymentTransactionStateFailed:{ // 购买错误，此时要根据错误的代码给用户相应的提示
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                NSLog(@"购买失败");
            }
                break;
            default:
                break;
        }
    }
}

@end
