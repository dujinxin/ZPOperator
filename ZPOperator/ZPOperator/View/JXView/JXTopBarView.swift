//
//  JXTopBarView.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/22.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class JXTopBarView: UIView {
    
    let titles : Array<String> = []
    var delegate : JXTopBarViewDelegate?
    var selectedIndex = 0
    var attribute = TopBarAttribute.init()
//    {
//        didSet{
//            for (i,v) in subviews {
//                if v {
//                    <#code#>
//                }
//            }
//        }
//    }
    
    
    var isBottomLineEnabled : Bool
    
    

//    override func draw(_ rect: CGRect) {
//        // Drawing code
//        let context = UIGraphicsGetCurrentContext()
//        context?.setLineCap(CGLineCap.round)
//        context?.setLineWidth(1)
//        context?.setAllowsAntialiasing(true)
//        context?.setStrokeColor(UIColor.groupTableViewBackground.cgColor)
//        context?.beginPath()
//        
//        if titles.count > 0 {
//            
//        }
//    }
    
    init(frame: CGRect,titles:Array<String>) {
        
        selectedIndex = 0
        isBottomLineEnabled = false
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        let width = frame.size.width / CGFloat(titles.count)
        let height = frame.size.height
        
        
        for i in 0..<titles.count {
            let button = UIButton()
            button.frame = CGRect.init(x: (width * CGFloat(i)), y: 0, width: width, height: height)
            button.setTitle(titles[i], for: UIControlState.normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(attribute.normalColor, for: UIControlState.normal)
            button.setTitleColor(attribute.highlightedColor, for: UIControlState.selected)
            button.tag = i
            
            button.addTarget(self, action: #selector(TabButtonAction(button:)), for: UIControlEvents.touchUpInside)
            
            self.addSubview(button)
            
            if i == 0 {
                button.isSelected = true
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func TabButtonAction(button : UIButton) {
        print(button.tag)
        
        selectedIndex = button.tag
        
        button.isSelected = true
        
        self.subviews.forEach { (v : UIView) -> () in
//            if let (v is UIButton.self),
//               let btn = v as! UIButton,
//                   btn.tag != button.tag{
//                btn.isEnabled = false
//            }
            
            if (v is UIButton){
                if (v.tag != button.tag){
                    let btn = v as! UIButton
                    btn.isSelected = false
                }
            }
        }
        
        if self.delegate != nil {
            self.delegate?.jxTopBarView(topBarView: self, didSelectTabAt: button.tag)
        }
    }
    

}

extension JXTopBarView{
    
}

protocol JXTopBarViewDelegate {
    
    func jxTopBarView(topBarView : JXTopBarView,didSelectTabAt index:Int) -> Void
}

class TopBarAttribute: NSObject {
    var normalColor = UIColor.darkGray
    var highlightedColor = UIColor.red
    var separatorColor = UIColor.groupTableViewBackground
    
    
    
    override init() {
        normalColor = UIColor.darkGray
        highlightedColor = UIColor.red
        separatorColor = UIColor.groupTableViewBackground
    }
}
        
