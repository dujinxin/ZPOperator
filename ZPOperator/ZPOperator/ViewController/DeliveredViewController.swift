//
//  DeliveredViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/21.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import MJRefresh

class DeliveredViewController: ZPTableViewController {

    var vm = TraceDeliverVM()
    
    
    var deliveredBlock : ((_ deliveringModel:TraceDeliverSubModel,_ deliverOperatorModel:TraceDeliverOperatorModel)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.groupTableViewBackground
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        
        
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            
            self.vm.loadMainData(batchStatus: 1) { (data, msg, isSuccess) in
                self.tableView.mj_header.endRefreshing()
                if isSuccess{
                    self.tableView.reloadData()
                }else{
                    ViewManager.showNotice(notice: msg)
                }
            }
        })
        self.tableView.mj_header.beginRefreshing()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.vm.traceDeliverModel.batches.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
    
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "reuseIdentifier")
            cell?.accessoryType = .disclosureIndicator
        }
        
        // Configure the cell...
        let model = self.vm.traceDeliverModel.batches[indexPath.row]
        
        cell?.textLabel?.text = model.goodsName
        cell?.detailTextLabel?.text = model.remarks
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.vm.traceDeliverModel.batches[indexPath.row]
        
        if let block = deliveredBlock {
            block(model,self.vm.traceDeliverModel.Operator)
        }
    }
}
