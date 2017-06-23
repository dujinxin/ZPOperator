//
//  TraceSAddViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class TraceSAddViewController: UIViewController,UITextFieldDelegate{

    
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var productButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    lazy var vm = TraceSAddVM()
    
    var block : (()->())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.vm.loadMainData(append: true, completion: { (data, msg, isSuccess) in
            if isSuccess {
                self.addressButton.setTitle(self.vm.station, for: UIControlState.normal)
            }else{
                print("message = \(msg)")
            }
        })
    }
    
    @IBAction func addressButton(_ sender: UIButton) {
    }

    @IBAction func productAction(_ sender: UIButton) {
    }
    
    @IBAction func submit(_ sender: Any) {
 
        
        let model = self.vm.dataArray[0]
        
        self.vm.submitTS(goodId:String.init(format: "%@", model.id!), completion: { (data, msg, isSuccess) in
            if isSuccess {
                print("message = \(msg)")
                if let myblock = self.block {
                    myblock()
                }
                self.navigationController?.popViewController(animated: true)
            }else{
                print("message = \(msg)")
            }
        })
    }
    
    //MARK :  UITextFieldDelegate
    
    
}

