//
//  MainViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/20.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let reuseIndentifierHeader = "reuseIndentifierHeader"
private let reuseIndentifierFooter = "reuseIndentifierFooter"

class MainViewController: UICollectionViewController {
    
    lazy var mainVM = MainVM()
    //log state
    var isLogin = JXNetworkManager.manager.isLogin
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        //self.automaticallyAdjustsScrollViewInsets = false

        // Register cell classes
        self.collectionView!.register(UINib.init(nibName: "MainCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.register(UINib.init(nibName: "MainReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIndentifierHeader)
        self.collectionView?.register(UINib.init(nibName: "MainReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: reuseIndentifierFooter)
    
        
        if !isLogin {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
//            self.navigationController?.pushViewController(vc, animated: true)
            
            let login = LoginViewController()
            
            //self.addChildViewController(login)
            self.navigationController?.present(login, animated: false, completion: nil)
        }else{
            self.mainVM.loadMainData(append: true, completion: { (data, msg, isSuccess) in
                if isSuccess {
                    self.collectionView?.reloadData()
                }else{
                    print("message = \(msg)")
                }
            })
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.mainVM.loadMainData(append: true, completion: { (data, msg, isSuccess) in
//            print(data)
//        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.mainVM.dataArray.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCell
    
        // Configure the cell
        cell.backgroundColor = UIColor.red
        
        if indexPath.item < self.mainVM.dataArray.count {
            let model = self.mainVM.dataArray[indexPath.item]
            cell.MainContentLabel.text = model.name
        }else{
            cell.MainContentLabel.text = "更多溯源批次"
        }
        
        
    
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reuseStr : String = (kind == UICollectionElementKindSectionHeader) ? reuseIndentifierHeader : reuseIndentifierFooter
        
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseStr, for: indexPath) as! MainReusableView
       
        if kind == UICollectionElementKindSectionHeader {
            reusableView.mainActionButton.setTitle("发货管理", for: UIControlState.normal)
            reusableView.mainActionButton.addTarget(self, action: #selector(deliverManagement), for: UIControlEvents.touchUpInside)
        }else{
            reusableView.mainActionButton.setTitle("标签管理", for: UIControlState.normal)
            reusableView.mainActionButton.addTarget(self, action: #selector(tagManagement), for: UIControlEvents.touchUpInside)
        }
        reusableView.mainActionButton.backgroundColor = UIColor.yellow
    
        
        return reusableView
    }
    
    func deliverManagement() {
        print("12345")
        
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
    func tagManagement() {
        print("876543")
        
        performSegue(withIdentifier: "tagManagement", sender: nil)
    }


    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == (self.mainVM.dataArray.count){
            performSegue(withIdentifier: "TraceSources", sender: nil)
        }else{
            performSegue(withIdentifier: "TraceSourceDetail", sender: nil)
        }
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}
