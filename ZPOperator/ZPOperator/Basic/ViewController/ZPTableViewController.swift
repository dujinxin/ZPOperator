//
//  ZPTableViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/7/1.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import MJRefresh
import MBProgressHUD

class ZPTableViewController: UITableViewController {

    var backBlock : (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = image
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = image?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftItemsSupplementBackButton = false;
        let backBarButtonItem = UIBarButtonItem.init(title:"", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationController?.navigationBar.barTintColor = UIColor.rgbColor(rgbValue: 0x046ac9)//导航条颜色
        self.navigationController?.navigationBar.tintColor = UIColor.white //item图片文字颜色
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white,NSFontAttributeName:UIFont.systemFont(ofSize: 19)]//标题设置
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


}
extension ZPTableViewController {
    func showMBProgressHUD() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        //        hud.backgroundView.color = UIColor.black
        //        hud.contentColor = UIColor.black
        //        hud.bezelView.backgroundColor = UIColor.black
        //        hud.label.text = "加载中..."
        
    }
    func hideMBProgressHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}
