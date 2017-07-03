//
//  DeliveringViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/21.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import MJRefresh

class DeliveringViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource{
    
    var tableView = UITableView.init(frame: CGRect.zero, style: .plain)
    var vm = TraceDeliverVM()
    var selectView : JXSelectView?
    var deliveringModel : TraceDeliverSubModel?
    
    var address1Height : CGFloat = 44.0
    var address2Height : CGFloat = 44.0
    var remarkHeight : CGFloat = 44.0
    var selectViewHeight : CGFloat = 44.0 * 6.0 + 29.0
    
    var addressStr : String = ""
    
    var deliveringBlock : ((_ deliveringModel:TraceDeliverSubModel,_ deliverOperatorModel:TraceDeliverOperatorModel)->())?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.groupTableViewBackground
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.frame = view.bounds
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier1")
        self.tableView.tableFooterView = UIView()
        view.addSubview(self.tableView)
        
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            
            self.vm.loadMainData(batchStatus: 0) { (data, msg, isSuccess) in
                self.tableView.mj_header.endRefreshing()
                if isSuccess{
                    self.tableView.reloadData()
                }else{
                    print(msg)
                }
            }
        })
        self.tableView.mj_header.beginRefreshing()
        
        selectView = JXSelectView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 200), style:.list)
        selectView?.dataSource = self
        selectView?.isUseTopBar = false
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationStatus(notify:)), name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: nil)
        
        //开启定位
        JXLocationManager.manager.startUpdateLocation()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return vm.traceDeliverModel.batches.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //1.才用这种方式，cell不需要提前注册，拿不到的话会走if;如果注册，且可以正确获取，那么不走if
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        //2.才用这种，cell必须提前注册，不注册会crash,而且注册后获取不到cell也会crash，不走if(总之不能自定义UITableViewCellStyle)
        //var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        if cell == nil {
            
            cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "reuseIdentifier")
        }
        let model = self.vm.traceDeliverModel.batches[indexPath.row]
        // Configure the cell...
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = model.goodsName
        cell?.textLabel?.textColor = UIColor.red
        cell?.detailTextLabel?.text = model.remarks

        return cell!
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.vm.traceDeliverModel.batches[indexPath.row]
        deliveringModel = model
        self.selectView?.resetFrame(height: calculateHeight(model: model))
        
        selectView?.show()
    }
    
    func calculateHeight(model:TraceDeliverSubModel) -> CGFloat {
        
        address1Height = 30.0 + 14 + calculateHeight(string: self.addressStr)
        if let province = deliveringModel?.province,
            let city = deliveringModel?.city,
            let county = deliveringModel?.county,
            let address = deliveringModel?.address{
            
            let detailAddress = province + city + county + address
            address2Height = 30 + calculateHeight(string: detailAddress)
        }

        if let remark = deliveringModel?.remarks {
            remarkHeight = 30 + calculateHeight(string: remark)
        }
        
        selectViewHeight = 44.0  + address1Height + address2Height + remarkHeight + 88.0
        return selectViewHeight
    }
    func calculateHeight(string:String?,width:CGFloat = kScreenWidth - 90,fontSize:CGFloat = 14) -> CGFloat {
        guard let contentStr = string  else{
            return 14
        }
        let height = contentStr.calculate(width: width, fontSize: fontSize, lineSpace: 5).height
        if height < CGFloat(20) {
            return 14
        }else{
            return height
        }
    }
}

