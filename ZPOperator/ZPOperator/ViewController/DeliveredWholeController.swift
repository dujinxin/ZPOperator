//
//  DeliveredWholeController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/30.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

import MJRefresh


private let reuseIdentifier = "reuseIdentifier"
private let reuseIdentifierNib = "reuseIdentifierNib"

class DeliveredWholeController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    var batchId : NSNumber? //批次id ,全程溯源用
    
    
    lazy var detailVM = TraceSourceDetailVM()
    lazy var recordVM = TraceSRecordVM()
    
    var currentPage = 1
    
    var currentRecord : TraceSourceRecord?
    
    
    
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
        
        self.tableView.mj_header.beginRefreshing()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addTraceSourceRecord(_ sender: UIButton) {
        let alert = UIAlertView.init(title: "注意", message: "此处新增的溯源信息，不影响发货批次之前的溯源信息", delegate: self, cancelButtonTitle: "确定")
        alert.tag = 100
        alert.show()
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
            let vc = segue.destination as? DeliveredWholeRecordController{
            
            switch identifier {
            case "addTraceSourceWholeRecord":
                
                vc.isAddTraceSource = sender as! Bool
                
                vc.batchId = self.detailVM.traceSourceWhole.batch.id
                vc.block = {()->()in
                    print("回调")
                    self.tableView.mj_header.beginRefreshing()
                }
                if let record = currentRecord {
                    vc.traceSourceRecord = record
                }
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
        return detailVM.dataArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
            if cell == nil {
                cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "reuseIdentifier")
                
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
        
            if let traceBatchName = detailVM.traceSourceWhole.batch.goodsName {
                lab1?.text = String.init(format: "   %@", traceBatchName)
            }
            lab2?.text = "   发货批次号："
            if let code = detailVM.traceSourceWhole.batch.code {
                lab2?.text = String.init(format: "   发货批次号：%@", code)
            }
            
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierNib, for: indexPath) as! TraceSourceCell
            cell.selectionStyle = .none
            // Configure the cell...
            
            let model = self.detailVM.dataArray[indexPath.row - 1]
            cell.model = model
            
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            currentRecord = self.detailVM.dataArray[indexPath.row - 1]
            
            if currentRecord?.isMine == false {
                return
            }
            let jxAlertView = JXAlertView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
            
            jxAlertView.position = .bottom
            jxAlertView.isSetCancelView = true
            jxAlertView.delegate = self
            jxAlertView.actions = ["修改","删除"]
            jxAlertView.tag = indexPath.row - 1
            jxAlertView.show()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.row == 0 {
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
        
        self.detailVM.traceSourceWholeTrace(page: page, batchId: batchId!, completion: { (data, msg, isSuccess) in
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
extension DeliveredWholeController : JXAlertViewDelegate,UIAlertViewDelegate{
    func jxAlertView(_ alertView: JXAlertView, clickButtonAtIndex index: Int) {
        if index == 0 {
            //修改
            performSegue(withIdentifier: "addTraceSourceWholeRecord", sender: false)
        }else{
            //删除
            let alert = UIAlertView.init(title: "确认删除本条溯源信息？", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确认删除")
            alert.tag = alertView.tag
            alert.show()
        }
        
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            //let model = self.detailVM.dataArray[alertView.tag]
            
            
            self.recordVM.deleteTraceSourceRecord(id: currentRecord!.id!, completion: { (data, msg, isSuccess) in
                ViewManager.showNotice(notice: msg)
                if isSuccess  {
                    self.detailVM.dataArray.remove(at: alertView.tag)
                    self.tableView.reloadData()
                }
            })
        }
        if alertView.tag == 100 {
            performSegue(withIdentifier: "addTraceSourceWholeRecord", sender: true)
        }
    }
}
