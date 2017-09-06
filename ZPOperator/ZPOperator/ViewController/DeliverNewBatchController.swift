//
//  DeliverNewBatchController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/8/14.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class DeliverNewBatchController: ZPTableViewController {
    
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var orderNumTextField: UITextField!
    @IBOutlet weak var pcaAddressLabel: UILabel!
    @IBOutlet weak var detailAddressTextField: UITextField!
    @IBOutlet weak var remarkTextField: UITextField!
    @IBOutlet weak var operatorLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
//    lazy var pickSelectView: JXSelectView = {
//        let select = JXSelectView(frame: CGRect(), style: .pick)
//        select.isUseSystemItemBar = true
//        select.delegate = self
//        select.dataSource = self
//        return select
//    }()
    
    var vm = DeliverNewBatchVM()
    var jxAlertView : JXAlertView?
    var productArray = Array<String>()
    
    var productId : Int = -1
    var orderString : String?
    var provinceId : Int = -1
    var provinceString : String?
    var cityId : Int = -1
    var cityString : String?
    var areaId : Int = -1
    var areaString : String?
    var detailString : String?
    

    @IBAction func submitClick(_ sender: UIButton) {
        if productId == -1 {
            ViewManager.showNotice(notice: "请选择产品")
            return
        }
        guard
             let orderString = orderNumTextField.text,
             orderString.isEmpty == false else {
            ViewManager.showNotice(notice: "请填写订单数量")
            return
        }
        if String.validateNumber(string: orderString) == false{
            ViewManager.showNotice(notice: "订单数量输入有误，请输入纯数字")
            return
        }
        guard
            let provinceString = provinceString,
            let cityString = cityString,
            let areaString = areaString,
            productId != -1,
            cityId != -1,
            areaId != -1
            else {
            ViewManager.showNotice(notice: "请填写收货地址")
            return
        }
        guard
            let detailString = self.detailAddressTextField.text,
            detailString.isEmpty == false else {
            ViewManager.showNotice(notice: "请填写街道地址")
            return
        }
        self.showMBProgressHUD()
        self.vm.deliverNewBatchSave(goodsId: productId, counts: orderString, provinceId: productId, cityId: cityId, countyId: areaId, province: provinceString, city: cityString, county: areaString, address: detailString, remarks: remarkTextField.text ?? "") { (data, msg, isSuccess) in
            self.hideMBProgressHUD()
            ViewManager.showNotice(notice: msg)
            if
                let block = self.backBlock ,
                isSuccess == true {
                block()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.layer.cornerRadius = 5
        submitButton.backgroundColor = JXGrayColor
//        submitButton.isEnabled = false
        
        self.jxAlertView = JXAlertView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
        self.jxAlertView?.position = .bottom
        self.jxAlertView?.isSetCancelView = true
        self.jxAlertView?.delegate = self
        
        
        self.vm.deliverNewBatchInfo { (data, msg, isSuccess) in
            guard isSuccess == true ,self.vm.deliverNewBatchModel.provinceList.isEmpty == false else{
                return
            }
            self.stationLabel.text = self.vm.deliverNewBatchModel.Operator.station
            self.operatorLabel.text = self.vm.deliverNewBatchModel.Operator.name
            for model in self.vm.deliverNewBatchModel.goodsList{
                self.productArray.append(model.name!)
            }
            self.jxAlertView?.actions = self.productArray
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            
            let contentView = UIView()
            contentView.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: 44)
            
            
            let titleLabel = UILabel()
            titleLabel.frame = CGRect.init(x: 15, y: 0, width: view.frame.width - 30, height: 44)
            titleLabel.text = "以下内容可根据需要选填"
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            titleLabel.textAlignment = .left
            titleLabel.textColor = JX666666Color
            
            contentView.addSubview(titleLabel)
            
            return contentView
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 2  {
            return 10
        }else if section == 1 {
            return 44
        }else{
            return 30
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.view.endEditing(true)
            if indexPath.row == 1 {
                self.jxAlertView?.show()
            }else if indexPath.row == 3{
                guard self.vm.deliverNewBatchModel.provinceList.isEmpty == false else {
                    return
                }
                self.provinceId = self.vm.deliverNewBatchModel.provinceList[0].id
                self.provinceString = self.vm.deliverNewBatchModel.provinceList[0].name
                self.vm.deliverAddress(pid: self.vm.deliverNewBatchModel.provinceList[0].id, isCity: true) { (data, msg, isSuccess) in
                    guard isSuccess == true ,self.vm.deliverNewBatchModel.cityList.isEmpty == false else{
                        return
                    }
                    self.cityId = self.vm.deliverNewBatchModel.cityList[0].id
                    self.cityString = self.vm.deliverNewBatchModel.cityList[0].name
                    self.vm.deliverAddress(pid: self.vm.deliverNewBatchModel.cityList[0].id, isCity: false) { (data, msg, isSuccess) in
                        guard isSuccess == true ,self.vm.deliverNewBatchModel.areaList.isEmpty == false else{
                            return
                        }
                        self.areaId = self.vm.deliverNewBatchModel.areaList[0].id
                        self.areaString = self.vm.deliverNewBatchModel.areaList[0].name
                        
                        let select = JXSelectView(frame: CGRect(), style: .pick)
                        select.isUseSystemItemBar = true
                        select.delegate = self
                        select.dataSource = self
                        select.show()
                    }
                }
            }
        }
    }

}
extension DeliverNewBatchController:JXAlertViewDelegate{
    func jxAlertView(_ alertView: JXAlertView, clickButtonAtIndex index: Int) {
        
        //selectIndex = index
        self.productLabel.text = self.productArray[index]
        self.productId = self.vm.deliverNewBatchModel.goodsList[index].id
        
//        if let _ = addressButton.currentTitle,
//            let _ = productButton.currentTitle{
//            
//            submitButton.backgroundColor = JXOrangeColor
//            submitButton.isEnabled = true
//            
//        }else{
//            submitButton.backgroundColor = JXGrayColor
//            submitButton.isEnabled = false
//            
//        }
        
//        if let _ = productButton.currentTitle {
//            placeHolderLabel.isHidden = true
//        }else{
//            placeHolderLabel.isHidden = false
//        }
        
    }
}
extension DeliverNewBatchController : JXSelectViewDelegate,JXSelectViewDataSource{
    func jxSelectView(jxSelectView: JXSelectView, didSelectRowAt row: Int, inSection section: Int) {
        
        if section == 0 {
            self.provinceId = self.vm.deliverNewBatchModel.provinceList[row].id
            self.provinceString = self.vm.deliverNewBatchModel.provinceList[row].name
            
            self.vm.deliverAddress(pid: self.provinceId, isCity: true) { (data, msg, isSuccess) in
                guard isSuccess == true ,self.vm.deliverNewBatchModel.cityList.isEmpty == false else{
                    return
                }
                self.cityId = self.vm.deliverNewBatchModel.cityList[0].id
                self.cityString = self.vm.deliverNewBatchModel.cityList[0].name
                jxSelectView.pickView.reloadComponent(1)
                jxSelectView.pickView.selectRow(0, inComponent: 1, animated: true)
                self.vm.deliverAddress(pid: self.cityId, isCity: false) { (data, msg, isSuccess) in
                    guard isSuccess == true ,self.vm.deliverNewBatchModel.areaList.isEmpty == false else{
                        return
                    }
                    self.areaId = self.vm.deliverNewBatchModel.areaList[0].id
                    self.areaString = self.vm.deliverNewBatchModel.areaList[0].name
                    jxSelectView.pickView.reloadComponent(2)
                    jxSelectView.pickView.selectRow(0, inComponent: 2, animated: true)
                }
               
            }
        }else if section == 1{
            self.cityId = self.vm.deliverNewBatchModel.cityList[row].id
            self.cityString = self.vm.deliverNewBatchModel.cityList[row].name
            self.vm.deliverAddress(pid: self.cityId, isCity: false) { (data, msg, isSuccess) in
                guard isSuccess == true ,self.vm.deliverNewBatchModel.areaList.isEmpty == false else{
                    return
                }
                self.areaId = self.vm.deliverNewBatchModel.areaList[0].id
                self.areaString = self.vm.deliverNewBatchModel.areaList[0].name
                jxSelectView.pickView.reloadComponent(2)
                jxSelectView.pickView.selectRow(0, inComponent: 2, animated: true)
            }
        }else{
            self.areaId = self.vm.deliverNewBatchModel.areaList[row].id
            self.areaString = self.vm.deliverNewBatchModel.areaList[row].name
        }
        
    }
    func jxSelectView(jxSelectView: JXSelectView, clickButtonAtIndex index: Int) {
        if index == 1 {
            guard
                let ps = self.provinceString,
                let cs = self.cityString,
                let As = self.areaString
                else {
                return
            }
            self.pcaAddressLabel.text = "\(ps)\(cs)\(As)"
        }else{
            self.provinceString = nil
            self.cityString = nil
            self.areaString = nil
            self.provinceId = -1
            self.cityId = -1
            self.areaId = -1
        }
        print(self.pcaAddressLabel)
    }
    func jxSelectView(jxSelectView: JXSelectView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.vm.deliverNewBatchModel.provinceList.count
        }else if section == 1{
            return self.vm.deliverNewBatchModel.cityList.count
        }else{
            return self.vm.deliverNewBatchModel.areaList.count
        }
    }
    func jxSelectView(jxSelectView: JXSelectView, contentForRow row: Int, InSection section: Int) -> String {
        if section == 0 {
            return self.vm.deliverNewBatchModel.provinceList[row].name ?? ""
        }else if section == 1{
            return self.vm.deliverNewBatchModel.cityList[row].name ?? ""
        }else{
            return self.vm.deliverNewBatchModel.areaList[row].name ?? ""
        }
    }
    func jxSelectView(jxSelectView: JXSelectView, heightForRowAt row: Int) -> CGFloat {
        return 40
    }
    func jxSelectView(jxSelectView: JXSelectView, widthForComponent component: Int) -> CGFloat {
        return kScreenWidth / 3
    }
    func numberOfComponents(jxSelectView: JXSelectView) -> Int {
        return 3
    }
}
extension DeliverNewBatchController:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if self.pickSelectView.isShowed {
//            self.pickSelectView.dismiss()
//        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
