//
//  NewMainCollectionController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2018/1/23.
//  Copyright © 2018年 dujinxin. All rights reserved.
//

import UIKit
import MJRefresh

private let reuseIdentifier = "Cell"

class NewMainViewController: ZPCollectionViewController{
    
    lazy var mainVM = MainVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        //self.automaticallyAdjustsScrollViewInsets = false
        
        
        let width = (kScreenWidth - 20 * 2 - 10 * 2) / 3
        
        
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize.init(width: kScreenWidth - 40, height: width)
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        //layout.headerReferenceSize = CGSize(width: kScreenWidth, height: width + width / 2 + 10)
        //layout.footerReferenceSize = CGSize(width: kScreenWidth, height: width)
        
        self.collectionView?.collectionViewLayout = layout
        
        // Register cell classes
        self.collectionView!.register(UINib.init(nibName: "LabelCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView?.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            self.mainVM.loadNewMainData(append: true, completion: { (data, msg, isSuccess) in
                self.collectionView?.mj_header.endRefreshing()
                if isSuccess {
                    self.collectionView?.reloadData()
                }else{
                    print("message = \(msg)")
                }
            })
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginStatus(notify:)), name: NSNotification.Name(rawValue: NotificationLoginStatus), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(deliveringNumberChange), name: NSNotification.Name(rawValue: NotificationMainDeliveringNumber), object: nil)
        //实名认证   您还没有通过认证，认证成功后才能使用全部功能   退出登录，立即认证，
        
        if UserManager.manager.isLogin {
            self.collectionView?.mj_header.beginRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UserManager.manager.isLogin {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let login = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            let loginVC = UINavigationController.init(rootViewController: login)
            
            self.navigationController?.present(loginVC, animated: false, completion: nil)
        }else{
            self.showAuthAlert()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationMainDeliveringNumber), object: nil)
    }

    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.mainVM.dataArray_new.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LabelCell
        
        cell.contentView.layer.cornerRadius = 5
        cell.contentView.layer.borderColor = JXMainColor.cgColor
        cell.contentView.layer.borderWidth = 1
        
        let model = self.mainVM.dataArray_new[indexPath.item]
    
        //cell.LabelButton.setImage(UIImage.init(named: "deliver")?.withRenderingMode(.alwaysOriginal), for: UIControlState.normal)
        //cell.LabelButton.setTitle("发货管理(\(self.mainVM.orderCount))", for: UIControlState.normal)
        cell.LabelButton.setTitle(model.moduleName, for: UIControlState.normal)

        return cell
    }
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.mainVM.dataArray_new[indexPath.item]
        
        guard let url = model.url else {
            ViewManager.showNotice(notice: "未分配权限")
            return
        }
        switch url {
//通用（无网点）
        case "/common/batch/list"://发货管理
            performSegue(withIdentifier: "deliverManagement", sender: DeliverStationStyle.none)
//电商（有网点&无）
        case "/station/batch/list"://发货管理
            let style : DeliverStationStyle = UserManager.manager.userAccound.stationName.isEmpty == true ? .none : .station
            
            performSegue(withIdentifier: "deliverManagement", sender: style)
//公共模块
        case "/traceBatch/list":   //溯源管理
            performSegue(withIdentifier: "TraceSources", sender: nil)
        case "/code/search":       //标签查询
            performSegue(withIdentifier: "tagManagement", sender: nil)
        default:
            ViewManager.showNotice(notice: LanguageManager.localizedString("Unassigned permissions"))
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier{
            switch identifier {
            case "deliverManagement":
                let dvc = segue.destination as! DeliverManageController
                dvc.style = sender as! DeliverStationStyle
            default:
                break
            }
        }
    }
    func loginStatus(notify:Notification) {
        print(notify)
        
        if let isSuccess = notify.object as? Bool,
            isSuccess == true{
            self.collectionView?.mj_header.beginRefreshing()
            self.showAuthAlert()
            
        }else{
            UserManager.manager.removeAccound()
            
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let login = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            let loginVC = UINavigationController.init(rootViewController: login)
            
            self.navigationController?.present(loginVC, animated: false, completion: nil)
            //self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func deliveringNumberChange(notify:Notification) {
        if let number = notify.object as? Int {
            self.mainVM.orderCount = number
            self.collectionView?.reloadData()
        }
    }
    func showAuthAlert() {
        
        //人脸识别功能暂停
        //        if UserManager.manager.userAccound.isAuthed == 0 {
        //            let alert = UIAlertController(title: "实名认证", message: "您还没有通过认证，认证成功后才能使用全部功能", preferredStyle: .alert)
        //            alert.addAction(UIAlertAction(title: "退出登录", style: .cancel, handler: { (action) in
        //                let loginVM = LoginVM()
        //                loginVM.logout { (data, msg, isSuccess) in
        //                    if isSuccess {
        //                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationLoginStatus), object: false)
        //                    }
        //                }
        //            }))
        //            alert.addAction(UIAlertAction(title: "立即认证", style: .destructive, handler: { (action) in
        //                let cwvc = CWLivessViewController()
        //                cwvc.allActionArry = [blink,openMouth,headLeft,headRight]
        //                //cwvc.delegate = self
        //                cwvc.setLivessParam(AuthCodeString, livessNumber: 4, isShowResultView: true)
        //                self.navigationController?.pushViewController(cwvc, animated: true)
        //            }))
        //            self.present(alert, animated: true, completion: nil)
        //        }else{
        //            print("已认证")
        //        }
    }
}
