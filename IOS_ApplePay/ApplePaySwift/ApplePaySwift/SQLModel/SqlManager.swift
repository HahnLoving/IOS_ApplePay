//
//  SqlManager.swift
//  ApplePaySwift
//
//  Created by Hahn on 2020/6/10.
//  Copyright © 2020 Hahn. All rights reserved.
//

import UIKit

class SqlManager: NSObject {
    
    // MARK: -单例
    private static var sharedSqlManager: SqlManager = {
        let sqlManager = SqlManager()
        return sqlManager
    }()

    override init() {
        var doc:NSString! = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as NSString
        doc = doc.appendingPathComponent("LDebugTool") as NSString
        
        if !FileManager.default.fileExists(atPath: doc! as String) {
            do {
                try FileManager.default.createDirectory(atPath: doc! as String, withIntermediateDirectories: true, attributes: nil)
            } catch  {
                print(error)
            }
        }
        
        let filePath:NSString! = doc.appendingPathComponent("LDebugTool.db") as NSString
        self.dbQueue = FMDatabaseQueue(path: filePath as String)
        

        let sql:NSString! = self.kCreateStudentModelTableSQL as NSString
        self.dbQueue?.inDatabase { (db) in
            
            let result = db.executeUpdate(sql as String, withArgumentsIn: [])
            if result {
                print("创表成功")
            }else{
                print("创表失败")
            }
        }
        
    }

    class func shared() -> SqlManager {
        return sharedSqlManager
    }
    
    private var dbQueue:FMDatabaseQueue?
    
    /**
     *建表
     如果ApplePayModelTable这个表不存在就创建，表里面的字段有id、orderId、payData，并且orderId和payData不能为null，id为自增的主键
    */
    private let kCreateStudentModelTableSQL:String! = "CREATE TABLE IF NOT EXISTS ApplePayModelTable(id integer primary key autoincrement,orderId text not null,payData text not null);"
    
    // 表名
    private let kApplePayModelTable:String! = "ApplePayModelTable"

    // 字段名
    private let kOrderIdColumn:String! = "orderId"
    private let kPayDataColumn:String! = "payData"
    
    // MARK:- ApplePayModel
    /**
     * 保存数据到SQL
     */
    public func saveApplePayModel(model:ApplePayModel){
        let table:String! = self.kApplePayModelTable
        let order:String! = self.kOrderIdColumn
        let data:String! = self.kPayDataColumn
        
        self.dbQueue?.inDatabase({ (db) in
            do {
                try db.executeUpdate("INSERT INTO \(table!)(\(order!),\(data!)) VALUES (?,?);", values: [model.orderId as Any,model.payData as Any])
            } catch  {
                print(error)
            }
            
        })
    }

    /**
     * 读取全部数据
     */
    public func getAllApplePayModel() -> NSMutableArray{
        let table:String! = self.kApplePayModelTable
        let array:NSMutableArray! = NSMutableArray()
        self.dbQueue?.inDatabase({ (db) in
            do {
                let set:FMResultSet = try db.executeQuery("SELECT * FROM \(table!)", values: nil)
                
                while set.next() {
                    _ = set.int(forColumn: "id")
                    let orderId = set.string(forColumn: "orderId")
                    let payData = set.string(forColumn: "payData")

                    let model = ApplePayModel()
                    model.orderId = orderId
                    model.payData = payData
                    array.add(model)
                    
                }
            } catch  {
                print(error)
            }
            
        })
        return array
    }

    /**
     * 删除指定的数据
     */
    public func removeMotionModel(model:ApplePayModel){
        let table:String! = self.kApplePayModelTable
        let order:String! = self.kOrderIdColumn
        
        self.dbQueue?.inDatabase({ (db) in
            do {
                try db.executeUpdate("DELETE FROM \(table!) WHERE \(order!) = ?", values: [model.orderId as Any])
            } catch  {
                print(error)
            }
            
        })
    }
}