extension DeliveringViewController: JXSelectViewDataSource{
    func jxSelectView(_: JXSelectView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func jxSelectView(_: JXSelectView, contentForRow row: Int, InSection section: Int) -> String {
        if let batch = deliveringModel?.Batch,
            row == 0
        {
            return "发货批次号：" + batch
        }
        return "测试\(row)"
    }
    func jxSelectView(_: JXSelectView, heightForRowAt row: Int) -> CGFloat {
        
        if row == 0{
            return 44
        }else if row == 1{
            return address1Height
        }else if row == 2{
            return address2Height
        }else if row == 3 {
            return remarkHeight
        }else{
            return 88
        }
    }
    func jxSelectView(_: JXSelectView, viewForRow row: Int) -> UIView? {
        var view : UIView?
        let titleArray = ["发货","收货","备注"]
        
        if row == 1 || row == 2 || row == 3{
            view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 44))
            
            let leftLabel = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: 40, height: 44))
            leftLabel.textColor = UIColor.black
            leftLabel.textAlignment = .left
            leftLabel.font = UIFont.systemFont(ofSize: 14)
            leftLabel.text = titleArray[row - 1]
            view?.addSubview(leftLabel)

        }else if row == 4{
            
            let button = UIButton()
            button.frame = CGRect.init(x: 40, y: 22, width: kScreenWidth - 80, height: 44)
            button.setTitle("确认发货批次", for: UIControlState.normal)
            button.setTitleColor(UIColor.white, for: UIControlState.normal)
            button.backgroundColor = UIColor.orange
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(confirmDeliver), for: UIControlEvents.touchUpInside)
            return button
            
        }else{
            let leftLabel = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: kScreenWidth - 40, height: 44))
            leftLabel.textColor = UIColor.black
            leftLabel.textAlignment = .left
            leftLabel.font = UIFont.systemFont(ofSize: 14)
            leftLabel.text = "发货批次号："
            if let batchCode = deliveringModel?.batchCode{
                leftLabel.text = "发货批次号：" + batchCode
            }
            return leftLabel
            
        }
        
        if row == 1 {
            view?.frame =  CGRect.init(x: 0, y: 0, width: kScreenWidth, height: address1Height)
            let rightLabel = UILabel.init(frame: CGRect.init(x: 80, y: 15, width: kScreenWidth - 90, height: 14))
            rightLabel.textColor = UIColor.black
            rightLabel.textAlignment = .left
            rightLabel.font = UIFont.systemFont(ofSize: 14)
            if let goodsName = deliveringModel?.goodsName,
               let counts = deliveringModel?.counts{
                rightLabel.text = goodsName + "      " + counts
            }
            view?.addSubview(rightLabel)
            
            let addressLabel = UILabel.init(frame: CGRect.init(x: 80, y: 30, width: kScreenWidth - 90, height: address1Height - 30))
            addressLabel.textColor = UIColor.black
            addressLabel.textAlignment = .left
            addressLabel.font = UIFont.systemFont(ofSize: 14)
            addressLabel.numberOfLines = 0
            addressLabel.text = self.addressStr
            view?.addSubview(addressLabel)
        }
        
        if row == 2 {
            view?.frame =  CGRect.init(x: 0, y: 0, width: kScreenWidth, height: address2Height)
            let addressLabel = UILabel.init(frame: CGRect.init(x: 80, y: 0, width: kScreenWidth - 90, height: address2Height))
            addressLabel.textColor = UIColor.black
            addressLabel.textAlignment = .left
            addressLabel.font = UIFont.systemFont(ofSize: 14)
            addressLabel.numberOfLines = 0
            if let province = deliveringModel?.province,
                let city = deliveringModel?.city,
                let county = deliveringModel?.county,
                let address = deliveringModel?.address{
                
                addressLabel.text = province + city + county + address
            }

            
            view?.addSubview(addressLabel)
        }
        
        if row == 3 {
            view?.frame =  CGRect.init(x: 0, y: 0, width: kScreenWidth, height: remarkHeight)
            let addressLabel = UILabel.init(frame: CGRect.init(x: 80, y: 0, width: kScreenWidth - 90, height: remarkHeight))
            addressLabel.textColor = UIColor.black
            addressLabel.textAlignment = .left
            addressLabel.font = UIFont.systemFont(ofSize: 14)
            addressLabel.numberOfLines = 0
            if let remarks = deliveringModel?.remarks {
                addressLabel.text = remarks
            }else{
                addressLabel.text = "暂无"
            }
            
            view?.addSubview(addressLabel)
        }
        return view
    }
    
    func confirmDeliver() {
        self.selectView?.dismiss()
        if let block = deliveringBlock {
            block(deliveringModel!,self.vm.traceDeliverModel.Operator)
        }
        
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let dmVC = storyboard.instantiateViewController(withIdentifier: "deliveringManager")
//        
//        self.navigationController?.pushViewController(dmVC, animated: true)
        //dmVC.performSegue(withIdentifier: "deliveringManager", sender: deliveringModel)
        
        ///performSegue(withIdentifier: "deliveringManager", sender: deliveringModel)
    }
}
extension DeliveringViewController {
    func locationStatus(notify:Notification) {
        print(notify)
        
        guard let isSuccess = notify.object as? Bool else {
            return
        }
        if isSuccess {
            self.addressStr = JXLocationManager.manager.address
        }else{
            if let stationName = deliveringModel?.stationName{
                self.addressStr = stationName
            }
        }
        
    }
}
