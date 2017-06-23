//
//  LoginViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/22.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    lazy var vm = LoginVM()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logAction(_ sender: Any) {
        
        userTextField.text = "13477831123"
        passwordTextField.text = "abc123"
        
        vm.login(userName: userTextField.text!, password: passwordTextField.text!) { (data, msg, isSuccess) in
            if isSuccess {
                self.dismiss(animated: true, completion: nil)
            }else{
                print(msg)
            }
        }
        
//        JXNetworkManager.manager.login(userName: userTextField.text!, password: passwordTextField.text!) { (data,msg, isSuccess) in
//            if isSuccess {
//                self.dismiss(animated: true, completion: nil)
//            }else{
//                print(msg)
//            }
//        }
        
//        JXNetworkManager.manager.login(userName: userTextField.text!, password: passwordTextField.text!) { (msg, isSuccess) in
//            if isSuccess {
//                self.dismiss(animated: true, completion: nil)
//            }else{
//                print(msg)
//            }
//        }
    }
    

}
