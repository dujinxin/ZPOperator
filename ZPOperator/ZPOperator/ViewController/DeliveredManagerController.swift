//
//  DeliveredManagerController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/30.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class DeliveredManagerController: ZPTableViewController {
    
    var deliveredBatchId : Int = 0
    var traceDeliverSubModel : TraceDeliverSubModel?
    var traceDeliverOperatorModel : TraceDeliverOperatorModel?
    
    
    
    
    @IBOutlet weak var deliverBatchIdLabel: UILabel!
    @IBOutlet weak var deliverProduct: UILabel!
    @IBOutlet weak var deliverProductWeightLabel: UILabel!
    @IBOutlet weak var deliverAddressLabel: UILabel!
    
    @IBOutlet weak var receiveAddressLabel: UILabel!
    @IBOutlet weak var receivePerson: UILabel!
    
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var traceBatchLabel: UILabel!
    @IBOutlet weak var startNumLabel: UILabel!
    @IBOutlet weak var endNumLabel: UILabel!
    @IBOutlet weak var tagNumLabel: UILabel!
    @IBOutlet weak var operatorAddressLabel: UILabel!
    @IBOutlet weak var operatorPersonLabel: UILabel!
    @IBOutlet weak var operatorTimeLabel: UILabel!
    
    @IBOutlet weak var traceDetailButton: UIButton!
    
    @IBAction func traceDetail(_ sender: Any) {
        performSegue(withIdentifier: "TraceSourceWhole", sender: deliveredBatchId)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
            identifier == "TraceSourceWhole"{
            
            let vc = segue.destination as! DeliveredWholeController
            vc.batchId = sender as? NSNumber
        
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        self.tableView.reloadData()
        
        
        self.deliveredBatchId = (self.traceDeliverSubModel?.id?.intValue)!
        
        self.traceDetailButton.backgroundColor = UIColor.originColor
        self.traceDetailButton.layer.cornerRadius = 5
        

        self.deliverBatchIdLabel.text = self.traceDeliverSubModel?.batchCode
        self.deliverProduct.text = self.traceDeliverSubModel?.goodsName
        self.deliverProductWeightLabel.text = self.traceDeliverSubModel?.counts
        self.deliverAddressLabel.text = self.traceDeliverSubModel?.stationName
        
        if let province = self.traceDeliverSubModel?.province,
            let city = self.traceDeliverSubModel?.city,
            let country = self.traceDeliverSubModel?.county,
            let address = self.traceDeliverSubModel?.address{
            
            self.receiveAddressLabel.text = province + city + country + address
        }
        if let contact = self.traceDeliverSubModel?.contact,
            let mobile = self.traceDeliverSubModel?.mobile{
            
            self.receivePerson.text = contact + "" + mobile
        }
        
        
        self.remarkLabel.text = self.traceDeliverSubModel?.remarks
        self.traceBatchLabel.text = self.traceDeliverSubModel?.traceBatch
        self.startNumLabel.text = self.traceDeliverSubModel?.startCode
        self.endNumLabel.text = self.traceDeliverSubModel?.endCode
        if let totalCount = self.traceDeliverSubModel?.totalCount {
            self.tagNumLabel.text = String.init(format: "%@",totalCount)
        }
        
        
        self.operatorAddressLabel.text = self.traceDeliverOperatorModel?.station
        self.operatorPersonLabel.text = self.traceDeliverOperatorModel?.name
        self.operatorTimeLabel.text = self.traceDeliverSubModel?.operateTime
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else{
            return 34
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 74
        }else if indexPath.row == 2{
            return 88
        }else if indexPath.row == 3{
            let size = self.traceDeliverSubModel?.remarks?.calculate(width: kScreenWidth - 120, fontSize: 14)
            if (size?.height)! < CGFloat(20) {
                return 44
            }else{
                return (size?.height)! + CGFloat(10)
            }

        }else{
            return 44
        }
    }

}