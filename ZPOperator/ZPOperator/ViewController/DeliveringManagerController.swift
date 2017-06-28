//
//  DeliveringManagerController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/26.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class DeliveringManagerController: UITableViewController {

    var deliverModel : TraceDeliverModel?
    var vm = DeliveringManagerVM()
    
    var selectView : JXSelectView?
    var addressHeight : CGFloat = 44.0
    var selectViewHeight : CGFloat = 44.0 * 6.0 + 88
    

    @IBOutlet weak var traceSourceButton: UIButton!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var operatorLabel: UILabel!
    
    
    @IBOutlet weak var submitButton: UIButton!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.operatorLabel.text = LoginVM.loginVMManager.userModel.userName
        
        selectView = JXSelectView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 200), style:.list)
        selectView?.dataSource = self
        selectView?.isUseTopBar = true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: nil)
    }
    

    @IBAction func deleveringManagerSelect(_ sender: UIButton) {
    }
    @IBAction func submit(_ sender: UIButton) {
        
        //self.selectView?.resetFrame(height: calculateHeight(model: model))
        self.selectView?.resetFrame(height: selectViewHeight)
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

extension DeliveringManagerController: JXSelectViewDataSource{
    func jxSelectView(_: JXSelectView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func jxSelectView(_: JXSelectView, contentForRow row: Int, InSection section: Int) -> String {
        return "测试\(row)"
    }
    func jxSelectView(_: JXSelectView, heightForRowAt row: Int) -> CGFloat {
        
        if row == 4{
            return addressHeight
        }else if row == 6{
            return 88
        }else{
            return 44
        }
    }
    func jxSelectView(_: JXSelectView, viewForRow row: Int) -> UIView? {
        var view : UIView?
        let titleArray = ["溯源批次","开始编码","结尾编码","标签数量","操作网点","操作人"]
        let detailArray = ["溯源批次","开始编码","结尾编码","标签数量","操作网点","操作人"]
        
        if row != 6{
            view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: addressHeight))
            
            let leftLabel = UILabel.init(frame: CGRect.init(x: 10, y: 0, width: 60, height: 44))
            leftLabel.textColor = UIColor.black
            leftLabel.textAlignment = .center
            leftLabel.font = UIFont.systemFont(ofSize: 14)
            leftLabel.text = titleArray[row]
            view?.addSubview(leftLabel)
            
            let addressLabel = UILabel.init(frame: CGRect.init(x: 80, y: 0, width: UIScreen.main.bounds.width - 90, height: addressHeight))
            addressLabel.textColor = UIColor.black
            addressLabel.textAlignment = .left
            addressLabel.font = UIFont.systemFont(ofSize: 14)
            addressLabel.numberOfLines = 0
            addressLabel.text = detailArray[row]
            view?.addSubview(addressLabel)
            
        }else {
            
            let button = UIButton()
            button.frame = CGRect.init(x: 40, y: 22, width: UIScreen.main.bounds.width - 80, height: 44)
            button.setTitle("确认发货编码", for: UIControlState.normal)
            button.setTitleColor(UIColor.white, for: UIControlState.normal)
            button.backgroundColor = UIColor.orange
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(confirmDeliver), for: UIControlEvents.touchUpInside)
            return button
            
        }

        return view
    }
    
    func confirmDeliver() {
//        self.selectView?.dismiss()
//        if let block = block {
//            block(deliveringModel!)
//        }
        
//        self.vm.deliveringManagerSubmit(id: deliverModel?.id as! Int, traceBatchId: <#T##Int#>, startCode: <#T##String#>, endCode: <#T##String#>, counts: <#T##Int#>, completion: <#T##((Any?, String, Bool) -> ())##((Any?, String, Bool) -> ())##(Any?, String, Bool) -> ()#>)
    }
}

