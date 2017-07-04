//
//  TagViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/20.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class TagViewController: BaseViewController {

    var vm = TraceSourceDetailVM()
    
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //searchTextField.text = "210000100101"
        
        self.searchButton.layer.cornerRadius = 5
        self.searchButton.backgroundColor = UIColor.gray
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(notify:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UITextFieldTextDidChange, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func search(_ sender: UIButton) {
        self.vm.traceSourceTag(code: searchTextField.text!) { (data, msg, isSuccess) in
            if isSuccess{
                if let status = self.vm.traceSourceTag.status?.intValue{
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
                vc.tagCode = str
                //vc.traceBatchId = self.vm.traceSourceTag.batchCode
            }
            
        }
        
    }

}
extension TagViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.becomeFirstResponder()
       
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let s = textField.text! as NSString
        
        if range.location > 11 {
            
            let str = s.substring(to: 11)
            textField.text = str
            ViewManager.showNotice(notice: "字符个数不能大于12")
        }
        return true
    }
    
    func textChange(notify:NSNotification) {
        
        if notify.object is UITextField {
            if searchTextField.text?.characters.count != 0 {
                searchButton.backgroundColor = UIColor.originColor
                searchButton.isEnabled = true
            }else{
                searchButton.backgroundColor = UIColor.gray
                searchButton.isEnabled = false
            }
        }
    }
    
}
