//
//  DeliverManagerController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2018/1/18.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit

class DeliverManagerController: BaseViewController ,JXTopBarViewDelegate,JXHorizontalViewDelegate{
    
    var topBar : JXTopBarView?
    
    var horizontalView : JXHorizontalView?
    
    let deliveringVC = DeliveringController()
    let deliveredVC = DeliveredController()
    
    var deliverManagerBlock : (()->())?
    var isBlockShouldRun : Bool = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
        self.automaticallyAdjustsScrollViewInsets = false
        
        topBar = JXTopBarView.init(frame: CGRect.init(x: 0, y: kNavStatusHeight, width: view.bounds.width, height: 44), titles: ["未发货(0)","已发货"])
        topBar?.delegate = self
        topBar?.isBottomLineEnabled = true
        view.addSubview(topBar!)
        
        
        
        deliveringVC.deliveringBlock = {(deliverModel,operatorModel)->() in
            self.performSegue(withIdentifier: "chickenDeliveringManager", sender: ["deliverModel":deliverModel,"operatorModel":operatorModel])
        }
        
        deliveredVC.deliveredBlock = { (deliverModel,operatorModel)->() in
            self.performSegue(withIdentifier: "chickenDeliveredManager", sender: ["deliverModel":deliverModel,"operatorModel":operatorModel])
        }
        
        horizontalView = JXHorizontalView.init(frame: CGRect.init(x: 0, y: kNavStatusHeight + 54, width: view.bounds.width, height: UIScreen.main.bounds.height - kNavStatusHeight - 54), containers: [deliveringVC,deliveredVC], parentViewController: self)
        view.addSubview(horizontalView!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deliveringNumberChange), name: NSNotification.Name(rawValue: NotificationMainDeliveringNumber), object: nil)
   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func additionAction(_ sender: UIBarButtonItem) {
        if UserManager.manager.userAccound.type == 1 {
            self.performSegue(withIdentifier: "delivery", sender: nil)
        }else{
            self.performSegue(withIdentifier: "newBatch", sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier{
            switch identifier {
            case "chickenDeliveringManager":
                let dvc = segue.destination as! DeliveringMController
                if let dict = sender as? Dictionary<String,Any>,
                    let deliverModel = dict["deliverModel"] as? DeliverChickenSubModel,
                    let _ = dict["operatorModel"] as? OperatorModel{
                    dvc.deliverModel = deliverModel
                    //dvc.operatorModel = operatorModel
                    
                    dvc.deliveringManageBlock = { (isSuccess)->() in
                        
                        //                        let indexPath = IndexPath.init(item: 1, section: 0)
                        //                        self.horizontalView?.containerView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
                        //                        self.resetTopBarStatus(index: indexPath.item)
                        
                        self.deliveringVC.tableView.mj_header.beginRefreshing()
                        
                    }
                }
            case "chickenDeliveredManager":
                let dvc = segue.destination as! DeliveredMController
                if let dict = sender as? Dictionary<String,Any>,
                    let deliverModel = dict["deliverModel"] as? DeliverChickenSubModel,
                    let operatorModel = dict["operatorModel"] as? OperatorModel{
                    dvc.deliverModel = deliverModel
                    dvc.operatorModel = operatorModel
                    
                    //                    dvc.deliveringManageBlock = { (isSuccess)->() in
                    //
                    //                        let indexPath = IndexPath.init(item: 1, section: 0)
                    //                        self.horizontalView?.containerView .scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
                    //                    }
                }
            case "newBatch":
                let dvc = segue.destination as! DeliverNewBatchController
                dvc.backBlock = {
                    let indexPath = IndexPath.init(item: 0, section: 0)
                    self.horizontalView?.containerView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
                    self.deliveringVC.tableView.mj_header.beginRefreshing()
                }
            case "delivery":
                let dvc = segue.destination as! DeliveryViewController
                dvc.backBlock = {
                    self.deliveredVC.tableView.mj_header.beginRefreshing()
                }
                
            default:
                break
            }
        }
        
    }
    func deliveringNumberChange(notify:Notification) {
        if let number = notify.object as? Int {
            let title = String.init(format: "未发货(%d)", number)
            self.topBar?.titles = [title,"已发货"]
        }
    }
}

extension DeliverManagerController {
    func jxTopBarView(topBarView: JXTopBarView, didSelectTabAt index: Int) {
        let indexPath = IndexPath.init(item: index, section: 0)
        self.horizontalView?.containerView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
    }
    func horizontalViewDidScroll(scrollView:UIScrollView) {
        var frame = self.topBar?.bottomLineView.frame
        let offset = scrollView.contentOffset.x
        frame?.origin.x = (offset / kScreenWidth ) * (kScreenWidth / 2)
        self.topBar?.bottomLineView.frame = frame!
    }
    func horizontalView(_: JXHorizontalView, to indexPath: IndexPath) {
        //
        if self.topBar?.selectedIndex == indexPath.item {
            return
        }
        resetTopBarStatus(index: indexPath.item)
    }
    
    func resetTopBarStatus(index:Int) {
        
        self.topBar?.selectedIndex = index
        self.topBar?.subviews.forEach { (v : UIView) -> () in
            
            if (v is UIButton){
                let btn = v as! UIButton
                if (v.tag != self.topBar?.selectedIndex){
                    btn.isSelected = false
                }else{
                    btn.isSelected = !btn.isSelected
                }
            }
        }
    }
}
