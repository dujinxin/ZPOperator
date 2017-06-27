//
//  TagViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/20.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class TagViewController: UIViewController {

    var vm = TraceSourceTagVM()
    
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.text = "210000100101"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func search(_ sender: UIButton) {
        self.vm.loadMainData(code: searchTextField.text!) { (data, msg, isSuccess) in
            if isSuccess{
                self.performSegue(withIdentifier: "210000100101", sender: self.vm.traceSourceTag)
            }else{
                print(msg)
            }
        }
    }
    

}
