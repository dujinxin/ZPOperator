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
    
    var qiniuManager : QNUploadManager?
    let isHttps = true
    var completionHandler : QNUpCompletionHandler?
    
    var successBlock : ((_ urlStr:String?, _ isSuccess:Bool)->())?
    var failureBlock : (()->())?
    
    
    
    
    init() {
        
        let autoConfig = QNConfiguration.build { (builder) in
            
            var array = Array<Any>()
            array.append(QNResolver.system)
            let dns = QNDnsManager.init(array, networkInfo: QNNetworkInfo.normal())
            let httpsZone = QNAutoZone.init(https: self.isHttps, dns: dns)
            
            builder?.setZone(httpsZone)
            //var error : Error?
            //builder?.recorder = QNFileRecorder.init(folder: <#T##String!#>)
        }
        
        qiniuManager = QNUploadManager.init(configuration: autoConfig)
        
    }
    
    
    func qiniuUpload(datas:Array<Any>?,completion:@escaping ((_ urls:Array<String>?)->())) {
        
        //QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:@"text/plain" progressHandler:nil params:@{ @"x:foo":@"fooval" } checkCrc:YES cancellationSignal:nil];
        
        guard let datas = datas else {
            completion(nil)
            return
        }
        
        var urlArray = Array<String>()
        var index = 0
        let process = 1 / datas.count
        var totalProcess = 0
        
        
        self.failureBlock = { ()->() in
             completion(nil)
        }
        self.successBlock = { (urlStr,isSuc)->() in
            if isSuc {
                if let url = urlStr {
                    urlArray.append(url)
                }
                totalProcess += process
                
                index += 1
                if urlArray.count == datas.count {
                    completion(urlArray)
                    return
                }else{
                    print("当前上传\(index)")
                    if index < datas.count {
                        self.qiniuUpload(data: datas[index], completion1: self.successBlock!)
                    }
                }
            }else{
                completion(nil)
                return
            }
            
        }
        self.qiniuUpload(data: datas[0], completion1: self.successBlock!)
        

//        let group = DispatchGroup()
//        let queue = DispatchQueue(label: "label")
//        
//        for data in datas {
//            DispatchQueue.global().async(group: group, qos: .default, flags: .detached) {
//                print("download1 \(Thread.current)")
//                self.qiniuUpload(data: data, completion1: { (url,isSuc) in
//                    if url != nil {
//                        urlArray.append(url!)
//                    }
//                })
//            }
//        }
//        
////        //DispatchQueue.global().async(group: <#T##DispatchGroup#>, execute: <#T##DispatchWorkItem#>)
////        DispatchQueue.global().async(group: group, qos: .default, flags: .detached) {
////            print("download1 \(Thread.current)")
////        }
////        DispatchQueue.global().async(group: group, qos: .default, flags: .detached) {
////            Thread.sleep(forTimeInterval: 1)
////            print("download2 \(Thread.current)")
////        }
//        group.notify(queue: queue) {
//            print("done \(Thread.current)")
//            completion(urlArray)
//        }
        
        
    }
    func qiniuUpload(data:Any?,options:QNUploadOption? = nil,completion1:@escaping ((_ urlStr:String?,_ isSuc:Bool)->())) {
    
        self.qiniuGetToken { (result, msg, isSuccess) in
            
            if let mdict = result as? Dictionary<String,Any>,
                let token = mdict["token"] as? String{
                
                let timeStr = self.getTimeStr()
                let randomStr = self.randomStr(length:8)
                let fileName = String.init(format: "%@_%@.png", timeStr,randomStr)
                
                self.qiniuManager?.put(data as! Data, key: fileName, token: token, complete: { (QNResponseInfo, str, dict) in
                    //
                    //print(QNResponseInfo)
                    //print(str)
                    //print(dict)
                    guard let dict = dict ,
                        let info = QNResponseInfo,
                        info.statusCode == 200 else{
                            completion1(nil,false)
                            return
                    }
                    let url = String.init(format: "%@/%@", mdict["domain"] as! CVarArg,dict["key"] as! CVarArg)
                    completion1(url,true)
                    
                }, option: options)
            }else{
                completion1(nil,false)
            }
        }
    }

    func qiniuGetToken(bucket:String = "zpsy",completion:@escaping (_ data:Any?,_ msg:String?,_ isSuccess:Bool)->()) {
        JXRequest.request( url: ApiString.uploadGetToken.rawValue, param: nil, success: { (data, msg) in
            completion(data,msg,true)
        }) { (msg, error) in
            completion(nil,msg,false)
        }
    }
    func getTimeStr() -> String {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: Date.init())
        return dateStr
    }
    func randomStr(length:Int) -> String {
        //let defaultStr = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomStr = String.init()
//        for i in 0..<length {
//            //let c = defaultStr.characters
//            let c = defaultStr.characters.
//            
//            let c = defaultStr.appendingFormat("%c", defaultStr.characters[Int32(length)])
//            let c = defaultStr.characters[]
//            randomStr.append(c)
//        }
        
        for _ in 0..<length {
            let randomNumber = arc4random_uniform(26) + 97
            let randomChar = Character(UnicodeScalar(randomNumber)!)
            randomStr.append(randomChar)
        }
        
        return randomStr
    }
}


