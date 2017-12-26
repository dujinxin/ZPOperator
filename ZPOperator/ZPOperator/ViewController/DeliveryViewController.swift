//
//  DeliveryViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/8/21.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class DeliveryViewController: ZPTableViewController {
    // MARK: - Properties
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var batchLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sizePreview: UIImageView!
    
    @IBOutlet weak var orderNumTextField: UITextField!
    
    @IBOutlet weak var codeButton: UIButton!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endTextField: UITextField!
   
    
    @IBOutlet weak var pcaAddressLabel: UILabel!
    @IBOutlet weak var detailAddressTextField: UITextField!
    @IBOutlet weak var remarkTextField: UITextField!
    @IBOutlet weak var operatorLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    var vm = DeliverDirectVM()
    var actionView : JXActionView?
    var selectView : JXSelectView?
    
    let confirmTitleArray = ["产品","溯源批次","标签规格","订单数量","开始编码","结束编码","收货","备注","操作人"]
    var confirmArray = Array<String>()
    
    var alertView : JXAlertView?
    
    
    var isProcessAlert : Int = 0
    var productArray = Array<String>()
    var batchArray = Array<String>()
    //产品
    var productId : Int = -1
    var productName : String?
    //批次
    var batchId : Int = -1
    var batchName : String?
    //规格
    var sizeId : Int = -1
    var sizeName : String?
    
    var orderString : String?//138
    
    //省市区
    var provinceId : Int = -1
    var provinceString : String?
    var cityId : Int = -1
    var cityString : String?
    var areaId : Int = -1
    var areaString : String?
    
    var pcaArray = Array<Dictionary<String,Any>>()
    var detailString : String?
    // MARK: - Systom Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.layer.cornerRadius = 5
        submitButton.backgroundColor = JXGrayColor
        submitButton.isEnabled = false
        
        codeButton.layer.cornerRadius = 5
        codeButton.backgroundColor = JXMainColor
        
        self.sizePreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(codeSizePreview)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(notify:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        self.actionView = JXActionView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
        self.actionView?.tag = 10
        self.actionView?.isUseBottomView = true
        self.actionView?.delegate = self
        
        
        self.vm.fetchDeliverInfo { (data, msg, isSuccess) in
            guard isSuccess == true ,self.vm.deliverDirectModel.provinceList.isEmpty == false else{
                return
            }
            //self.stationLabel.text = self.vm.deliverNewBatchModel.Operator.station
            self.operatorLabel.text = self.vm.deliverDirectModel.Operator.name
            for model in self.vm.deliverDirectModel.goodsList{
                self.productArray.append(model.name!)
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func codeSizePreview() {
        let customView = setSizeSelectView()
        let alertView = JXAlertView.init(frame: customView.bounds, style: .custom)
        alertView.customView = customView
        self.alertView = alertView
        self.alertView?.show()
    }
    @IBAction func fetchCode(_ sender: Any) {
        
        if productId == -1 {
            ViewManager.showNotice(notice: "请选择产品")
            return
        }
        //防止重复获取
        if
            let startText = self.startLabel.text,
            let endText = self.endTextField.text,
            startText.isEmpty == false,
            endText.isEmpty == false,
            self.orderString == orderNumTextField.text{
            return
        }
        
        guard
            let orderStr = orderNumTextField.text,
            orderStr.isEmpty == false else {
                ViewManager.showNotice(notice: "请填写订单数量")
                return
        }
        if String.validateNumber(string: orderStr) == false{
            ViewManager.showNotice(notice: "订单数量输入有误，请输入纯数字")
            return
        }
        self.orderString = orderStr
        self.showMBProgressHUD()
        self.vm.fetchCode(counts: Int(orderStr)!) { (data, msg, isSuccess) in
            self.hideMBProgressHUD()
            if isSuccess == true{
                self.startLabel.text = self.vm.deliverDirectCodeModel.startCode
                self.endTextField.text = self.vm.deliverDirectCodeModel.endCode
            }else{
                ViewManager.showNotice(notice: msg)
            }
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        if productId == -1 {
            ViewManager.showNotice(notice: "请选择产品")
            return
        }
        guard
            let orderStr = orderNumTextField.text,
            orderStr.isEmpty == false else {
                ViewManager.showNotice(notice: "请填写订单数量")
                return
        }
        if String.validateNumber(string: orderStr) == false{
            ViewManager.showNotice(notice: "订单数量输入有误，请输入纯数字")
            return
        }
        if sizeLabel.text?.isEmpty == true {
            ViewManager.showNotice(notice: "请先选择标签规格")
            return
        }
        guard
            pcaArray.count == 3,
            let provinceName = pcaArray[0]["name"] as? String,
            let cityName = pcaArray[1]["name"] as? String,
            let areaName = pcaArray[2]["name"] as? String,
            let _ = pcaArray[0]["id"] as? Int,
            let _ = pcaArray[1]["id"] as? Int,
            let _ = pcaArray[2]["id"] as? Int
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
        guard
            let startCode = self.vm.deliverDirectCodeModel.startCode,
            let endCode = self.endTextField.text,
            endCode.isEmpty == false else {
            return
        }
        var remarkText = "暂无"
        if
            let text = self.remarkTextField.text,
            text.isEmpty == false{
            remarkText = text
        }
        self.confirmArray.removeAll()
        self.confirmArray.append(String.init(format: "%@", self.productName ?? ""))
        self.confirmArray.append(String.init(format: "%@", self.batchName ?? "暂无溯源批次"))
        self.confirmArray.append(String.init(format: "%@", self.sizeLabel.text ?? "暂无可用标签"))
        self.confirmArray.append(String.init(format: "%d", orderStr))
        self.confirmArray.append(String.init(format: "%@", startCode))
        self.confirmArray.append(String.init(format: "%@", endCode))
        self.confirmArray.append(String.init(format: "%@%@%@%@", provinceName,cityName,areaName,detailString))
        
        self.confirmArray.append(String.init(format: "%@", remarkText))
        self.confirmArray.append(String.init(format: "%@", self.vm.deliverDirectModel.Operator.name ?? ""))
        
        setConfirmSelectView()
        
    }
    func validate() {
        
        if
            productId != -1,//产品
            let orderStr = orderNumTextField.text,//订单数量
            orderStr.isEmpty == false,
            String.validateNumber(string: orderStr) == true,
      
            pcaArray.count == 3, //省市区
//            let provinceName = pcaArray[0]["name"] as? String,
//            let cityName = pcaArray[1]["name"] as? String,
//            let areaName = pcaArray[2]["name"] as? String,
//            let provinceID = pcaArray[0]["id"] as? Int,
//            let cityID = pcaArray[1]["id"] as? Int,
//            let areaID = pcaArray[2]["id"] as? Int,
  
            let detailString = self.detailAddressTextField.text,//详细地址
            detailString.isEmpty == false,
        
        
            let endStr = endTextField.text, //标签编码
            let endCode = self.vm.deliverDirectCodeModel.endCode,
            let endNumber = Int(endCode),
            let number = Int(endStr),
            endStr.count == 12,
            number >= endNumber
        {
            submitButton.backgroundColor = JXOrangeColor
            submitButton.isEnabled = true
        }else{
            submitButton.backgroundColor = JXGrayColor
            submitButton.isEnabled = false
        }
    }
    
    func setConfirmSelectView() {
        selectView = nil
        selectView = JXSelectView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 200), style:.list)
        selectView?.dataSource = self
        selectView?.topBarView = {
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height:
                260))
            view.backgroundColor = JX999999Color
            
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 59.5)
            label.backgroundColor = UIColor.white
            //label.center = view.center
            label.text = "确认发货信息"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 18)
            label.textColor = JX333333Color
            view.addSubview(label)
            //label.sizeToFit()
            
            let button = UIButton()
            button.frame = CGRect(x: 10, y: 8.5, width: 40, height: 40)
            //button.center = CGPoint(x: 30, y: view.jxCenterY)
            //button.setTitle("×", for: .normal)
            button.setImage(UIImage(named:"cancel"), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            button.setTitleColor(JX333333Color, for: .normal)
            button.contentVerticalAlignment = .center
            button.contentHorizontalAlignment = .center
            button.addTarget(self, action: #selector(dismissSelectView), for: .touchUpInside)
            view.addSubview(button)
            
            return view
        }()
        selectView?.isUseCustomTopBar = true
        selectView?.isEnabled = false
        selectView?.isScrollEnabled = false
        self.selectView?.resetFrame(height: CGFloat(44 * confirmTitleArray.count + 88))
        selectView?.show()
    }
    func setSizeSelectView() -> UIView {
        
        let contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth * 0.8, height:
            260))
        contentView.backgroundColor = JXFfffffColor
        //view.layer.cornerRadius =
        
        let titleArray = ["35mm*20mm","27mm*17mm"]
        let imageArray = ["size_2035","size_1727"]
        let sizeArray = [CGSize(width: 275.0 * 0.6, height: 275.0 * 0.6 * (20.0 / 35.0)),CGSize(width: 212.0 * 0.6, height: 212.0 * 0.6 * (17.0 / 27.0))]
        
        
        //let imageViewSize = CGSize(width: view.jxWidth * 0.8, height: view.jxWidth * 0.6 * (17.0 / 24.0))
        var H : CGFloat = 0.0
        for i in 0..<titleArray.count {
            let size = sizeArray[i]
            var height : CGFloat = 0
            if i > 0 {
                height = sizeArray[0].height + 10.0 * 2.0 + 14.0
            }
            
            let imageView = UIImageView()
            imageView.frame = CGRect(x: 0, y: 10.0 + height, width: size.width, height: size.height)
            imageView.image = UIImage(named: imageArray[i])
            contentView.addSubview(imageView)
            imageView.center = CGPoint(x: contentView.center.x, y: imageView.center.y)
            
            let label = UILabel()
            label.frame = CGRect(x: 0, y: imageView.jxBottom + 10.0, width: contentView.jxWidth, height: 14)
            label.text = titleArray[i]
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = JX333333Color
            contentView.addSubview(label)
            
            H = label.jxBottom
      
        }
        
        let separateLine = UIView(frame: CGRect(x: 0, y: H + 10 - 0.5, width: contentView.frame.width, height:
            0.5))
        separateLine.backgroundColor = UIColor.groupTableViewBackground
        contentView.addSubview(separateLine)
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: H + 10, width: contentView.frame.width, height: 44)
        button.setTitle("确定", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(JXMainColor, for: .normal)
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(dismissAlertView), for: .touchUpInside)
        contentView.addSubview(button)

        contentView.frame = CGRect.init(x: 0, y: 0, width: kScreenWidth * 0.8, height:
            H + 10 + 44)
   
        return contentView
    }
    func dismissAlertView() {
        self.alertView?.dismiss()
    }
    func dismissSelectView() {
        self.selectView?.dismiss()
    }
    func confirmDeliver() {
        if productId == -1 {
            ViewManager.showNotice(notice: "请选择产品")
            return
        }
        guard
            let orderStr = orderNumTextField.text,
            orderStr.isEmpty == false else {
                ViewManager.showNotice(notice: "请填写订单数量")
                return
        }
        if String.validateNumber(string: orderStr) == false{
            ViewManager.showNotice(notice: "订单数量输入有误，请输入纯数字")
            return
        }
        guard
            pcaArray.count == 3,
            let provinceName = pcaArray[0]["name"] as? String,
            let cityName = pcaArray[1]["name"] as? String,
            let areaName = pcaArray[2]["name"] as? String,
            let provinceID = pcaArray[0]["id"] as? Int,
            let cityID = pcaArray[1]["id"] as? Int,
            let areaID = pcaArray[2]["id"] as? Int
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
        guard
            let startCode = self.vm.deliverDirectCodeModel.startCode,
            let endCode = self.endTextField.text,
            endCode.isEmpty == false else {
                return
        }
        
        self.selectView?.dismiss()
        self.showMBProgressHUD()
        
        self.vm.deliverSave(goodsId: productId, counts: orderStr, provinceId: provinceID, cityId: cityID, countyId: areaID, province: provinceName, city: cityName, county: areaName, address: detailString, remarks: remarkTextField.text ?? "", startCode: startCode, endCode: endCode, traceBatchId: self.batchId,codeType: self.sizeId) { (data, msg, isSuccess) in
            self.hideMBProgressHUD()
            ViewManager.showNotice(notice: msg)
            if
                let block = self.backBlock,
                isSuccess == true{
                block()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 4 {
            
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
        if section == 3 || section == 5  {
            return 10
        }else if section == 4 {
            return 44
        }else if section == 6 {
            return 30
        }else{
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                isProcessAlert = 1
                self.actionView?.actions = self.productArray
                self.actionView?.show()
            }else if indexPath.row == 1{
                isProcessAlert = 0
                if self.productId == -1 {
                    ViewManager.showNotice(notice: "请选择产品")
                    return
                }
                if self.batchId != -1 {
                    self.actionView?.actions = self.batchArray
                    self.actionView?.show()
                    return
                }
                self.vm.fetchBatchs(goodsId: self.productId, completion: { (data, msg, isSuccess) in
                    if isSuccess == false {
                        ViewManager.showNotice(notice: msg)
                    }
                    guard isSuccess == true ,self.vm.batchs.isEmpty == false else{
                        self.batchLabel.text = "暂无溯源批次"
                        self.batchId = -1
                        return
                    }
                    self.batchArray.removeAll()
                    for model in self.vm.batchs{
                        self.batchArray.append(model.name!)
                    }
                    self.actionView?.actions = self.batchArray
                    self.actionView?.show()
                })
            }else if indexPath.row == 2 {
                
                if self.vm.deliverDirectModel.codeSpecList.isEmpty == false {
                    var titleArray = Array<String>()
                    for model in self.vm.deliverDirectModel.codeSpecList {
                        titleArray.append(model.desc!)
                    }
                    
                    let actionView = JXActionView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
                    actionView.isUseBottomView = true
                    actionView.delegate = self
                    actionView.actions = titleArray
                    actionView.tag = 11
                    actionView.show()
                } else {
                    ViewManager.showNotice(notice: "暂无可用标签，请先申请标签")
                    return
                }
            }
        }
        if indexPath.section == 3 {
            if indexPath.row == 0{
                guard self.vm.deliverDirectModel.provinceList.isEmpty == false else {
                    return
                }
                self.provinceId = self.vm.deliverDirectModel.provinceList[0].id
                self.provinceString = self.vm.deliverDirectModel.provinceList[0].name
                self.vm.deliverAddress(pid: self.vm.deliverDirectModel.provinceList[0].id, isCity: true) { (data, msg, isSuccess) in
                    guard isSuccess == true ,self.vm.deliverDirectModel.cityList.isEmpty == false else{
                        return
                    }
                    self.cityId = self.vm.deliverDirectModel.cityList[0].id
                    self.cityString = self.vm.deliverDirectModel.cityList[0].name
                    self.vm.deliverAddress(pid: self.vm.deliverDirectModel.cityList[0].id, isCity: false) { (data, msg, isSuccess) in
                        guard isSuccess == true ,self.vm.deliverDirectModel.areaList.isEmpty == false else{
                            return
                        }
                        self.areaId = self.vm.deliverDirectModel.areaList[0].id
                        self.areaString = self.vm.deliverDirectModel.areaList[0].name
                        
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
extension DeliveryViewController:JXActionViewDelegate{
    func jxActionView(_ actionView: JXActionView, clickButtonAtIndex index: Int) {
        
        if actionView.tag == 10 {
            if isProcessAlert == 0 {
                self.batchLabel.text = self.batchArray[index]
                self.batchId = self.vm.batchs[index].id
                self.batchName = self.vm.batchs[index].name
            }else{
                
                if self.productLabel.text == self.productArray[index] && self.productId == self.vm.deliverDirectModel.goodsList[index].id {
                    return
                }else{
                    self.productLabel.text = self.productArray[index]
                    self.productId = self.vm.deliverDirectModel.goodsList[index].id
                    self.productName = self.vm.deliverDirectModel.goodsList[index].name
                    
                    self.batchLabel.text = "请选择"
                    self.batchId = -1
                    self.batchName = nil
                    self.batchArray.removeAll()
                }
            }
        }else if actionView.tag == 11 {
            self.sizeName = self.vm.deliverDirectModel.codeSpecList[index].desc
            self.sizeId = self.vm.deliverDirectModel.codeSpecList[index].id
            self.sizeLabel.text = self.vm.deliverDirectModel.codeSpecList[index].desc
        }
    }
}
extension DeliveryViewController : JXSelectViewDelegate,JXSelectViewDataSource{
    func jxSelectView(jxSelectView: JXSelectView, didSelectRowAt row: Int, inSection section: Int) {
        
        if section == 0 {
            self.provinceId = self.vm.deliverDirectModel.provinceList[row].id
            self.provinceString = self.vm.deliverDirectModel.provinceList[row].name
            
            self.vm.deliverAddress(pid: self.provinceId, isCity: true) { (data, msg, isSuccess) in
                guard isSuccess == true ,self.vm.deliverDirectModel.cityList.isEmpty == false else{
                    return
                }
                self.cityId = self.vm.deliverDirectModel.cityList[0].id
                self.cityString = self.vm.deliverDirectModel.cityList[0].name
                jxSelectView.pickView.reloadComponent(1)
                jxSelectView.pickView.selectRow(0, inComponent: 1, animated: true)
                self.vm.deliverAddress(pid: self.cityId, isCity: false) { (data, msg, isSuccess) in
                    guard isSuccess == true ,self.vm.deliverDirectModel.areaList.isEmpty == false else{
                        return
                    }
                    self.areaId = self.vm.deliverDirectModel.areaList[0].id
                    self.areaString = self.vm.deliverDirectModel.areaList[0].name
                    jxSelectView.pickView.reloadComponent(2)
                    jxSelectView.pickView.selectRow(0, inComponent: 2, animated: true)
                }
                
            }
        }else if section == 1{
            self.cityId = self.vm.deliverDirectModel.cityList[row].id
            self.cityString = self.vm.deliverDirectModel.cityList[row].name
            self.vm.deliverAddress(pid: self.cityId, isCity: false) { (data, msg, isSuccess) in
                guard isSuccess == true ,self.vm.deliverDirectModel.areaList.isEmpty == false else{
                    return
                }
                self.areaId = self.vm.deliverDirectModel.areaList[0].id
                self.areaString = self.vm.deliverDirectModel.areaList[0].name
                jxSelectView.pickView.reloadComponent(2)
                jxSelectView.pickView.selectRow(0, inComponent: 2, animated: true)
            }
        }else{
            self.areaId = self.vm.deliverDirectModel.areaList[row].id
            self.areaString = self.vm.deliverDirectModel.areaList[row].name
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
            self.pcaArray.removeAll()
            self.pcaArray.append(["name":ps,"id":self.provinceId])
            self.pcaArray.append(["name":cs,"id":self.cityId])
            self.pcaArray.append(["name":As,"id":self.areaId])
            
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
        if jxSelectView.style == .pick {
            if section == 0 {
                return self.vm.deliverDirectModel.provinceList.count
            }else if section == 1{
                return self.vm.deliverDirectModel.cityList.count
            }else{
                return self.vm.deliverDirectModel.areaList.count
            }
        }else{
            return confirmTitleArray.count + 1
        }
    }
    func jxSelectView(jxSelectView: JXSelectView, contentForRow row: Int, InSection section: Int) -> String {
        if section == 0 {
            return self.vm.deliverDirectModel.provinceList[row].name ?? ""
        }else if section == 1{
            return self.vm.deliverDirectModel.cityList[row].name ?? ""
        }else{
            return self.vm.deliverDirectModel.areaList[row].name ?? ""
        }
    }
    func jxSelectView(jxSelectView: JXSelectView, heightForRowAt row: Int) -> CGFloat {
        if jxSelectView.style == .pick {
            return 40
        }else{
            if row < confirmTitleArray.count{
                return 44
            }else{
                return 88
            }
        }
    }
    func jxSelectView(jxSelectView: JXSelectView, widthForComponent component: Int) -> CGFloat {
        return kScreenWidth / 3
    }
    func numberOfComponents(jxSelectView: JXSelectView) -> Int {
        return 3
    }
    func jxSelectView(jxSelectView: JXSelectView, viewForRow row: Int) -> UIView? {
        var view : UIView?
        
        if row < confirmTitleArray.count{
            view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 44))
            
            let leftLabel = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: 60, height: 44))
            leftLabel.textColor = JX999999Color
            leftLabel.textAlignment = .left
            leftLabel.font = UIFont.systemFont(ofSize: 14)
            leftLabel.text = confirmTitleArray[row]
            view?.addSubview(leftLabel)
            
            let rightLabel = UILabel.init(frame: CGRect.init(x: 80, y: 0, width: kScreenWidth - 80 - 20, height: 44))
            rightLabel.textColor = JX333333Color
            rightLabel.textAlignment = .left
            rightLabel.font = UIFont.systemFont(ofSize: 13)
            rightLabel.text = self.confirmArray[row]
            rightLabel.numberOfLines = 2
            view?.addSubview(rightLabel)
            
            
        }else{
            
            let button = UIButton()
            button.frame = CGRect.init(x: 40, y: 22, width: kScreenWidth - 80, height: 44)
            button.setTitle("确认发货", for: UIControlState.normal)
            button.setTitleColor(UIColor.white, for: UIControlState.normal)
            button.backgroundColor = JXOrangeColor
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(confirmDeliver), for: UIControlEvents.touchUpInside)
            return button
            
        }
        return view
    }
}
extension DeliveryViewController:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.endTextField {
            if range.location > 11 {
                //ViewManager.showNotice(notice: "字符个数不能大于12")
                return false
            }
        }
        
        return true
    }
    
    func textChange(notify:NSNotification) {
        
        if let textField = notify.object as? UITextField{
            
            if textField == endTextField {
                if
                    let endStr = textField.text,
                    let endCode = self.vm.deliverDirectCodeModel.endCode,
                    let endNumber = Int(endCode),
                    let number = Int(endStr),
                    endStr.characters.count == 12,
                    number < endNumber
                {
                    ViewManager.showNotice(notice: "不能小于默认结束编码")
                }
            }else if textField == orderNumTextField{
                if
                    let orderStr = orderString,
                    let text = textField.text,
                    orderStr != text{
                    
                    self.orderString = nil
                    self.vm.deliverDirectCodeModel = DeliverDirectCodeModel()
                    self.startLabel.text = "自动获取"
                    self.endTextField.text = ""
                    
                    ViewManager.showNotice(notice: "请重新获取标签")
                }
            }else if textField == detailAddressTextField{
                
            }

            validate()
        }
    }
}
