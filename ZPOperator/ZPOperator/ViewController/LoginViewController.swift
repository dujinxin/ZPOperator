//
//  LoginViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/22.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var lookButton: UIButton!
   
    @IBOutlet weak var leadingConstraints: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //textFieldTopConstraint.constant = CGFloat(333) * kPercent - 80
        
        var font = UIFont.systemFont(ofSize: 13)
        
        if kScreenWidth < 375 {
            self.leadingConstraints.constant = 15
            self.trailingConstraints.constant = 15
            font = UIFont.systemFont(ofSize: 12)
        }
        
        let attributeString1 = NSMutableAttributedString.init(string: "请向企业管理员提供手机号")
        attributeString1.addAttributes([NSFontAttributeName:font,NSForegroundColorAttributeName:UIColor.rgbColor(rgbValue: 0xd0cece)], range: NSRange.init(location: 0, length: attributeString1.length))
        userTextField.attributedPlaceholder = attributeString1
        
        let attributeString2 = NSMutableAttributedString.init(string: "如果忘记密码，请联系管理员")
        attributeString2.addAttributes([NSFontAttributeName:font,NSForegroundColorAttributeName:UIColor.rgbColor(rgbValue: 0xd0cece)], range: NSRange.init(location: 0, length: attributeString2.length))
        passwordTextField.attributedPlaceholder = attributeString2
        
        
        lookButton.setImage(UIImage(named:"look_normal"), for: .normal)
        lookButton.setImage(UIImage(named:"look_highlight"), for: .highlighted)
        lookButton.isSelected = false
        
        loginButton.backgroundColor = UIColor.rgbColor(from: 153, 153, 153)
        loginButton.layer.cornerRadius = 22
        //loginButton.alpha = 0.4
        
        
        
        
        //userTextField.text = "13477831123"
        //passwordTextField.text = "12345678a"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
            ViewManager.showNotice(notice: "手机号格式错误")
            return
        }
        if password.isEmpty == true {
            ViewManager.showNotice(notice: "密码不能为空")
            return
        }
        
        self.showMBProgressHUD()
        
        LoginVM.loginVMManager.login(userName: phone, password: password) { (data, msg, isSuccess) in
            self.hideMBProgressHUD()
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

        if textField == userTextField {
            if range.location > 10 {
                //let s = textField.text! as NSString
                //let str = s.substring(to: 10)
                //textField.text = str
                //ViewManager.showNotice(notice: "字符个数为11位")
                return false
            }
        }
        return true
    }
    func textChange(notify:NSNotification) {
        
    }
    
}
