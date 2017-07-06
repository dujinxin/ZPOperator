//
//  TraceSAddViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import MapKit

class TraceSAddViewController: BaseViewController,UITextFieldDelegate{

    
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var productButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    
    lazy var vm = TraceSAddVM()
    var jxAlertView : JXAlertView?
    var isAddressAlert = true
    var traceSAddBlock : (()->())?
    
    var address : String = ""
    
    var productArray = Array<String>()
    var addressArray = Array<String>()
    
    var selectIndex : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

        submitButton.layer.cornerRadius = 5
        submitButton.backgroundColor = UIColor.gray
        submitButton.isEnabled = false
        
        
        self.jxAlertView = JXAlertView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
        
        self.jxAlertView?.position = .bottom
        self.jxAlertView?.isSetCancelView = true
        self.jxAlertView?.delegate = self
        
        
        //NotificationCenter.default.addObserver(self, selector: #selector(locationStatus(notify:)), name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: nil)
        //开启定位
        //JXLocationManager.manager.startUpdateLocation()
        
        self.vm.loadMainData(append: true, completion: { (data, msg, isSuccess) in
            if isSuccess{
                //格式化数组
                self.addressButton.setTitle(self.vm.station, for: .normal)
                for model in self.vm.dataArray{
                    self.productArray.append(model.name!)
                }
            }
        })

    }
    
    @IBAction func addressButton(_ sender: UIButton) {

    }

    @IBAction func productAction(_ sender: UIButton) {
        
        isAddressAlert = false
        self.jxAlertView?.actions = self.productArray
        self.jxAlertView?.show()
    }
    
    @IBAction func submit(_ sender: Any) {
 
        
        let model = self.vm.dataArray[selectIndex]
        
        self.vm.submitTS(goodId:model.id!,goodName:model.name!, completion: { (data, msg, isSuccess) in
            ViewManager.showNotice(notice: msg)
            if isSuccess {
                print("message = \(msg)")
                if let myblock = self.traceSAddBlock {
                    myblock()
                }
                self.navigationController?.popViewController(animated: true)
            }
        })
    }

}
extension TraceSAddViewController : JXAlertViewDelegate{
    func jxAlertView(_ alertView: JXAlertView, clickButtonAtIndex index: Int) {

        self.productButton.setTitle(self.productArray[index], for: .normal)

        if let _ = addressButton.currentTitle,
            let _ = productButton.currentTitle{
            
            submitButton.backgroundColor = UIColor.originColor
            submitButton.isEnabled = true
            
        }else{
            submitButton.backgroundColor = UIColor.gray
            submitButton.isEnabled = false
            
        }
        if let _ = productButton.currentTitle {
            placeHolderLabel.isHidden = true
        }else{
            placeHolderLabel.isHidden = false
        }
        
    }
}
