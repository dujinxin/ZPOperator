//
//  DeliverManageController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/21.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class DeliverManageController: UIViewController ,JXTopBarViewDelegate,JXHorizontalViewDelegate{
    
    var topBar : JXTopBarView?
    
    var horizontalView : JXHorizontalView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        topBar = JXTopBarView.init(frame: CGRect.init(x: 0, y: 64, width: view.bounds.width, height: 44), titles: ["未发货","已发货"])
        topBar?.delegate = self
        view.addSubview(topBar!)
        
        let deliveringVC = DeliveringViewController()
        let deliveredVC = DeliveredViewController()

        horizontalView = JXHorizontalView.init(frame: CGRect.init(x: 0, y: 64 + 54, width: view.bounds.width, height: UIScreen.main.bounds.height - 64 - 54), containers: [deliveringVC,deliveredVC], parentViewController: self)
        view.addSubview(horizontalView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension DeliverManageController {
    func jxTopBarView(topBarView: JXTopBarView, didSelectTabAt index: Int) {
        let indexPath = IndexPath.init(item: index, section: 0)
        self.horizontalView?.containerView .scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
    }
    
    func horizontalView(_: JXHorizontalView, to indexPath: IndexPath) {
        //
        if self.topBar?.selectedIndex == indexPath.item {
            return
        }
        self.topBar?.selectedIndex = indexPath.item
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
