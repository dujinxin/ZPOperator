//
//  TagResultController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/30.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import MJRefresh

private let reuseIdentifier = "reuseIdentifier"
private let reuseIdentifierNib = "reuseIdentifierNib"

class TagResultController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var tagCode : String? //查询编号 ,标签查询结果用
    
    lazy var detailVM = TraceSourceDetailVM()
    
    
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.register(UINib.init(nibName: "TraceSourceCell", bundle: nil), forCellReuseIdentifier: reuseIdentifierNib)

        
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            self.currentPage = 1
            self.loadData(page: 1)
        })
        self.tableView.mj_footer = MJRefreshAutoFooter.init(refreshingBlock: {
            self.currentPage += 1
            self.loadData(page: self.currentPage)
        })
        
        self.tableView.reloadData()
        //self.tableView.mj_header.beginRefreshing()
        
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

        return detailVM.dataArray.count + 2
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier1")
            if cell == nil {
                cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "reuseIdentifier1")
                
                cell?.contentView.backgroundColor = UIColor.groupTableViewBackground
                cell?.selectionStyle = .none
                
                let lab = UILabel()
                lab.frame = CGRect(x: 0, y: 10, width: kScreenWidth, height: 44)
                lab.backgroundColor = UIColor.white
                lab.textAlignment = .left
                lab.font = UIFont.systemFont(ofSize: 13)
                lab.tag = 10
                
                cell?.contentView.addSubview(lab)
            }
            let lab = cell?.contentView.viewWithTag(10) as? UILabel
            
            
            // Configure the cell...
            lab?.text = "   标签码："
            if let code = detailVM.traceSourceTag.code {
                lab?.text = String.init(format: "   标签码：%@", code)
            }
            
            return cell!
        }else if indexPath.row == 1{
            var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier2")
            if cell == nil {
                cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "reuseIdentifier2")
                
                cell?.contentView.backgroundColor = UIColor.groupTableViewBackground
                cell?.selectionStyle = .none
                
                let lab1 = UILabel()
                lab1.frame = CGRect(x: 0, y: 10, width: kScreenWidth, height: 30)
                lab1.backgroundColor = UIColor.white
                lab1.textAlignment = .left
                lab1.font = UIFont.systemFont(ofSize: 13)
                lab1.tag = 10
                
                cell?.contentView.addSubview(lab1)
                
                
                let lab2 = UILabel()
                lab2.frame = CGRect(x: 0, y: 40, width: kScreenWidth, height: 30)
                lab2.backgroundColor = UIColor.white
                lab2.textAlignment = .left
                lab2.font = UIFont.systemFont(ofSize: 12)
                lab2.tag = 11
                
                cell?.contentView.addSubview(lab2)
            }
            let lab1 = cell?.contentView.viewWithTag(10) as? UILabel
            let lab2 = cell?.contentView.viewWithTag(11) as? UILabel
            // Configure the cell...
            //lab1?.text = vm.traceSourceTag?.goodsName
            if let goodsName = detailVM.traceSourceTag.goodsName {
                lab1?.text = String.init(format: "   %@", goodsName)
            }
            lab2?.text = "   发货批次号："
            if let code = detailVM.traceSourceTag.batchCode {
                lab2?.text = String.init(format: "   发货批次号：%@", code)
            }
            
            return cell!
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierNib, for: indexPath) as! TraceSourceCell
            // Configure the cell...
            cell.selectionStyle = .none
            
            let model = self.detailVM.dataArray[indexPath.row - 2]
            cell.model = model
            
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 0 {
            return 44 + 10
        }else if indexPath.row == 1 {
            return 60 + 10
        }else{
            return calculateCellHeight(array: self.detailVM.dataArray[indexPath.row - 1].images)
        }

    }
    
    func calculateCellHeight(array:Array<String>?) -> CGFloat {
        let height : CGFloat = (44 * 3 + 92)//44 * 3 + 72 + 10 + 5 + 5
        if let array = array{
            if !array.isEmpty {
                let imageheight = (kScreenWidth - (10 * 2 + 20 * 2 + 60 + 10)) / 3
                return height + imageheight
            }
        }
        return height
    }
    
    
    func loadData(page:Int) {

        self.detailVM.traceSourceTag(code: tagCode!, completion: { (data, msg, isSuccess) in
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            if isSuccess {
                self.tableView.reloadData()
            }else{
                ViewManager.showNotice(notice: msg)
            }
        })
        
    }
}
