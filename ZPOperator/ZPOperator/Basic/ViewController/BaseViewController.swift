//
//  BaseViewController.swift
//  ShoppingGo-Swift
//
//  Created by 杜进新 on 2017/6/6.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    //MARK: - custom NavigationBar
    //自定义导航栏
    lazy var customNavigationBar : UINavigationBar = {
        let navigationBar = UINavigationBar(frame:CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64))
        navigationBar.barTintColor = UIColor.cyan//导航条颜色
        navigationBar.tintColor = UIColor.brown //item图片文字颜色
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.red,NSFontAttributeName:UIFont.systemFont(ofSize: 22)]//标题设置
        return navigationBar
    }()
    lazy var customNavigationItem: UINavigationItem = {
        let item = UINavigationItem()
        return item
    }()
    
    //重写title的setter方法
    override var title: String?{
        didSet {
            customNavigationItem.title = title
        }
    }
    
    //MARK: - default view info
    
    /// default view
    lazy var defaultView: JXDefaultView = {
        let v = JXDefaultView()
        v.backgroundColor = UIColor.randomColor()
        return v
    }()
    
    var defaultInfo : [String:String]?
    
    //log state
    var isLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.rgbColor(rgbValue: 0xf1f1f1)
        view.backgroundColor = UIColor.rgbColor(from: 200, 200, 200)
        view.backgroundColor = UIColor.randomColor()
        
        
        isLogin ? setUpMainView() : setUpDefaultView()
        
        setCustomNavigationBar()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension BaseViewController {
    func setCustomNavigationBar() {
        //隐藏navigationBar
        //1.自定义view代替NavigationBar,需要自己实现手势返回;
        //2.自定义navigatioBar代替系统的，手势返回不用自己实现
        view.addSubview(customNavigationBar)
        customNavigationBar.items = [customNavigationItem]
        
    }
}

extension BaseViewController {
    
    /// request data
    func requestData() {
        
    }
    
    /// request data
    ///
    /// - Parameter withPage: load data for page,
    func request(withPage:Int) {
        
    }
    //MARK: - base view set
    func setUpMainView() {
        //
    }
    
    /// add default view eg:no data,no network,no login
    func setUpDefaultView() {
        defaultView.frame = view.bounds
        view.addSubview(defaultView)
        defaultView.info = defaultInfo
        defaultView.tapBlock = {()->() in
            self.requestData()
        }
    }
}

extension BaseViewController {
    
}
