//
//  PhotoBrowserView.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/7/6.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class PhotoBrowserView: UIView {

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
    
    
    init(frame: CGRect,images:Array<Any>) {
        self.collectionView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        addSubview(self.collectionView)
        
        
    }
}
extension PhotoBrowserView: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath)
        
        return cell
    }
}
