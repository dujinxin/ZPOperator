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
    
    @IBOutlet weak var textFieldTopConstraint: NSLayoutConstraint!
    lazy var vm = LoginVM()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textFieldTopConstraint.constant = CGFloat(333) * kPercent - 80
        
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
    

    @IBAction func logAction(_ sender: Any) {
        
        
        
        
        
//        guard let phone = userTextField.text ,
//              let password = passwordTextField.text else {
//            
//            return
//        }
//        
//        if !String.validateTelephone(tel: phone) {
//            
//        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        vm.login(userName: userTextField.text!, password: passwordTextField.text!) { (data, msg, isSuccess) in
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
}
