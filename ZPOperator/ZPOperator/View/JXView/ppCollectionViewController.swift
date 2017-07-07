//
//  ppCollectionViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/7/7.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ppCollectionViewController: UICollectionViewController {
    
    var images = Array<String>()
    var currentPage = 1
    
    lazy var pageLabel: UILabel = {
        let lab = UILabel()
        lab.frame = CGRect(origin: CGPoint(), size: CGSize(width: 100, height: 30))
        lab.textColor = UIColor.white
        lab.textAlignment = .center
        return lab
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        images = [
            "http://img.izheng.org/d879ec5f-43dc-4860-ba35-ca63c974a83b",
            "http://img.izheng.org/e0cc9b48-aaad-47a4-bc0b-1133189b148d",
            "http://img.izheng.org/be2c15bb-d877-4580-802e-57e2252c4600"
        ]
        
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = view.bounds.size
        layout.scrollDirection = .horizontal

        self.collectionView?.collectionViewLayout = layout
        self.collectionView?.isPagingEnabled = true
        self.collectionView?.showsVerticalScrollIndicator = false
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView!.register(PhotoImageView.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        
        view.addSubview(self.pageLabel)
        
        pageLabel.center = CGPoint(x: view.center.x, y: view.bounds.height - 80)
        pageLabel.text = "\(self.currentPage)/\(self.images.count)"
        

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoImageView
    
        // Configure the cell
        cell.imageView.backgroundColor = UIColor.randomColor
        cell.imageView.setImageWith(URL.init(string: self.images[indexPath.item])!, placeholderImage: nil)
        cell.closeBlock = { _ in
            self.dismiss(animated: true, completion: nil)
        }
    
        return cell
    }
    // MARK: UICollectionViewDelegate

}
extension ppCollectionViewController {
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x / view.bounds.width
        currentPage = Int(offset)
        pageLabel.text = "\(self.currentPage + 1)/\(self.images.count)"
    }
    
}

class PhotoImageView: UICollectionViewCell,UIScrollViewDelegate {

    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.minimumZoomScale = 1.0
        scroll.maximumZoomScale = 3.0 //不设置范围，缩放不起作用
        scroll.delegate = self
        return scroll
    }()
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(tapZoomScale(tap:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        iv.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapDismiss(tap:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        singleTap.require(toFail: doubleTap)//单击事件需要双击事件失败才响应，不然优先响应双击
        iv.addGestureRecognizer(singleTap)
        
        return iv
    }()
    var closeBlock : (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        
        self.scrollView.frame = self.contentView.bounds
        self.imageView.frame = self.scrollView.bounds
        
        self.scrollView.addSubview(self.imageView)
        self.contentView.addSubview(self.scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapDismiss(tap:UITapGestureRecognizer) {
        //收起
        print("收起")
        if let block = closeBlock {
            block()
        }
    }
    /// 缩放
    ///
    /// - Parameter tap: 双击
    func tapZoomScale(tap:UITapGestureRecognizer) {
        //
        UIView.animate(withDuration: 0.3, animations: { 
            if self.scrollView.zoomScale == 1.0 {
                self.scrollView.zoomScale = 3.0
            }else {
                self.scrollView.zoomScale = 1.0
            }
        }) { (finished) in
            //
        }
    }
    /// 获取要缩放的视图
    ///
    /// - Parameter scrollView: scrollview
    /// - Returns: 要缩放的视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        var centerX = scrollView.center.x
        var centerY = scrollView.center.y
        centerX = scrollView.contentSize.width > scrollView.frame.size.width ?
            scrollView.contentSize.width/2:centerX
        centerY = scrollView.contentSize.height > scrollView.frame.size.height ?
            scrollView.contentSize.height/2:centerY
        print(centerX,centerY)
        self.imageView.center = CGPoint(x: centerX, y: centerY)
    }
}
