//
//  LoginViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/22.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var lookButton: UIButton!
    
    lazy var vm = LoginVM()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //textFieldTopConstraint.constant = CGFloat(333) * kPercent - 80
        
        lookButton.setImage(UIImage(named:"look_normal"), for: .normal)
        lookButton.setImage(UIImage(named:"look_highlight"), for: .highlighted)
        lookButton.isSelected = false
        loginButton.layer.cornerRadius = 22
        
        
        
        
        //userTextField.text = "13477831123"
        //passwordTextField.text = "12345678a"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        //
    }
    
    @IBAction func changePasswordText(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            passwordTextField.isSecureTextEntry = false
        }else{
            passwordTextField.isSecureTextEntry = true
        }
        
    }

    @IBAction func logAction(_ sender: Any) {
        
        guard let phone = userTextField.text,
            let password = passwordTextField.text else {
                ViewManager.showNotice(notice: "用户名密码不能为空")
                return
        }
        if !String.validateTelephone(tel: phone) {
            ViewManager.showNotice(notice: "密码格式错误")
            return
        }
        if password.isEmpty == true {
            ViewManager.showNotice(notice: "密码不能为空")
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        vm.login(userName: phone, password: password) { (data, msg, isSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if isSuccess {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationLoginStatus), object: true)
                self.dismiss(animated: true, completion: nil)
            }else{
                ViewManager.showNotice(notice: msg)
            }
        }
    }
    

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let s = textField.text! as NSString
        
        if textField == userTextField {
            if range.location > 10 {
                
                let str = s.substring(to: 10)
                textField.text = str
                ViewManager.showNotice(notice: "字符个数为11位")
            }
        }
        return true
    }
    
    func textChange(notify:NSNotification) {
        
    }
    
}
