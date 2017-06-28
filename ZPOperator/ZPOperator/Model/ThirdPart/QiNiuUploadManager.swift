//
//  QiNiuUploadManager.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/27.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation
import Qiniu
import HappyDNS

class QiNiuUploadManager {
//    NSString *token = @"从服务端SDK获取";
//    QNUploadManager *upManager = [[QNUploadManager alloc] init];
//    NSData *data = [@"Hello, World!" dataUsingEncoding : NSUTF8StringEncoding];
//    [upManager putData:data key:@"hello" token:token
//    complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//    NSLog(@"%@", info);
//    NSLog(@"%@", resp);
//    } option:nil];
    
    var qiniuManager : QNUploadManager?
    let isHttps = true
    var completionHandler : QNUpCompletionHandler?
    
    
    init() {

        let autoConfig = QNConfiguration.build { (builder) in
            let httpsZone = QNAutoZone.init(https: self.isHttps, dns: nil)
            var array = Array<Any>()
            array.append(QNResolver.system)
            let dns = QNDnsManager.init(array, networkInfo: QNNetworkInfo.normal())
            
            builder?.setZone(httpsZone)
            var error : Error?
            //builder?.recorder = QNFileRecorder.init(folder: <#T##String!#>)
        }
        
        qiniuManager = QNUploadManager.init(configuration: autoConfig)
        
    }
    
    
    func qiniuUpload(token:String,key:String,data:Any,options:QNUploadOption? = nil,completion:@escaping (()->())) {
        
        //QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:@"text/plain" progressHandler:nil params:@{ @"x:foo":@"fooval" } checkCrc:YES cancellationSignal:nil];
        
        self.qiniuGetToken { (data, msg, isSuccess) in
            if isSuccess {
                qiniuManager?.put(data as! Data, key: key, token: token, complete: {(QNResponseInfo, str, dict) -> () in
                    print(QNResponseInfo)
                    print(str)
                    print(dict)
                    completion()
                }, option: options)
            }else{
                completion()
            }
        }
        
        
    }
    
    func qiniuGetToken(bucket:String = "zpsy",completion:(_ data:Any?,_ msg:String?,_ isSuccess:Bool)->()) {
        JXRequest.request(url: ApiString.getProductTokenUrl.rawValue, param: ["bucket":bucket], success: { (data, msg) in
            //
        }) { (msg, error) in
            //
        }
    }
}