//if isSuccess {
//    if let mdict = result as? Dictionary<String,Any>,
//        let token = mdict["token"] as? String{
//        
//        let timeStr = self.getTimeStr()
//        let randomStr = self.randomStr(length:8)
//        let fileName = String.init(format: "%@_%@.png", timeStr,randomStr)
//        self.qiniuManager?.put(data as! Data, key: fileName, token: token, complete: { (QNResponseInfo, str, dict) in
//            //
//            print(QNResponseInfo)
//            print(str)
//            print(dict)
//            guard let dict = dict ,
//                let info = QNResponseInfo,
//                info.statusCode == 200 else{
//                    completion(nil)
//                    return
//            }
//            let url = String.init(format: "%@/%@", mdict["domain"] as! CVarArg,dict["key"] as! CVarArg)
//            completion(url)
//        }, option: options)
//        
//    }
//    
//}else{
//    completion(nil)
//}



//self.qiniuGetToken { (result, msg, isSuccess) in
//    if isSuccess {
//        
//        //                let operationQueue = OperationQueue.init()
//        //                var operation : Operation?
//        //                for i in 0..<datas.count {
//        //
//        //                    let myOperation = BlockOperation { () -> Void in
//        //                        //1、请求操作
//        //                        self.qiniuUpload(tokenResult: result, data: datas[i], completion1: { (url) in
//        //                            if url != nil {
//        //                                urlArray.append(url!)
//        //                            }
//        //
//        //                        })
//        //                    }
//        //
//        //                    //myOperation2.completionBlock = {
//        //                    //调用完成之后调用该闭包
//        //
//        //                    //操作1依赖于操作2, 等于操作2完成之后操作1才开始
//        //                    if let oper = operation {
//        //                        myOperation.addDependency(oper)
//        //                    }
//        //                    operation = myOperation
//        //
//        //                    operationQueue.addOperation(myOperation)
//        //
//        //
//        ////                    DispatchQueue.global().async(group: group, qos: .default, flags: [], execute: {
//        ////                        self.qiniuUpload(tokenResult: result, data: datas[i], completion: { (url) in
//        ////                            if url != nil {
//        ////                                urlArray.append(url!)
//        ////                            }
//        ////
//        ////                        })
//        ////                    })
//        //
//        //                }
//        //
//        //
//        //
//        //                let myOperation = BlockOperation { () -> Void in
//        //                    completion(urlArray)
//        //                }
//        //                if let oper = operation {
//        //                    myOperation.addDependency(oper)
//        //                }
//        //                operationQueue.addOperation(myOperation)
//        
//        
//        //                let group = DispatchGroup()
//        //
//        //                let queue = DispatchQueue.init(label: "queue")
//        //                queue.async {
//        //                    completion(urlArray)
//        //                }
//        //                //let queue = DispatchQueue.init(label: "queue", qos: .default, attributes: .concurrent, autoreleaseFrequency: <#T##DispatchQueue.AutoreleaseFrequency#>, target: <#T##DispatchQueue?#>)
//        //                group.enter()
//        //                for i in 0..<datas.count {
//        //
//        ////                    self.qiniuUpload(tokenResult: result, data: datas[i], completion: { (url) in
//        ////                        if url != nil {
//        ////                            urlArray.append(url!)
//        ////                        }
//        ////
//        ////                    })
//        //
//        //                    DispatchQueue.global().async(group: group, qos: .default, flags: [], execute: {
//        //                        self.qiniuUpload(tokenResult: result, data: datas[i], completion: { (url) in
//        //                            if url != nil {
//        //                                urlArray.append(url!)
//        //                            }
//        //                            
//        //                        })
//        //                    })
//        //                    
//        //                }
//        //
//        //                group.leave()
//        //                group.notify(queue: queue, execute: { 
//        //                    //
//        //                })
//        
//        
//    }else{
//        completion(nil)
//    }
//}
