//
//  TraceSourceDetailController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/22.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import MJRefresh

enum TraceRecordWhereFrom : Int{
    case detail           //详情
    case tag              //标签查询结果
    case wholeTrace       //已发货查看全程溯源
}

private let reuseIdentifier = "reuseIdentifier"
private let reuseIdentifierNib1 = "reuseIdentifierNib1"
private let reuseIdentifierNib2 = "reuseIdentifierNib2"

class TraceDetailController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var addButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addButtonWidthConstraint: NSLayoutConstraint!
    var traceBatchId : NSNumber? //溯源批次id,详情用
    var batchId : Int = 0 //批次id ,全程溯源用
    var tagCode : String? //查询编号 ,标签查询结果用
    
    lazy var detailVM = TraceSourceDetailVM()
    lazy var recordVM = TraceSRecordVM()
    
    var whereFrom : TraceRecordWhereFrom = .detail //标记来源，因为不同来源接口不同
    
    var currentPage = 1
    
    var currentRecord : TraceSourceRecord?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        self.addButtonWidthConstraint.constant = 44 * kPercent
        self.addButtonHeightConstraint.constant = 44 * kPercent
        
        self.tableView.register(UINib.init(nibName: "DeliverListCell", bundle: nil), forCellReuseIdentifier: reuseIdentifierNib1)
        self.tableView.register(UINib.init(nibName: "TraceSourceCell", bundle: nil), forCellReuseIdentifier: reuseIdentifierNib2)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addTraceSourceRecord(_ sender: UIButton) {
        performSegue(withIdentifier: "addTraceSourceRecord", sender: true)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
           let vc = segue.destination as? TraceSRecordController{
            
            switch identifier {
            case "addTraceSourceRecord":
            
                vc.isAdd = sender as! Bool
                vc.traceSource = self.detailVM.traceSourceDetail.traceBatch
                vc.block = {()->()in
                    print("回调")
                    self.tableView.mj_header.beginRefreshing()
                }
                if let record = currentRecord {
                    vc.traceRecordId = record.id
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
        if whereFrom == .tag {
            return detailVM.dataArray.count + 2
        }
        return detailVM.dataArray.count + 1
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if whereFrom == .tag {
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
                    lab1.textColor = JX333333Color
                    lab1.font = UIFont.systemFont(ofSize: 15)
                    lab1.tag = 10
                    
                    cell?.contentView.addSubview(lab1)
                    
                    
                    let lab2 = UILabel()
                    lab2.frame = CGRect(x: 0, y: 40, width: kScreenWidth, height: 30)
                    lab2.backgroundColor = UIColor.white
                    lab2.textAlignment = .left
                    lab2.textColor = JX333333Color
                    lab2.font = UIFont.systemFont(ofSize: 13)
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
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierNib2, for: indexPath) as! TraceSourceCell
                // Configure the cell...
                cell.selectionStyle = .none
                
                let model = self.detailVM.dataArray[indexPath.row - 2]
                cell.model = model
                
                
                return cell
            }
        }else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierNib1, for: indexPath) as? DeliverListCell
                cell?.selectionStyle = .none
                cell?.accessoryType = .none
                
                cell?.TitleLabel.text = detailVM.traceSourceDetail.traceBatch?.traceBatchName
                if let code = detailVM.traceSourceDetail.traceBatch?.traceBatchCreateBy {
                    cell?.DetailTitleLabel.text = String.init(format: "溯源创建人 %@", code)
                }else{
                    cell?.DetailTitleLabel.text = "溯源创建人"
                }
                return cell!
            
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierNib2, for: indexPath) as! TraceSourceCell
                cell.selectionStyle = .none
                // Configure the cell...
                
                let model = self.detailVM.dataArray[indexPath.row - 1]
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
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            currentRecord = self.detailVM.dataArray[indexPath.row - 1]
            
            if currentRecord?.isMine == false {
                return
            }
            let actionView = JXActionView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
            
            actionView.isUseBottomView = true
            actionView.delegate = self
            actionView.actions = ["修改","删除"]
            actionView.tag = indexPath.row - 1
            actionView.show()
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if whereFrom == .tag {
            if indexPath.row == 0 {
                return 44 + 10
            }else if indexPath.row == 1 {
                return 60 + 10
            }else{
                return calculateCellHeight(array: self.detailVM.dataArray[indexPath.row - 1].images)
            }
        }else{
            if indexPath.row == 0 {
                return 54
            }else{
                return calculateCellHeight(array: self.detailVM.dataArray[indexPath.row - 1].images)
            }
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
        
        switch whereFrom {
            
        case .detail:
            print("详情")
            self.detailVM.traceSourceDetail(page:page,traceBatchId: traceBatchId!) { (data, msg, isSuccess) in
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
                if isSuccess {
                    self.tableView.reloadData()
                }else{
                    print(msg)
                }
            }
        case .tag:
            self.detailVM.traceSourceTag(page:page,code: tagCode!, completion: { (data, msg, isSuccess) in
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
                if isSuccess {
                    self.tableView.reloadData()
                }else{
                    print(msg)
                }
            })
            print("标签")
        case .wholeTrace:
            print("全程溯源")
            self.detailVM.traceSourceWholeTrace(page: page, batchId: batchId, completion: { (data, msg, isSuccess) in
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
                if isSuccess {
                    self.tableView.reloadData()
                }else{
                    print(msg)
                }
            })
        }

    }
}
extension TraceDetailController : JXActionViewDelegate,UIAlertViewDelegate{
    func jxActionView(_ actionView: JXActionView, clickButtonAtIndex index: Int) {
        if index == 0 {
            //修改
            performSegue(withIdentifier: "addTraceSourceRecord", sender: false)
        }else{
            //删除
            let alert = UIAlertView.init(title: "确认删除本条溯源信息？", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确认删除")
            alert.tag = actionView.tag
            alert.show()
        }
        
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            //let model = self.detailVM.dataArray[alertView.tag]
            
            
            self.recordVM.deleteTraceSourceRecord(id: currentRecord!.id!, completion: { (data, msg, isSuccess) in
                ViewManager.showNotice(notice: msg)
                if isSuccess {
                    self.detailVM.dataArray.remove(at: alertView.tag)
                    self.tableView.reloadData()
                }
            })
            
        }
    }
}
