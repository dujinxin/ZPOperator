//
//  DeliveredMController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2018/1/18.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit

class DeliveredMController: ZPTableViewController {
    
    var deliverModel : DeliverChickenSubModel?
    var operatorModel : OperatorModel?
    
    @IBOutlet weak var deliverBatchIdLabel: UILabel!
    @IBOutlet weak var deliverProduct: UILabel!
    @IBOutlet weak var deliverProductWeightLabel: UILabel!
    
    
    @IBOutlet weak var receiveAddressLabel: UILabel!
    
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var traceBatchLabel: UILabel!

    @IBOutlet weak var footCodeLabel: UILabel!
    @IBOutlet weak var traceCodeLabel: UILabel!
    @IBOutlet weak var deliverTypeLabel: UILabel!
    @IBOutlet weak var trackingNumberLabel: UILabel!
    
    @IBOutlet weak var operatorPersonLabel: UILabel!
    @IBOutlet weak var operatorTimeLabel: UILabel!
    
    @IBOutlet weak var traceDetailButton: UIButton!
    
    @IBAction func traceDetail(_ sender: Any) {
        performSegue(withIdentifier: "chickenTraceSourceWhole", sender: self.deliverModel?.batchId)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
            identifier == "chickenTraceSourceWhole"{
            
            let vc = segue.destination as! DeliveredWholeController
            vc.batchId = sender as! Int
            vc.comefrom = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        self.tableView.reloadData()
        
        self.traceDetailButton.backgroundColor = JXOrangeColor
        self.traceDetailButton.layer.cornerRadius = 5
        
        
        self.deliverBatchIdLabel.text = self.deliverModel?.orderNum
        self.deliverProduct.text = self.deliverModel?.title
        self.deliverProductWeightLabel.text = String(format: "%d", self.deliverModel?.counts ?? "0")
        
        if let province = self.deliverModel?.province,
            let city = self.deliverModel?.city,
            let country = self.deliverModel?.county,
            let address = self.deliverModel?.detailAddress{
            
            self.receiveAddressLabel.text = province + city + country + address
        }
        
        if let remarks = self.deliverModel?.remarks,
            remarks.isEmpty == false{
            self.remarkLabel.text = self.deliverModel?.remarks
        }
        self.traceBatchLabel.text = self.deliverModel?.traceBatchName
        self.footCodeLabel.text = self.deliverModel?.deviceNum
        self.traceCodeLabel.text = self.deliverModel?.codeSn
        self.deliverTypeLabel.text = self.deliverModel?.expressName
        self.trackingNumberLabel.text = self.deliverModel?.expressNumber
        self.operatorPersonLabel.text = self.operatorModel?.name
        self.operatorTimeLabel.text = self.deliverModel?.deliverDate
        
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
        if indexPath.section == 1 {
            return 44
        }else{
            if indexPath.row == 2{
                let size = self.receiveAddressLabel.text?.calculate(width: kScreenWidth - 120, fontSize: 14)
                if (size?.height)! < CGFloat(20) {
                    return 44
                }else{
                    return (size?.height)! + CGFloat(10)
                }
                
            }else if indexPath.row == 3{
                let size = self.deliverModel?.remarks.calculate(width: kScreenWidth - 120, fontSize: 14)
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
    
}
