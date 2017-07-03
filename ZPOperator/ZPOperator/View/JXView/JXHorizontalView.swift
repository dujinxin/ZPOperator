//
//  JXHorizontalView.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/21.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let reuseIndentifierHeader = "reuseIndentifierHeader"
private let reuseIndentifierFooter = "reuseIndentifierFooter"

class JXHorizontalView: UIView {

    let parentViewController : UIViewController
    let rect : CGRect
    var containers = Array<UIViewController>()
    
    var delegate : JXHorizontalViewDelegate?
    
    
    
    init(frame: CGRect, containers:Array<UIViewController>,parentViewController:UIViewController) {
        
        self.rect = frame
        self.parentViewController = parentViewController
        self.delegate = parentViewController as? JXHorizontalViewDelegate
        self.containers = containers
        
        for vc in containers {
            if vc .isKind(of: UINavigationController.self) {
                assert(false, "can not append UINavigationController")
            }
            self.parentViewController.addChildViewController(vc)
        }
        
        super.init(frame: frame)
        
        self.addSubview(self.containerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func reloadData() {
        let indexPath = IndexPath.init(item: 0, section: 0)
        self.containerView.reloadItems(at: [indexPath])
    }
    
    
    
    lazy var containerView: UICollectionView = {
        
        let flowlayout = UICollectionViewFlowLayout.init()
        flowlayout.itemSize = self.rect.size
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing  = 0.0
        flowlayout.minimumInteritemSpacing = 0.0
        flowlayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        //flowlayout.headerReferenceSize = CGSize.init(width: self.rect.size.width, height: 44)
        
        let collectionView = UICollectionView(frame: CGRect.init(x: 0, y: 0, width: self.rect.width, height: self.rect.height), collectionViewLayout: flowlayout)
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.brown
  
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        return collectionView
    }()
}

protocol JXHorizontalViewDelegate {
    
    func horizontalView(_ :JXHorizontalView,to indexPath:IndexPath) -> Void
    
}

extension JXHorizontalView:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if containers.count > 0 {
            return containers.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = containerView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if containers.count > indexPath.item {
            let vc = containers[indexPath.item]
            vc.view.frame = CGRect.init(x: 0, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
            cell.contentView.addSubview(vc.view)
            vc.didMove(toParentViewController: parentViewController)
            
        }
        return cell
    }
}

extension JXHorizontalView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let page = offset / self.frame.size.width
        let indexPath = IndexPath.init(item: Int(page), section: 0)
        
        self.containerView.reloadItems(at: [indexPath as IndexPath])
        
        if self.delegate != nil{
            self.delegate?.horizontalView(self, to: indexPath)
        }
        
    }
}
