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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logAction(_ sender: Any) {
        
        userTextField.text = "13121213434"
        passwordTextField.text = "123456"
        
        JXBaseRequest.request(url: ApiString.userLogin.rawValue, param: ["ua":userTextField.text!,"Up":passwordTextField.text!], success: { (data, message, type) in
            //
            let isJson = JSONSerialization.isValidJSONObject(data)
            print(isJson)
            //let jsons = JSONSerialization.jsonObject(with: <#T##InputStream#>, options: <#T##JSONSerialization.ReadingOptions#>)
            
            guard let data = data as? Data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                else{
                    return
            }
            
            print("jsonData = \(jsonData) \n message = \(message) \n alertType = \(type)")
        }) { (task, error) in
            print(error)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    

}
