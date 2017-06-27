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
    var vm = TraceSRecordVM()
    var jxAlertView : JXAlertView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        operatorContentView.textLabel?.text = self.traceSource?.traceBatchName
        operatorContentView.detailTextLabel?.text = "操作人：" + LoginVM.loginVMManager.userModel.userName!
        
        if let goodsId = traceSource?.goodsId {
            self.vm.loadProgress(goodsId: goodsId) { (data, msg, isSuccess) in
                self.jxAlertView = JXAlertView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
                for model in self.vm.traceSourceProgress.traceProcesses{
                    self.jxAlertView?.actions.append(model.name!)
                }
                self.jxAlertView?.isSetCancelView = true
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                self.jxAlertView?.show()
            }else if indexPath.row == 2{
                
            }
        }
    }
}
