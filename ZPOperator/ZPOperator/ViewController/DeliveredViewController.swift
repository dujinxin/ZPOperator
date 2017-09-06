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
    var currentPage = 1
    
    var deliveredBlock : ((_ deliveringModel:TraceDeliverSubModel,_ deliverOperatorModel:TraceDeliverOperatorModel)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.groupTableViewBackground
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: UIScreen.main.bounds.height - kNavStatusHeight - 54)
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.rowHeight = 54
        self.tableView.register(UINib.init(nibName: "DeliverListCell", bundle: Bundle.main), forCellReuseIdentifier: "reuseIdentifier")
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            self.currentPage = 1
            self.loadData(page: 1)
        })
        self.tableView.mj_footer = MJRefreshBackFooter.init(refreshingBlock: {
            self.currentPage += 1
            self.loadData(page: self.currentPage)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? DeliverListCell
        cell?.contentView.backgroundColor = UIColor.white
        // Configure the cell...
        let model = self.vm.traceDeliverModel.batches[indexPath.row]
        
        cell?.TitleLabel.text = model.goodsName
        cell?.DetailTitleLabel.text = model.remarks
    
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
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.vm.traceDeliverModel.batches[indexPath.row]
        
        if let block = deliveredBlock {
            block(model,self.vm.traceDeliverModel.Operator)
        }
    }
    func loadData(page:Int) {
        
        self.vm.loadMainData(page: page,batchStatus: 1) { (data, msg, isSuccess) in
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            if isSuccess{
                self.tableView.reloadData()
            }else{
                print(msg)
            }
        }
    }
}
