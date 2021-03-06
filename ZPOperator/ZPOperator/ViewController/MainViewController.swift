//
//  MainViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/20.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import MJRefresh

private let reuseIdentifier = "Cell"
private let reuseIndentifierHeader = "reuseIndentifierHeader"
private let reuseIndentifierFooter = "reuseIndentifierFooter"

class MainViewController: ZPCollectionViewController,SBCollectionViewDelegateFlowLayout {
    
    lazy var mainVM = MainVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        //self.automaticallyAdjustsScrollViewInsets = false
        
        
        let width = (kScreenWidth - 20 * 2 - 10 * 2) / 3
        
        
        let layout = self.collectionView?.collectionViewLayout as! MainCollectionViewFlowLayout
        layout.itemSize = CGSize.init(width: width, height: width)
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 20, 20)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        layout.headerReferenceSize = CGSize(width: kScreenWidth, height: width + width / 2 + 10)
        layout.footerReferenceSize = CGSize(width: kScreenWidth, height: width)
        
        self.collectionView?.collectionViewLayout = layout

        // Register cell classes
        self.collectionView!.register(UINib.init(nibName: "MainCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.register(UINib.init(nibName: "MainReusableViewHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIndentifierHeader)
        self.collectionView?.register(UINib.init(nibName: "MainReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: reuseIndentifierFooter)
        self.collectionView?.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { 
            self.mainVM.loadMainData(append: true, completion: { (data, msg, isSuccess) in
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundColorForSectionAt section: Int) -> UIColor {
        return UIColor.white
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if self.mainVM.dataArray.count == 0 {
            return self.mainVM.dataArray.count + 1
        }else{
            return self.mainVM.dataArray.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCell
    
        cell.contentView.layer.cornerRadius = 5
        cell.contentView.layer.borderColor = JXMainColor.cgColor
        cell.contentView.layer.borderWidth = 1
        
        if indexPath.item < self.mainVM.dataArray.count {
            let model = self.mainVM.dataArray[indexPath.item]
            cell.MainContentLabel.text = model.name
            cell.MainContentLabel.textColor = JXMainColor
            cell.MainContentLabel.font = UIFont.systemFont(ofSize: 15)
        }else{
            cell.MainContentLabel.text = "+"
            cell.MainContentLabel.textColor = UIColor.rgbColor(from: 200, 228, 255)
            cell.MainContentLabel.font = UIFont.systemFont(ofSize: 40)
        }
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reuseStr : String = (kind == UICollectionElementKindSectionHeader) ? reuseIndentifierHeader : reuseIndentifierFooter
        
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseStr, for: indexPath) as! MainReusableView
       
        if kind == UICollectionElementKindSectionHeader {
            reusableView.mainActionButton.setImage(UIImage.init(named: "deliver")?.withRenderingMode(.alwaysOriginal), for: UIControlState.normal)
            reusableView.mainActionButton.setTitle("发货管理(\(self.mainVM.orderCount))", for: UIControlState.normal)
            
            reusableView.mainActionButton.addTarget(self, action: #selector(deliverManagement), for: UIControlEvents.touchUpInside)
            reusableView.mainActionButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, -20)
            
            reusableView.moreActionButton?.addTarget(self, action: #selector(moreTraceSources), for: .touchUpInside)
        }else{
            reusableView.mainActionButton.setImage(UIImage.init(named: "tag")?.withRenderingMode(.automatic), for: UIControlState.normal)
            reusableView.mainActionButton.setTitle("标签查询", for: UIControlState.normal)
            reusableView.mainActionButton.addTarget(self, action: #selector(tagManagement), for: UIControlEvents.touchUpInside)
            reusableView.mainActionButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, -20)
        }

        return reusableView
    }
    
    func deliverManagement() {
        
        //1
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        //self.navigationController?.pushViewController(vc, animated: true)
        
        //2
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        //self.navigationController?.pushViewController(vc, animated: true)
        
        //3
        performSegue(withIdentifier: "deliverManagement", sender: nil)
        
        
    }
    func moreTraceSources() {
        performSegue(withIdentifier: "TraceSources", sender: nil)
    }
    func tagManagement() {
        performSegue(withIdentifier: "tagManagement", sender: nil)
    }


    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == (self.mainVM.dataArray.count){
            performSegue(withIdentifier: "traceSourceAdd", sender: nil)
        }else{
            let model = self.mainVM.dataArray[indexPath.item]
            performSegue(withIdentifier: "TraceSourceDetail", sender: model.id)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier{
            switch identifier {
            case "TraceSourceDetail":
                let dvc = segue.destination as! TraceDetailController
                dvc.traceBatchId = sender as? NSNumber
            case "traceSourceAdd":
                let dvc = segue.destination as! TraceSAddViewController
                dvc.traceSAddBlock = {()->()in
                    self.collectionView?.mj_header.beginRefreshing()
                }
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
