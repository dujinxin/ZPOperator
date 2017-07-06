//
//  TraceSourcesController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/20.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import MJRefresh

private let reuseIdentifier = "Cell"

class TraceSourcesController: ZPCollectionViewController {

    lazy var vm = TraceSourceVM()
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        //self.automaticallyAdjustsScrollViewInsets = false
        
        // Register cell classes
        self.collectionView!.register(UINib.init(nibName: "MainCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        let width = (kScreenWidth - 20 * 2 - 10 * 2) / 3
        
        
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize.init(width: width, height: width)
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        self.collectionView?.collectionViewLayout = layout
        self.collectionView?.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { 
            self.currentPage = 1
            self.loadData(page: self.currentPage)
        })
        self.collectionView?.mj_footer = MJRefreshBackFooter.init(refreshingBlock: {
            self.currentPage += 1
            self.loadData(page: self.currentPage)
        })
        self.collectionView?.mj_header.beginRefreshing()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(page:Int) {
        self.vm.loadMainData(append: false, page:page, completion: { (data, msg, isSuccess) in
            self.collectionView?.mj_header.endRefreshing()
            self.collectionView?.mj_footer.endRefreshing()
            if isSuccess {
                self.collectionView?.reloadData()
            }else{
                print("message = \(msg)")
            }
        })
    }
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if let identifier = segue.identifier{
        switch identifier {
        case "traceSourceAdd":
            let dvc = segue.destination as! TraceSAddViewController
            //let block = sender as! (()->())
            
            dvc.traceSAddBlock = {()->()in
                print("回调")
                self.collectionView?.mj_header.beginRefreshing()
            }
            
        case "TraceSourceDetail":
            let dvc = segue.destination as! TraceDetailController
            dvc.traceBatchId = sender as? NSNumber
        default:
            break
        }
    }

    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.vm.dataArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCell
        
        // Configure the cell
        
        cell.contentView.layer.cornerRadius = 5
        cell.contentView.layer.borderColor = UIColor.rgbColor(from: 35, 68, 120).cgColor
        cell.contentView.layer.borderWidth = 1
        
        let model = self.vm.dataArray[indexPath.item]
        
        cell.MainContentLabel.text = model.name
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.vm.dataArray[indexPath.item]
        performSegue(withIdentifier: "TraceSourceDetail", sender: model.id)
    }
    // MARK: UICollectionViewDelegate

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
