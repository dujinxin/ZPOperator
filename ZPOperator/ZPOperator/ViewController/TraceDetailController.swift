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
        return detailVM.dataArray.count + 1
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierNib1, for: indexPath) as? DeliverListCell
            cell?.selectionStyle = .none
            cell?.accessoryType = .none
            
            cell?.TitleLabel.text = detailVM.traceSourceDetail.traceBatch?.traceBatchName
            cell?.DetailTitleLabel.text = String.init(format: "%@ %@",LanguageManager.localizedString("Trace.Creator"), detailVM.traceSourceDetail.traceBatch?.traceBatchCreateBy ?? "")
            
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            currentRecord = self.detailVM.dataArray[indexPath.row - 1]
            
            if currentRecord?.isMine == false {
                return
            }
            let actionView = JXActionView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
            
            actionView.isUseBottomView = true
            actionView.delegate = self
            actionView.actions = [LanguageManager.localizedString("Edit"),
                                  LanguageManager.localizedString("Delete")]
            actionView.tag = indexPath.row - 1
            actionView.show()
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 54
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
        case .wholeTrace:
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
            let alert = UIAlertView.init(title: LanguageManager.localizedString("Notice.ConfirmDeleteTracingInformation"), message: "", delegate: self, cancelButtonTitle: LanguageManager.localizedString("Cancel"), otherButtonTitles: LanguageManager.localizedString("Delete"))
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
