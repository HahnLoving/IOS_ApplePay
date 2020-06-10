//
//  ViewController.swift
//  ApplePaySwift
//
//  Created by Hahn on 2020/6/9.
//  Copyright © 2020 Hahn. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {

    var request:SKProductsRequest! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let array = SqlManager.shared().getAllApplePayModel()
        if array.count > 0 {
            for model in array {
                let mo:ApplePayModel = model as! ApplePayModel
                print(mo.orderId as Any)
                /**
                 * 内购校验的Api(你的应用的api)
                 */
            }
        }
    }
    
    deinit {
        print("释放充值")
        if (self.request != nil) {
            self.request.cancel()
        }
        
        NotificationCenter.default.removeObserver(self)
        SKPaymentQueue.default().remove(self)
    }

    // MARK:-购买
    @IBAction func buyBtn(_ sender: Any) {
        SKPaymentQueue.default().add(self)
        if SKPaymentQueue.canMakePayments() {
            // 你的itunesConnect的商品ID
            self.getProductInfow(proId: "")
        }else{
            print("不允许程序内付费")
        }
    }
    
}

extension ViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    // 苹果内购服务，下面的ProductId应该是事先在itunesConnect中添加好的，已存在的付费项目。否则查询会失败。
    func getProductInfow(proId:String){
        let proArr = NSMutableArray()
        proArr.add(proId)
        let set = NSSet(array: proArr as! [Any])
        
        self.request = SKProductsRequest(productIdentifiers: set as! Set<String>)
        self.request.delegate = self
        self.request.start()
        
        print("set")
        print("请求开始请等待...")
    }
    
    // 收到产品返回信息
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("--------------收到产品反馈消息---------------------")
        let product = response.products;
        print("productID:\(response.invalidProductIdentifiers)")
        if product.count == 0 {
            print("查找不到商品信息")
            return
        }
        
        var p = SKProduct()
        for pro in product {
            print(pro.description)
            print(pro.localizedTitle)
            print(pro.localizedDescription)
            print(pro.price)
            print(pro.productIdentifier)
            
            if pro.productIdentifier == pro.productIdentifier {
                p = pro
            }
            
            let payment = SKPayment(product: p)
            print("发送购买请求")
            SKPaymentQueue.default().add(payment)
        }
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("请求失败")
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("支付调用完成")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for tran in transactions {
            switch tran.transactionState {
            case .purchased: // 购买成功，此时要提供给用户相应的内容
                SKPaymentQueue.default().finishTransaction(tran)
                
                let model = ApplePayModel()
                model.orderId = "1234"
                model.payData = "1234"
                SqlManager.shared().saveApplePayModel(model: model)
                
                
                /**
                 * 请求校验API 请求完成删除数据库对应数据
                 */
//                SqlManager.shared().removeMotionModel(model: model)
                
                break
                
            case .purchasing: // 购买中，此时可更新UI来展现购买的过程
                break
            
            case .restored: // 恢复已购产品，此时需要将已经购买的商品恢复给用户
                SKPaymentQueue.default().finishTransaction(tran)
                break
            
            case .failed: // 购买错误，此时要根据错误的代码给用户相应的提示
                SKPaymentQueue.default().finishTransaction(tran)
                print("购买失败")
                break
                
            default:
                break
            }
        }
    }
    

    
}


