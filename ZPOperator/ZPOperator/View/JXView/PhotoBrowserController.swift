//
//  PhotoBrowserController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/7/6.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class PhotoBrowserController: UIView {

//    var <#variable name#>: <#type#> {
//        get {
//            <#statements#>
//        }
//        set {
//            <#variable name#> = newValue
//        }
//    }
    
//    var <#variable name#>: <#type#> {
//        <#statements#>
//    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = UIScreen.main.bounds.size
        
        let collection = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "reuserIdentifier")
        
        return collection
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension PhotoBrowserController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath)
        
        return cell
    }
}
