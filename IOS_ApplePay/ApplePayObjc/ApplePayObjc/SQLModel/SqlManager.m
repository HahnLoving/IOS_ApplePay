//
//  SqlManager.m
//  WildFireChat
//
//  Created by Hahn on 2020/6/9.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "SqlManager.h"
#import "ApplePayModel.h"
#import "FMDB.h"
#import "MJExtension.h"

static SqlManager *_instance = nil;

// Table SQL
/**
 *建表
 如果ApplePayModelTable这个表不存在就创建，表里面的字段有id、orderId、payData，并且orderId和payData不能为null，id为自增的主键
*/
static NSString *const kCreateStudentModelTableSQL = @"CREATE TABLE IF NOT EXISTS ApplePayModelTable(id integer primary key autoincrement,orderId text not null,payData text not null);";

// 表名
static NSString *const kApplePayModelTable = @"ApplePayModelTable";

// 字段名
static NSString *const kOrderIdColumn = @"orderId";
static NSString *const kPayDataColumn = @"payData";


@interface SqlManager()

@property (strong , nonatomic) FMDatabaseQueue * dbQueue;

@end

@implementation SqlManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SqlManager alloc] init];
        [_instance initial];
    });
    return _instance;
}

#pragma mark - ApplePayModel

- (void)saveApplePayModel:(ApplePayModel *)model{

    __block BOOL ret = NO;
    
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSError *error;
        ret = [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@(%@,%@) VALUES (?,?);",kApplePayModelTable,kOrderIdColumn,kPayDataColumn] values:@[model.orderId, model.payData] error:&error];
        if (!ret) {
            NSLog(@"SQL保存失败 = %@",error.localizedDescription);
        } else {
            NSLog(@"SQL保存成功");
        }
    }];

}

- (NSArray<ApplePayModel *> *)getAllApplePayModel{
    __block NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",kApplePayModelTable]];
        while ([set next]) {
            
            int id = [set intForColumn:@"id"];
            NSString *orderId = [set stringForColumn:kOrderIdColumn];
            NSString *payData = [set stringForColumn:kPayDataColumn];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:id], @"id", orderId, @"orderId", payData, @"payData", nil];
            ApplePayModel *model = [ApplePayModel mj_objectWithKeyValues:dict];
            if (model) {
                [modelArray insertObject:model atIndex:0];
            }
        }
    }];
    
    return modelArray.copy;
}


- (void)removeMotionModel:(ApplePayModel *)model {
    __block BOOL ret = NO;
    
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSError *error;
        ret = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",kApplePayModelTable,kOrderIdColumn] values:@[model.orderId] error:&error];
        if (!ret) {
            NSLog(@"删除SQL失败 = %@",error);
        }
    }];

}

#pragma mark - Primary

- (void)initial {
    __unused BOOL result = [self initDatabase];
    NSAssert(result, @"Init Database fail");
}

/**
 * 初始化SQL 保存地址的操作
 */
- (BOOL)initDatabase {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    doc = [doc stringByAppendingPathComponent:@"LDebugTool"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:doc]) {
        NSError *error;
        [[NSFileManager  defaultManager] createDirectoryAtPath:doc withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"CSStorageManager create folder fail, error = %@",error.description);
        }
        NSAssert(!error, error.description);
    }
    NSString *filePath = [doc stringByAppendingPathComponent:@"LDebugTool.db"];
    
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    
    __block BOOL ret1 = NO;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        // ObjectData use to convert to Student, launchDate use as identity
        ret1 = [db executeUpdate:kCreateStudentModelTableSQL];
        if (!ret1) {
            NSLog(@"LLStorageManager create StudentModelTable fail");
        }
    }];
    return ret1;
}

@end
