//
//  DeliveringViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/21.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class DeliveringViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var tableView = UITableView.init(frame: CGRect.zero, style: .plain)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.red
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.frame = view.bounds
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier1")
        self.tableView.tableFooterView = UIView()
        view.addSubview(self.tableView)
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
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //1.才用这种方式，cell不需要提前注册，拿不到的话会走if;如果注册，且可以正确获取，那么不走if
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        //2.才用这种，cell必须提前注册，不注册会crash,而且注册后获取不到cell也会crash，不走if(总之不能自定义UITableViewCellStyle)
        //var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        if cell == nil {
            
            cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "reuseIdentifier")
        }
        
        // Configure the cell...
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = "产品名称"
        cell?.textLabel?.textColor = UIColor.red
        cell!.detailTextLabel?.text = "备注说明"

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
        
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

}
