//
//  TraceSRecordController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/27.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class TraceSRecordController: UITableViewController {

    
    @IBOutlet weak var operatorContentView: UITableViewCell!
    @IBOutlet weak var traceProcessContentView: UITableViewCell!
    @IBOutlet weak var addressContentView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    var traceSource : TraceSource?
    var processId : NSNumber?
    var addressStr : String?
    var isProcessAlert = true
    
    
    
    var vm = TraceSRecordVM()
    var jxAlertView : JXAlertView?
    var uploadManager = QiNiuUploadManager()
    
    var processArray = Array<String>()
    var addressArray = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.jxAlertView = JXAlertView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
        
        self.jxAlertView?.position = .bottom
        self.jxAlertView?.isSetCancelView = true
        self.jxAlertView?.delegate = self


        operatorContentView.textLabel?.text = self.traceSource?.traceBatchName
        operatorContentView.detailTextLabel?.text = "操作人：" + LoginVM.loginVMManager.userModel.userName!
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationStatus(notify:)), name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: nil)
        
        
        if let goodsId = traceSource?.goodsId,
           let traceBatchId = traceSource?.traceBatchId{
            self.vm.loadProgress(goodsId: goodsId, traceBatchId: traceBatchId) { (data, msg, isSuccess) in
                if isSuccess{
                    //格式化数组
                    self.addressArray.append(self.vm.traceSourceProgress.stationLocation!)
                    for model in self.vm.traceSourceProgress.traceProcesses{
                        self.processArray.append(model.name!)
                    }
                }
                
                //开启定位
                JXLocationManager.manager.startUpdateLocation()
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: nil)
    }
    
    @IBAction func submit(_ sender: UIButton) {
        //self.vm.saveTraceSourceRecord(id: self.traceSource?.goodsId, traceTemplateBatchId: self.traceSource?.traceBatchId, traceProcessId: self.traceSource., location: <#T##String#>, file: <#T##String?#>, contents: <#T##String?#>, completion: <#T##((Any?, String, Bool) -> ())##((Any?, String, Bool) -> ())##(Any?, String, Bool) -> ()#>)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 10
        }else if section == 2 {
            return 64
        }else{
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 1 && indexPath.row == 2 {
//            return 180
//        }else{
//            return 44
//        }
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                isProcessAlert = true
                self.jxAlertView?.actions = processArray
                self.jxAlertView?.show()
            }else if indexPath.row == 1{
                isProcessAlert = false
                self.jxAlertView?.actions = addressArray
                self.jxAlertView?.show()
                
            }else{
                self.uploadManager.qiniuUpload(token: "", key: "", data: "", completion: {()->() in
                    //
                })
            }
        }
    }
}
extension TraceSRecordController : JXAlertViewDelegate{
    func jxAlertView(_ alertView: JXAlertView, clickButtonAtIndex index: Int) {
        if isProcessAlert {
            self.traceProcessContentView.detailTextLabel?.text = self.vm.traceSourceProgress.traceProcesses[index].name
            self.processId = self.vm.traceSourceProgress.traceProcesses[index].id
        }else{
            //self.addressContentView.detain
        }
        
    }
}
extension TraceSRecordController {
    func locationStatus(notify:Notification) {
        print(notify)
        
        guard let isSuccess = notify.object as? Bool else {
            return
        }
        if isSuccess {
            self.addressArray.append(JXLocationManager.manager.address)
        }
        
    }
}
