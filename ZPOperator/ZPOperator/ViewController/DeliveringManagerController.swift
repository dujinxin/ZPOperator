//
//  DeliveringManagerController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class DeliveringManagerController: ZPTableViewController {

    var deliverModel : DeliverSubModel?
    var operatorModel : OperatorModel?
    
    var vm = DeliverManagerVM()
    
    var actionView : JXActionView?
    var alertView : JXAlertView?
    var selectView : JXSelectView?
    
    var addressHeight : CGFloat = 44.0
    var selectViewHeight : CGFloat = 44.0 * 6.0 + 88
    

    @IBOutlet weak var traceSourceButton: UIButton!
    @IBOutlet weak var sizeLabel: UIButton!
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var operatorLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    var batchId : Int = -2 //不做选择为-2，选择暂无溯源批次为 -1，大于0的已选的批次
    var batchArray = Array<String>()
    
    var sizeName : String?
    var sizeId : Int = -1
    //["溯源批次","标签规格","开始编码","结束编码","标签数量","操作网点","操作人"]
    let confirmTitleArray = [LanguageManager.localizedString("Ship.TracingBatch"),LanguageManager.localizedString("Ship.LabelSpecification"),LanguageManager.localizedString("Ship.StartCode"),LanguageManager.localizedString("Ship.EndCode"),LanguageManager.localizedString("Ship.LabelNumber"),LanguageManager.localizedString("Ship.Outlet"),LanguageManager.localizedString("Ship.Operator")]
    var confirmArray = Array<String>()
    var tagNum : Int = 0
    
    var deliveringManageBlock : ((_ isSuccess:Bool)->())?
    
    
    lazy var doneButton : UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth / 3, height: 53)
        button.setTitle(LanguageManager.localizedString("Done"), for: .normal)
        button.setTitleColor(JX333333Color, for: .normal)
        button.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
        
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.operatorLabel.text = UserManager.manager.userAccound.userName

        self.previewView.isUserInteractionEnabled = true
        self.previewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(codeSizePreview)))
        
        submitButton.layer.cornerRadius = 5
        submitButton.backgroundColor = JXGrayColor
        submitButton.isEnabled = false
        
        
        self.endTextField.keyboardType = .numberPad

        
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(notify:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notify:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notify:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
      
        
        self.vm.loadDeliveringBatch(batchId: deliverModel?.id as! Int) { (data, msg, isSuccess,code) in
            if isSuccess {
                self.startTextField.text = self.vm.deliverManagerModel.startCode
                self.endTextField.text = self.vm.deliverManagerModel.endCode
                self.numberLabel.text = String(format: "%d", self.vm.deliverManagerModel.counts)
                
                for modal in self.vm.deliverManagerModel.traceBatches {
                    self.batchArray.append(modal.name!)
                }
                self.batchArray.append(LanguageManager.localizedString("Trace.NoTracingBatches"))
            }else{
                self.traceSourceButton.isEnabled = false
                self.traceSourceButton.setTitle(LanguageManager.localizedString("Trace.NoTracingBatches"), for: .normal)
                
                if code == JXNetworkError.kResponseDeliverTagNotEnough {
                    let alert = UIAlertView(title: nil, message: msg, delegate: self, cancelButtonTitle: LanguageManager.localizedString("Confirm"))
                    alert.tag = 11
                    alert.show()
                }else{
                    ViewManager.showNotice(notice: msg)
                }
            }
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.doneButton.removeFromSuperview()
        self.hideKeyboard()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        if identifier ==  "traceSourceAdd" {
            let vc = segue.destination as! TraceSAddViewController
            vc.traceSAddBlock = {()->() in
                self.vm.loadDeliveringBatch(batchId: self.deliverModel?.id as! Int) { (data, msg, isSuccess,code) in
                    if isSuccess {
                        self.batchArray.removeAll()
                        for modal in self.vm.deliverManagerModel.traceBatches {
                            self.batchArray.append(modal.name!)
                        }
                        self.batchArray.append(LanguageManager.localizedString("Trace.NoTracingBatches"))
                    }else{
                        if code == JXNetworkError.kResponseDeliverTagNotEnough {
                            let alert = UIAlertView(title: nil, message: msg, delegate: self, cancelButtonTitle: LanguageManager.localizedString("Confirm"))
                            alert.tag = 11
                            alert.show()
                        }else{
                            ViewManager.showNotice(notice: msg)
                        }
                    }
                }
            }
            
        }
        
    }
    // MARK: - Custom Methods
    func codeSizePreview() {
        let customView = setSizeSelectView()
        let alertView = JXAlertView.init(frame: customView.bounds, style: .custom)
        alertView.customView = customView
        self.alertView = alertView
        self.alertView?.show()
    }
    @IBAction func deleveringManagerSelect(_ sender: UIButton) {
        self.view.endEditing(true)
        
        self.actionView = nil
        self.actionView = JXActionView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
        self.actionView?.isUseBottomView = true
        self.actionView?.delegate = self
        self.actionView?.actions = batchArray
        self.actionView?.tag = 10
        self.actionView?.show()
    }
    @IBAction func sizeSelect(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.vm.deliverManagerModel.codeSpecList.isEmpty == false {
            var titleArray = Array<String>()
            for model in self.vm.deliverManagerModel.codeSpecList {
                titleArray.append(model.desc!)
            }
            
            let actionView = JXActionView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
            actionView.isUseBottomView = true
            actionView.delegate = self
            actionView.actions = titleArray
            actionView.tag = 11
            actionView.show()
        } else {
            ViewManager.showNotice(notice: LanguageManager.localizedString("Ship.NotEnoughLabel"))
            return
        }
    }
    
    @IBAction func submit(_ sender: UIButton) {
        
        startTextField.resignFirstResponder()
        endTextField.resignFirstResponder()
        
        if sizeLabel.currentTitle?.isEmpty == true {
            ViewManager.showNotice(notice: LanguageManager.localizedString("SelectSpec"))
            return
        }
        
        if
            let startCode = self.startTextField.text,
            let endCode = self.endTextField.text,
            let station = self.operatorModel?.station,
            let name = self.operatorModel?.name
        {
            if String.validateCode(code: endCode) == false {
                ViewManager.showNotice(notice: LanguageManager.localizedString("Label.Notice2"))
                return
            }
            if Int(endCode)! < Int(self.vm.deliverManagerModel.endCode!)!{
                ViewManager.showNotice(notice: "End code can not be less than the default code")
                return
            }
            self.confirmArray.removeAll()
            self.confirmArray.append(String.init(format: "%@", self.traceSourceButton.currentTitle ?? LanguageManager.localizedString("Trace.NoTracingBatches")))
            self.confirmArray.append(String.init(format: "%@", self.sizeName ?? "Error"))
            self.confirmArray.append(String.init(format: "%@", startCode))
            self.confirmArray.append(String.init(format: "%@", endCode))
            self.confirmArray.append(String.init(format: "%d", self.vm.deliverManagerModel.counts))
            self.confirmArray.append(String.init(format: "%@", station))
            self.confirmArray.append(String.init(format: "%@", name))
            
            setSelectView()
            self.selectView?.resetFrame(height: CGFloat(44 * self.confirmTitleArray.count + 88))
            self.selectView?.show()
        }
    }
    func observeButtonEnabled() {
        if let _ = self.sizeName, endTextField.text?.isEmpty == false{
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
            label.text = LanguageManager.localizedString("Ship.ConfirmShippingInformation")
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
        separateLine.backgroundColor = JXSeparatorColor
        contentView.addSubview(separateLine)
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: H + 10, width: contentView.frame.width, height: 44)
        button.setTitle(LanguageManager.localizedString("Confirm"), for: .normal)
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
    func setSelectView() {
        selectView = nil
        selectView = JXSelectView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 200), style:.list)
        selectView?.dataSource = self
        selectView?.topBarView = {
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 260))
            view.backgroundColor = JX999999Color
            
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 59.5)
            label.backgroundColor = UIColor.white
            //label.center = view.center
            label.text = LanguageManager.localizedString("Ship.ConfirmShippingCode")
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
    }
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            
            let contentView = UIView()
            contentView.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: 30)
            
            
            let titleLabel = UILabel()
            titleLabel.frame = CGRect.init(x: 15, y: 0, width: view.frame.width - 30, height: 30)
            titleLabel.text = "End code can be modified to a larger number"//结束编码可被修改为更大数值
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
        if section == 0 {
            return 0
        }else if section == 1 || section == 3 {
            return 10
        }else if section == 2{
            return 30
        }else{
            return 64
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            self.view.endEditing(true)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension DeliveringManagerController : JXActionViewDelegate,UIAlertViewDelegate{
    func jxActionView(_ actionView: JXActionView, clickButtonAtIndex index: Int) {
        
        if actionView.tag == 10 {
            if index < self.vm.deliverManagerModel.traceBatches.count {
                let model = self.vm.deliverManagerModel.traceBatches[index]
                self.traceSourceButton.setTitle(model.name, for: .normal)
                batchId = model.id
            }else{
                let alert = UIAlertView.init(title: LanguageManager.localizedString("Notice.NoTracingBatchesNotice"), message: "", delegate: self, cancelButtonTitle: LanguageManager.localizedString("Ship.AddTracingInformation"), otherButtonTitles: LanguageManager.localizedString("Confirm"))
                alert.tag = 10
                alert.show()
            }
        } else if actionView.tag == 11 {
            if self.vm.deliverManagerModel.codeSpecList.count > 1 && self.vm.deliverManagerModel.codeSpecList[index].id != self.sizeId{
                self.vm.fetchDeliveryCode(batchId: self.deliverModel?.id as! Int, codeSpecId: self.vm.deliverManagerModel.codeSpecList[index].id, completion: { (data, msg, isSuccess) in
                    if isSuccess {
                        self.startTextField.text = self.vm.deliverManagerModel.startCode
                        self.endTextField.text = self.vm.deliverManagerModel.endCode
                    } else {
                        ViewManager.showNotice(notice: msg)
                    }
                })
            }
            self.sizeName = self.vm.deliverManagerModel.codeSpecList[index].desc
            self.sizeId = self.vm.deliverManagerModel.codeSpecList[index].id
            self.sizeLabel.setTitle(self.vm.deliverManagerModel.codeSpecList[index].desc, for: .normal)
        }
        self.observeButtonEnabled()
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == 10 {
            if buttonIndex == 0 {
                self.performSegue(withIdentifier: "traceSourceAdd", sender: nil)
            }else{
                batchId = -1
                self.traceSourceButton.setTitle(LanguageManager.localizedString("Trace.NoTracingBatches"), for: .normal)
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    func dismissAlertView() {
        self.alertView?.dismiss()
    }
    func dismissSelectView() {
        self.selectView?.dismiss()
    }
    func confirmDeliver() {
     
        self.selectView?.dismiss()
        self.showMBProgressHUD()
        self.vm.deliveringManagerSubmit(id: deliverModel?.id as! Int, traceBatchId: batchId, startCode: startTextField.text!, endCode: endTextField.text!, counts: self.vm.deliverManagerModel.counts, codeSpecId: self.sizeId) { (data, msg, isSuccess) in
            
            self.hideMBProgressHUD()
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
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.startTextField {
            return false
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        //获得键盘所在的window视图
//        let array = UIApplication.shared.windows
//        for w in array {
//            
//            let str =  NSStringFromClass(type(of: w))    //NSStringFromClass(w.self)
//            if str == "UIRemoteKeyboardWindow" && self.doneButton.superview == nil{
//                w.addSubview(self.doneButton)
//            }
//        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let s = textField.text! as NSString
        
        if range.location > 11 {
            
            let str = s.substring(to: 11)
            textField.text = str
            ViewManager.showNotice(notice: "The number of characters can not be greater than 12")
            
//            if let string = textField.text?.replacingCharacters(in: range, with: string) {
//                textField.text = string.substring(to: string.index(string.startIndex, offsetBy: 20))
//                
//                ViewManager.showNotice(notice: "字符个数不能大于20")
//            }
        }
        return true
    }
    
    func textChange(notify:NSNotification) {
        
        if  notify.object is UITextField,
            let endStr = endTextField.text,
            let endCode = self.vm.deliverManagerModel.endCode,
            let endNumber = Int(endCode),
            let number = Int(endStr),
            endStr.count == 12,
            batchId > -2
        {
            
            if number >= endNumber {
                submitButton.backgroundColor = JXOrangeColor
                submitButton.isEnabled = true
            }else{
                ViewManager.showNotice(notice: "End code can not be less than the default code")
            }
        }else{
            submitButton.backgroundColor = JXGrayColor
            submitButton.isEnabled = false
        }
    }
    // 键盘出现处理事件
    func keyboardWillShow(notify:Notification) {
        //获得键盘所在的window视图
        if self.doneButton.superview == nil {
            let array = UIApplication.shared.windows
            for w in array {
                
                let str =  NSStringFromClass(type(of: w))    //NSStringFromClass(w.self)
                if str == "UIRemoteKeyboardWindow"{
                    self.doneButton.alpha = 0
                    w.addSubview(self.doneButton)
                }
            }
        }

        if
            let userInfo = notify.userInfo,
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval
            //,let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UIViewAnimationCurve
            {
        
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(duration)
            //UIView.setAnimationCurve(animationCurve)
        
            self.doneButton.alpha = 1
            //self.doneButton.transform = CGAffineTransform(translationX: 0, y: -53)
            self.doneButton.frame = CGRect(x: 0, y: kScreenHeight - 53, width: kScreenWidth / 3, height: 53)
            UIView.commitAnimations()
        }
    }
    func keyboardWillHide(notify:Notification) {
        if
            let userInfo = notify.userInfo,
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval
            //,let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UIViewAnimationCurve
        {
            if (self.doneButton.superview != nil) {
                UIView.animate(withDuration: duration, animations: {
                    //self.doneButton.transform = CGAffineTransform(translationX: 0, y: 53)
                    self.doneButton.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth / 3, height: 53)
                }, completion: { (finished) in
                    self.doneButton.removeFromSuperview()
                })
            }
        }
    }
    func hideKeyboard() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}
extension DeliveringManagerController: JXSelectViewDataSource{
    func jxSelectView(jxSelectView: JXSelectView, numberOfRowsInSection section: Int) -> Int {
        return self.confirmTitleArray.count + 1
    }
    func jxSelectView(jxSelectView: JXSelectView, contentForRow row: Int, InSection section: Int) -> String {
        if row < self.confirmTitleArray.count {
            return self.confirmArray[row]
        }else {
            return ""
        }
    }
    func jxSelectView(jxSelectView: JXSelectView, heightForRowAt row: Int) -> CGFloat {
        
        if row < self.confirmTitleArray.count{
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
    func jxSelectView(jxSelectView: JXSelectView, viewForRow row: Int) -> UIView? {
        var view : UIView?
        
        if row < self.confirmTitleArray.count{
            view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 44))
            
            let leftLabel = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: 100, height: 44))
            leftLabel.textColor = JX999999Color
            leftLabel.textAlignment = .left
            leftLabel.font = UIFont.systemFont(ofSize: 14)
            leftLabel.text = self.confirmTitleArray[row]
            view?.addSubview(leftLabel)
            
            let rightLabel = UILabel.init(frame: CGRect.init(x: 120, y: 0, width: kScreenWidth - 120 - 20, height: 44))
            rightLabel.textColor = JX333333Color
            rightLabel.textAlignment = .left
            rightLabel.font = UIFont.systemFont(ofSize: 13)
            rightLabel.text = self.confirmArray[row]
            view?.addSubview(rightLabel)
            
            
        }else{
 
            let button = UIButton()
            button.frame = CGRect.init(x: 40, y: 22, width: kScreenWidth - 80, height: 44)
            button.setTitle(LanguageManager.localizedString("Confirm"), for: UIControlState.normal)
            button.setTitleColor(UIColor.white, for: UIControlState.normal)
            button.backgroundColor = JXOrangeColor
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
        return view
    }
}
