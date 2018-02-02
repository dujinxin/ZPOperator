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
private let reuseIdentifierNib1 = "reuseIdentifierNib1"
private let reuseIdentifierNib2 = "reuseIdentifierNib2"

class TagResultController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var tagCode : String? //查询编号 ,标签查询结果用
    
    var detailVM = TraceSourceDetailVM()
    
    
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
     
        self.tableView.register(UINib.init(nibName: "DeliverListCell", bundle: nil), forCellReuseIdentifier: reuseIdentifierNib1)
        self.tableView.register(UINib.init(nibName: "TraceSourceCell", bundle: nil), forCellReuseIdentifier: reuseIdentifierNib2)

        self.tableView.reloadData()
        
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
                lab.textColor = JX333333Color
                lab.font = UIFont.systemFont(ofSize: 15)
                lab.tag = 10
                
                cell?.contentView.addSubview(lab)
            }
            let lab = cell?.contentView.viewWithTag(10) as? UILabel
            
            
            // Configure the cell...
            lab?.text = String.init(format: "   %@：%@", LanguageManager.localizedString("Label.Code"),detailVM.traceSourceTag.code ?? "")
    
            return cell!
        }else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierNib1, for: indexPath) as? DeliverListCell
            cell?.selectionStyle = .none
            cell?.accessoryType = .none
            
            cell?.TitleLabel.text = detailVM.traceSourceTag.goodsName
            cell?.DetailTitleLabel.text = String.init(format: "%@ %@",LanguageManager.localizedString("Ship.BatchNumber") ,detailVM.traceSourceTag.batchCode ?? "")
            
            return cell!
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierNib2, for: indexPath) as! TraceSourceCell
            // Configure the cell...
            cell.selectionStyle = .none
            
            let model = self.detailVM.dataArray[indexPath.row - 2]
            cell.model = model
            cell.imageViewBlock = {index in
                let vc = JXPhotoBrowserController(collectionViewLayout: UICollectionViewFlowLayout())
                vc.currentPage = index
                vc.images = model.images!
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
            
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 0 {
            return 44 + 10
        }else if indexPath.row == 1 {
            return 54 + 10
        }else{
            return calculateCellHeight(array: self.detailVM.dataArray[indexPath.row - 2].images)
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

        self.detailVM.traceSourceTag(page:page,code: tagCode!, completion: { (data, msg, isSuccess) in
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
