//
//  JXNavigationController.swift
//  ShoppingGo-Swift
//
//  Created by 杜进新 on 2017/6/6.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

class JXNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationBar.barTintColor = UIColor.yellow//导航条颜色
        self.navigationBar.tintColor = UIColor.black   //item图片文字颜色
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black,NSFontAttributeName:UIFont.systemFont(ofSize: 22)]//标题设置
        
        self.navigationBar.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension JXNavigationController {
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
      
        
        if  let vc = viewController as? BaseViewController{
            if viewControllers.count > 0 {
                vc.hidesBottomBarWhenPushed = true
                
                var titleName = "返回"
                
                if viewControllers.count == 1 {
                    titleName = viewControllers.first?.title ?? titleName
                }
                
                vc.customNavigationItem.leftBarButtonItem = UIBarButtonItem(title: titleName, target: self, action: #selector(pop))
            }
        }
        super.pushViewController(viewController, animated: true)
    }
    
    func pop() {
        popViewController(animated: true)
    }
}
