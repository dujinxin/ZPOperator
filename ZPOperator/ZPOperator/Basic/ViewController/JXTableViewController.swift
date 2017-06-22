//
//  JXTableViewController.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/6/7.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

class JXTableViewController: BaseViewController{

    //tableview
    var tableView : UITableView?
    //refreshControl
    var refreshControl : UIRefreshControl?
    //data array
    var dataArray = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //isLogin ? setUpTableView() : setUpDefaultView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension JXTableViewController : UITableViewDelegate,UITableViewDataSource{
    
    override func setUpMainView() {
        setUpTableView()
    }
    
    func setUpTableView(){
        
        self.tableView = UITableView(frame: self.view.bounds, style: .plain)
        self.tableView?.backgroundColor = UIColor.groupTableViewBackground
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        
        self.view.addSubview(self.tableView!)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(requestData), for: UIControlEvents.valueChanged)
        
        self.tableView?.addSubview(refreshControl!)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
