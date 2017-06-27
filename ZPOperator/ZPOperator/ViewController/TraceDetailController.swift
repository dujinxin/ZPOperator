//
//  TraceSourceDetailController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/22.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "reuseIdentifier"
private let reuseIdentifierNib = "reuseIdentifierNib"

class TraceDetailController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var traceBatchId : NSNumber?
    
    lazy var vm = TraceSourceDetailVM()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.register(UINib.init(nibName: "TraceSourceCell", bundle: nil), forCellReuseIdentifier: reuseIdentifierNib)
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        self.vm.loadMainData(traceBatchId: traceBatchId!) { (data, msg, isSuccess) in
            if isSuccess {
                self.tableView.reloadData()
            }else{
                print(msg)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addTraceSourceRecord(_ sender: UIButton) {
        performSegue(withIdentifier: "addTraceSourceRecord", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
           let vc = segue.destination as? TraceSRecordController{
            
            switch identifier {
            case "addTraceSourceRecord":
                vc.traceSource = self.vm.traceSource
            default:
                break
            }
        }
        
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return vm.dataArray.count + 1
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            //1.才用这种方式，cell不需要提前注册，拿不到的话会走if;如果注册，且可以正确获取，那么不走if
            var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
            //2.才用这种，cell必须提前注册，不注册会crash,而且注册后获取不到cell也会crash，不走if,获取到了
            //var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            
            if cell == nil {
                
                cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "reuseIdentifier")
            }
            
            // Configure the cell...
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.text = "产品名称"
            cell?.textLabel?.text = vm.traceSource?.traceBatchName
            cell?.textLabel?.textColor = UIColor.red
            cell!.detailTextLabel?.text = "备注说明"
            //cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            
            // Configure the cell...
            
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierNib, for: indexPath) as! TraceSourceCell
            // Configure the cell...
            let model = self.vm.dataArray[indexPath.row - 1]
            cell.labelDetail1.text = model.createBy
            return cell
        }
        

        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        }else if indexPath.row == 1{
            return 400
        }else{
            return 340
        }
    }

}
