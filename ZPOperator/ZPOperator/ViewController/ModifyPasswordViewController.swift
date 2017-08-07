//
//  ModifyPasswordViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/27.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class ModifyPasswordViewController: ZPTableViewController {

    @IBOutlet weak var oldTextField: UITextField!
    @IBOutlet weak var newTextField: UITextField!
    @IBOutlet weak var againTextField: UITextField!
    @IBOutlet weak var newLookButton: UIButton!
    @IBOutlet weak var againLookButton: UIButton!

    @IBOutlet weak var confirmButton: UIButton!
    
    var vm = LoginVM()
    
    @IBAction func changeNewPasswordText(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            newTextField.isSecureTextEntry = false
        }else{
            newTextField.isSecureTextEntry = true
        }
    }
    @IBAction func changeAgainPasswordText(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            againTextField.isSecureTextEntry = false
        }else{
            againTextField.isSecureTextEntry = true
        }
    }
    
    
    @IBAction func confirm(_ sender: Any) {
        
        guard let oldPassword = oldTextField.text,
              let newPassword = newTextField.text,
              let againPassword = againTextField.text else {
                
                ViewManager.showNotice(notice: "密码不能为空")
            return
        }
        if !String.validatePassword(passWord: newPassword) {
            ViewManager.showNotice(notice: "密码格式错误")
            return
        }
        if newPassword != againPassword {
            ViewManager.showNotice(notice: "两次密码输入不一致")
            return
        }
        
        self.showMBProgressHUD()
        self.vm.modifyPassword(old: oldPassword, new: newPassword) { (data, msg, isSuccess) in
            self.hideMBProgressHUD()
            if isSuccess {
                self.navigationController?.popViewController(animated: true)
            }else{
                ViewManager.showNotice(notice: msg)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(notify:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        confirmButton.layer.cornerRadius = 5
        confirmButton.backgroundColor = JXGrayColor
        confirmButton.isEnabled = false
        
        newLookButton.isSelected = false
        againTextField.isSelected = false
 
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UITextFieldTextDidChange, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }else{
            return 120
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

extension ModifyPasswordViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == oldTextField {
            newTextField.becomeFirstResponder()
        }else if textField == newTextField {
            againTextField.becomeFirstResponder()
        }else{
            againTextField.resignFirstResponder()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textChange(notify:NSNotification) {
        
        if notify.object is UITextField {
            if oldTextField.text?.characters.count != 0 && newTextField.text?.characters.count != 0 && againTextField.text?.characters.count != 0 {
                confirmButton.backgroundColor = JXOrangeColor
                confirmButton.isEnabled = true
            }else{
                confirmButton.backgroundColor = JXGrayColor
                confirmButton.isEnabled = false
            }
        }
    }
    
}
