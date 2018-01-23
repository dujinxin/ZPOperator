//
//  TagViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/20.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

enum TagSearchStyle {
    case vervel //脚环
    case label  //标签
}

class TagViewController: BaseViewController {

    var vm = TraceSourceDetailVM()
    var style : TagSearchStyle = .label
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.searchButton.layer.cornerRadius = 5
        self.searchButton.backgroundColor = JXGrayColor
        self.searchButton.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(notify:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        if self.style == .label {
            self.title = "标签查询"
            self.searchTextField.placeholder = "请输入12位纯数字编码"
        }else {
            self.title = "脚环信息查询"
            self.searchTextField.placeholder = "请输入8位纯数字编码"
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UITextFieldTextDidChange, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func search(_ sender: UIButton) {
        
        if self.style == .label {
            self.labelSearch()
        } else {
            self.vervelSearch()
        }
    }
    func labelSearch() {
        guard let text = searchTextField.text else {
            return
        }
        if text.count != 12 {
            ViewManager.showNotice(notice: "请输入正确的12位标签编码")
            return
        }
        if !String.validateCode(code: text) {
            ViewManager.showNotice(notice: "请输入12位纯数字标签编码")
            return
        }
        
        self.showMBProgressHUD()
        self.vm.traceSourceTag(page:1,code: text) { (data, msg, isSuccess) in
            self.hideMBProgressHUD()
            if isSuccess{
                let status = self.vm.traceSourceTag.status
                switch  status{
                case 1://正常
                    self.performSegue(withIdentifier: "TraceSourceTag", sender: self.vm.traceSourceTag)
                case 3://未绑定
                    let alert = UIAlertView.init(title: "标签已被停用", message: msg, delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                default:
                    ViewManager.showNotice(notice: msg)
                    break
                }
                
            }else{
                ViewManager.showNotice(notice: msg)
            }
        }
    }
    func vervelSearch() {
        guard let text = searchTextField.text else {
            return
        }
        if text.count != 8 {
            ViewManager.showNotice(notice: "请输入正确的8位标签编码")
            return
        }
        if !String.validateCode(code: text) {
            ViewManager.showNotice(notice: "请输入8位纯数字标签编码")
            return
        }
        
        self.showMBProgressHUD()
        self.vm.traceSourceTag(page:1,code: text) { (data, msg, isSuccess) in
            self.hideMBProgressHUD()
            if isSuccess{
                let status = self.vm.traceSourceTag.status
                switch  status{
                case 1://正常
                    self.performSegue(withIdentifier: "TraceSourceTag", sender: self.vm.traceSourceTag)
                case 3://未绑定
                    let alert = UIAlertView.init(title: "标签已被停用", message: msg, delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                default:
                    ViewManager.showNotice(notice: msg)
                    break
                }
                
            }else{
                ViewManager.showNotice(notice: msg)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TraceSourceTag" {
            let vc = segue.destination as! TagResultController
            if let str = searchTextField.text {
                vc.detailVM.traceSourceTag = self.vm.traceSourceTag
                vc.detailVM.dataArray = self.vm.dataArray
                vc.tagCode = str
                //vc.traceBatchId = self.vm.traceSourceTag.batchCode
            }
            
        }
        
    }

}
extension TagViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.style == .label {
            if range.location > 11 {
                ViewManager.showNotice(notice: "字符个数不能大于12")
                return false
            }
        }else {
            if range.location > 7 {
                ViewManager.showNotice(notice: "字符个数不能大于8")
                return false
            }
        }
        
        return true
    }
    
    func textChange(notify:NSNotification) {
        
        if notify.object is UITextField {
            if searchTextField.text?.count != 0 {
                searchButton.backgroundColor = JXOrangeColor
                searchButton.isEnabled = true
            }else{
                searchButton.backgroundColor = JXGrayColor
                searchButton.isEnabled = false
            }
        }
    }
    
}
