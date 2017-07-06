//
//  DeliveringManagerController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import MBProgressHUD

class DeliveringManagerController: ZPTableViewController {

    var deliverModel : TraceDeliverSubModel?
    var deliverOperatorModel : TraceDeliverOperatorModel?
    
    var vm = DeliveringManagerVM()
    
    var selectView : JXSelectView?
    var jxAlertView : JXAlertView?
    var addressHeight : CGFloat = 44.0
    var selectViewHeight : CGFloat = 44.0 * 6.0 + 88
    

    @IBOutlet weak var traceSourceButton: UIButton!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var operatorLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    var batchId : Int = -1
    var batchArray = Array<String>()
    var confirmArray = Array<String>()
    var tagNum : Int = 0
    
    var deliveringManageBlock : ((_ isSuccess:Bool)->())?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.operatorLabel.text = LoginVM.loginVMManager.userModel.userName
        
        submitButton.layer.cornerRadius = 5
        submitButton.backgroundColor = UIColor.gray
        submitButton.isEnabled = false
        
        self.jxAlertView = JXAlertView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
        
        self.jxAlertView?.position = .bottom
        self.jxAlertView?.isSetCancelView = true
        self.jxAlertView?.delegate = self
        
        selectView = JXSelectView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 200), style:.list)
        selectView?.dataSource = self
        selectView?.topBarView = {
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 260))
            view.backgroundColor = JX999999Color
            
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 59.5)
            label.backgroundColor = UIColor.white
            //label.center = view.center
            label.text = "确认发货编号"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 18)
            label.textColor = JX333333Color
            view.addSubview(label)
            //label.sizeToFit()
            
            let button = UIButton()
            button.frame = CGRect(x: 10, y: 8.5, width: 40, height: 40)
            //button.center = CGPoint(x: 30, y: view.jxCenterY)
            button.setTitle("×", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            button.setTitleColor(JX333333Color, for: .normal)
            button.contentVerticalAlignment = .center
            button.contentHorizontalAlignment = .center
            button.addTarget(self, action: #selector(dismissSelectView), for: .touchUpInside)
            view.addSubview(button)
            
            return view
        }()
        selectView?.isUseTopBar = true
        selectView?.isEnabled = false
        selectView?.isScrollEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(notify:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        self.vm.loadDeliveringBatch(batchId: deliverModel?.id as! Int) { (data, msg, isSuccess) in
            if isSuccess {
                for modal in self.vm.deliveringBatches {
                    self.batchArray.append(modal.name!)
                }
                self.batchArray.append("暂无溯源批次")
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        if identifier ==  "traceSourceAdd" {
            let vc = segue.destination as! TraceSAddViewController
            vc.traceSAddBlock = {()->() in
                self.vm.loadDeliveringBatch(batchId: self.deliverModel?.id as! Int) { (data, msg, isSuccess) in
                    if isSuccess {
                        self.batchArray.removeAll()
                        for modal in self.vm.deliveringBatches {
                            self.batchArray.append(modal.name!)
                        }
                        self.batchArray.append("暂无溯源批次")
                    }
                }
            }
            
        }
        
    }
    

    @IBAction func deleveringManagerSelect(_ sender: UIButton) {
        self.jxAlertView?.actions = batchArray
        self.jxAlertView?.show()
    }
    @IBAction func submit(_ sender: UIButton) {
        
        startTextField.resignFirstResponder()
        endTextField.resignFirstResponder()
        
        self.confirmArray.removeAll()
        self.confirmArray.append(String.init(format: "溯源批次：%@", (self.traceSourceButton.currentTitle)!))
        self.confirmArray.append(String.init(format: "开始编码：%@", self.startTextField.text!))
        self.confirmArray.append(String.init(format: "结束编码：%@", self.endTextField.text!))
        self.confirmArray.append(String.init(format: "标签数量：%ld", self.tagNum))
        self.confirmArray.append(String.init(format: "操作网点：%@", (self.deliverOperatorModel?.station)!))
        self.confirmArray.append(String.init(format: "操作人：%@", (self.deliverOperatorModel?.name)!))
        
        self.selectView?.resetFrame(height: 44 * 6 + 88)
        self.selectView?.show()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            
            let contentView = UIView()
            contentView.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: 30)
            
            
            let titleLabel = UILabel()
            titleLabel.frame = CGRect.init(x: 15, y: 0, width: view.frame.width - 30, height: 30)
            titleLabel.text = "输入已按顺序贴码标签的编码"
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            titleLabel.textAlignment = .left
            titleLabel.textColor = UIColor.black
            
            contentView.addSubview(titleLabel)
            
            return contentView
        }else{
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else if section == 1 {
            return 30
        }else if section == 2 || section == 3 {
            return 10
        }else{
            return 64
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension DeliveringManagerController : JXAlertViewDelegate,UIAlertViewDelegate{
    func jxAlertView(_ alertView: JXAlertView, clickButtonAtIndex index: Int) {
        if index < self.vm.deliveringBatches.count {
            let model = self.vm.deliveringBatches[index]
            self.traceSourceButton.setTitle(model.name, for: .normal)
            batchId = model.id as! Int
        }else{
            let alert = UIAlertView.init(title: "暂无溯源批次，仍然发货？", message: "", delegate: self, cancelButtonTitle: "添加溯源", otherButtonTitles: "确定")
            alert.show()
            
        }
        
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            //
            print("添加溯源")
            
            self.performSegue(withIdentifier: "traceSourceAdd", sender: nil)
        }else{
            batchId = -1
            self.traceSourceButton.setTitle("暂无溯源批次", for: .normal)
            print("发货")
        }
    }
    func dismissSelectView() {
        self.selectView?.dismiss()
    }
    func confirmDeliver() {
     
        self.selectView?.dismiss()
        MBProgressHUD.showAdded(to: self.view, animated: true)
        self.vm.deliveringManagerSubmit(id: deliverModel?.id as! Int, traceBatchId: batchId, startCode: startTextField.text!, endCode: endTextField.text!, counts: tagNum) { (data, msg, isSuccess) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            ViewManager.showNotice(notice: msg)
            if isSuccess{
                if let block = self.deliveringManageBlock {
                    block(true)
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension DeliveringManagerController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let s = textField.text! as NSString
        
        if range.location > 11 {
            
            let str = s.substring(to: 11)
            textField.text = str
            ViewManager.showNotice(notice: "字符个数不能大于12")
            
//            if let string = textField.text?.replacingCharacters(in: range, with: string) {
//                textField.text = string.substring(to: string.index(string.startIndex, offsetBy: 20))
//                
//                ViewManager.showNotice(notice: "字符个数不能大于20")
//            }
        }
        return true
    }
    
    func textChange(notify:NSNotification) {
        
        if notify.object is UITextField {
            if startTextField.text?.characters.count == 12 && endTextField.text?.characters.count != 0{
                if let startNum = Int(startTextField.text!),
                    let endNum = Int(endTextField.text!){
                    if endNum >= startNum {
                        numberLabel.text = String(endNum - startNum + 1)
                        numberLabel.textColor = UIColor.black
                        submitButton.backgroundColor = UIColor.originColor
                        submitButton.isEnabled = true
                        tagNum = endNum - startNum + 1
                    }else{
                        numberLabel.text = String(endNum - startNum + 1)
                        numberLabel.textColor = UIColor.red
                        submitButton.backgroundColor = UIColor.gray
                        submitButton.isEnabled = false
                    }
                }else{
                    submitButton.backgroundColor = UIColor.gray
                    submitButton.isEnabled = false
                }
                
                
            }else{
                submitButton.backgroundColor = UIColor.gray
                submitButton.isEnabled = false
            }
        }
    }
}
extension DeliveringManagerController: JXSelectViewDataSource{
    func jxSelectView(_: JXSelectView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func jxSelectView(_: JXSelectView, contentForRow row: Int, InSection section: Int) -> String {
        if row < 6 {
            return confirmArray[row]
        }else {
            return ""
        }
    }
    func jxSelectView(_: JXSelectView, heightForRowAt row: Int) -> CGFloat {
        
        if row < 6{
            return 44
        }
//        else if row == 1{
//            return address1Height
//        }else if row == 2{
//            return address2Height
//        }else if row == 3 {
//            return remarkHeight
//        }
        else{
            return 88
        }
    }
    func jxSelectView(_: JXSelectView, viewForRow row: Int) -> UIView? {
//        var view : UIView?
//        let titleArray = ["发货","收货","备注"]
//        
//        if row == 1 || row == 2 || row == 3{
//            view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 44))
//            
//            let leftLabel = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: 40, height: 44))
//            leftLabel.textColor = UIColor.black
//            leftLabel.textAlignment = .left
//            leftLabel.font = UIFont.systemFont(ofSize: 14)
//            leftLabel.text = titleArray[row - 1]
//            view?.addSubview(leftLabel)
//            
//        }else
            if row == 6{
            
            let button = UIButton()
            button.frame = CGRect.init(x: 40, y: 22, width: kScreenWidth - 80, height: 44)
            button.setTitle("确认发货批次", for: UIControlState.normal)
            button.setTitleColor(UIColor.white, for: UIControlState.normal)
            button.backgroundColor = UIColor.orange
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(confirmDeliver), for: UIControlEvents.touchUpInside)
            return button
            
        }
//            else{
//            let leftLabel = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: kScreenWidth - 40, height: 44))
//            leftLabel.textColor = UIColor.black
//            leftLabel.textAlignment = .left
//            leftLabel.font = UIFont.systemFont(ofSize: 14)
//            leftLabel.text = "发货批次号："
//            if let batchCode = deliveringModel?.batchCode{
//                leftLabel.text = "发货批次号：" + batchCode
//            }
//            return leftLabel
//            
//        }
//        
//        if row == 1 {
//            view?.frame =  CGRect.init(x: 0, y: 0, width: kScreenWidth, height: address1Height)
//            let rightLabel = UILabel.init(frame: CGRect.init(x: 80, y: 15, width: UIScreen.main.bounds.width - 90, height: 14))
//            rightLabel.textColor = UIColor.black
//            rightLabel.textAlignment = .left
//            rightLabel.font = UIFont.systemFont(ofSize: 14)
//            if let goodsName = deliveringModel?.goodsName,
//                let counts = deliveringModel?.counts{
//                rightLabel.text = goodsName + "      " + counts
//            }
//            view?.addSubview(rightLabel)
//            
//            let addressLabel = UILabel.init(frame: CGRect.init(x: 80, y: 30, width: UIScreen.main.bounds.width - 90, height: address1Height - 30))
//            addressLabel.textColor = UIColor.black
//            addressLabel.textAlignment = .left
//            addressLabel.font = UIFont.systemFont(ofSize: 14)
//            addressLabel.numberOfLines = 0
//            addressLabel.text = self.addressStr
//            view?.addSubview(addressLabel)
//        }
//        
//        if row == 2 {
//            view?.frame =  CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: address2Height)
//            let addressLabel = UILabel.init(frame: CGRect.init(x: 80, y: 0, width: UIScreen.main.bounds.width - 90, height: address2Height))
//            addressLabel.textColor = UIColor.black
//            addressLabel.textAlignment = .left
//            addressLabel.font = UIFont.systemFont(ofSize: 14)
//            addressLabel.numberOfLines = 0
//            if let province = deliveringModel?.province,
//                let city = deliveringModel?.city,
//                let county = deliveringModel?.county,
//                let address = deliveringModel?.address{
//                
//                addressLabel.text = province + city + county + address
//            }
//            
//            
//            view?.addSubview(addressLabel)
//        }
//        
//        if row == 3 {
//            view?.frame =  CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: remarkHeight)
//            let addressLabel = UILabel.init(frame: CGRect.init(x: 80, y: 0, width: UIScreen.main.bounds.width - 90, height: remarkHeight))
//            addressLabel.textColor = UIColor.black
//            addressLabel.textAlignment = .left
//            addressLabel.font = UIFont.systemFont(ofSize: 14)
//            addressLabel.numberOfLines = 0
//            if let remarks = deliveringModel?.remarks {
//                addressLabel.text = remarks
//            }else{
//                addressLabel.text = "暂无"
//            }
//            
//            view?.addSubview(addressLabel)
//        }
        return nil
    }
}
