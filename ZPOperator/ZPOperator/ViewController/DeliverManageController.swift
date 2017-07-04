//
//  DeliverManageController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/21.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class DeliverManageController: BaseViewController ,JXTopBarViewDelegate,JXHorizontalViewDelegate{
    
    var topBar : JXTopBarView?
    
    var horizontalView : JXHorizontalView?
    
    let deliveringVC = DeliveringViewController()
    let deliveredVC = DeliveredViewController()
    
    var deliverManagerBlock : (()->())?
    var isBlockShouldRun : Bool = false
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        topBar = JXTopBarView.init(frame: CGRect.init(x: 0, y: kNavStatusHeight, width: view.bounds.width, height: 44), titles: ["未发货","已发货"])
        topBar?.delegate = self
        view.addSubview(topBar!)
        
        
        
        deliveringVC.deliveringBlock = {(deliveringModel,deliveringOperatorModel)->() in
            self.performSegue(withIdentifier: "deliveringManager", sender: ["deliveringModel":deliveringModel,"deliveringOperatorModel":deliveringOperatorModel])
        }

        deliveredVC.deliveredBlock = { (deliveringModel,deliveringOperatorModel)->() in
            self.performSegue(withIdentifier: "deliveredManager", sender: ["deliveringModel":deliveringModel,"deliveringOperatorModel":deliveringOperatorModel])
        }
        horizontalView = JXHorizontalView.init(frame: CGRect.init(x: 0, y: kNavStatusHeight + 54, width: view.bounds.width, height: UIScreen.main.bounds.height - kNavStatusHeight - 54), containers: [deliveringVC,deliveredVC], parentViewController: self)
        view.addSubview(horizontalView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier{
            switch identifier {
            case "deliveringManager":
                let dvc = segue.destination as! DeliveringManagerController
                if let dict = sender as? Dictionary<String,Any>,
                   let deliveringModel = dict["deliveringModel"] as? TraceDeliverSubModel,
                   let deliveringOperatorModel = dict["deliveringOperatorModel"] as? TraceDeliverOperatorModel{
                    dvc.deliverModel = deliveringModel
                    dvc.deliverOperatorModel = deliveringOperatorModel
                    
                    dvc.deliveringManageBlock = { (isSuccess)->() in
                        
//                        let indexPath = IndexPath.init(item: 1, section: 0)
//                        self.horizontalView?.containerView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
//                        self.resetTopBarStatus(index: indexPath.item)
                        
                        self.deliveringVC.tableView.mj_header.beginRefreshing()
                        
                    }
                }
            case "deliveredManager":
                let dvc = segue.destination as! DeliveredManagerController
                if let dict = sender as? Dictionary<String,Any>,
                    let deliveringModel = dict["deliveringModel"] as? TraceDeliverSubModel,
                    let deliveringOperatorModel = dict["deliveringOperatorModel"] as? TraceDeliverOperatorModel{
                    dvc.traceDeliverSubModel = deliveringModel
                    dvc.traceDeliverOperatorModel = deliveringOperatorModel
                    
//                    dvc.deliveringManageBlock = { (isSuccess)->() in
//                        
//                        let indexPath = IndexPath.init(item: 1, section: 0)
//                        self.horizontalView?.containerView .scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
//                    }
                }
                    
            default:
                break
            }
        }
        
    }

}

extension DeliverManageController {
    func jxTopBarView(topBarView: JXTopBarView, didSelectTabAt index: Int) {
        let indexPath = IndexPath.init(item: index, section: 0)
        self.horizontalView?.containerView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
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
