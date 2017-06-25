//
//  JXAlertView.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/25.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

enum JXAlertViewStyle : Int {
    case plain
    case list
    case custom
}
enum JXAlertViewShowPosition {
    case middle
    case bottom
}

private let reuseIdentifier = "reuseIdentifier"
//private let topBarHeight : CGFloat = 40

private let alertViewWidth : CGFloat = UIScreen.main.bounds.width - 40
private let listHeight : CGFloat = 40
private let cancelViewHeight : CGFloat = 40
private let animateDuration : TimeInterval = 0.3

class JXAlertView: UIView {

    var title : String?
    var message : String?
    var actions : Array<String>?
    
    var delegate : JXAlertViewDelegate?
    var style : JXAlertViewStyle = .plain
    var position : JXAlertViewShowPosition = .middle {
        didSet{
            self.resetFrame()
            self.layoutSubviews()
        }
    }
    
    var rect : CGRect = CGRect.init()
    
    var selectRow : Int = -1
    
    private var contentView : UIView?
    
    var selectViewTop : CGFloat = 0
    var topBarHeight : CGFloat = 40 {
        didSet{
            if (self.topBarView.superview == nil){
                self.addSubview(self.topBarView)
            }
            selectViewTop = topBarHeight
            self.resetFrame()
            self.layoutSubviews()
        }
    }
    var isUseTopBar : Bool = false {
        didSet{
            selectViewTop = topBarHeight
            if (self.topBarView.superview == nil){
                self.addSubview(self.topBarView)
            }
            self.resetFrame()
            self.layoutSubviews()
        }
    }
    var isSetCancelView : Bool = false {
        didSet{
            if isSetCancelView {
                self.resetFrame()
                self.addSubview(self.cancelButton)
                self.layoutSubviews()
            }
        }
    }
    
    lazy var topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.groupTableViewBackground
        return view
    }()
    lazy var tableView : UITableView = {
        let table = UITableView.init(frame: CGRect.init(), style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        return table
    }()
    lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.white
        btn.setTitle("取消", for: UIControlState.normal)
        btn.setTitleColor(UIColor.blue, for: UIControlState.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.addTarget(self, action: #selector(tapClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    lazy private var bgWindow : UIWindow = {
        let window = UIWindow()
        window.frame = UIScreen.main.bounds
        window.windowLevel = UIWindowLevelAlert + 1
        window.backgroundColor = UIColor.clear
        window.isHidden = false
        return window
    }()
    
    lazy private var bgView : UIView = {
        let view = UIView()
        view.frame = UIScreen.main.bounds
        view.backgroundColor = UIColor.black
        view.alpha = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    
    init(frame: CGRect, style:JXAlertViewStyle) {
        super.init(frame: frame)
        self.rect = frame
        self.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        self.backgroundColor = UIColor.clear
        self.style = style
        
        if style == .list {
            self.contentView = self.tableView
        }else if style == .custom{
            
        }else{
            
        }
        self.addSubview(self.contentView!)
        self.layoutSubviews()
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func resetFrame() {
        var height = rect.height
        
        if isUseTopBar {
            height += topBarHeight
        }
        if isSetCancelView {
            height += cancelViewHeight
            
            if position == .bottom {
                height += 10
            }
        }
        
        self.frame = CGRect.init(x: 20, y: 0, width: alertViewWidth, height:height)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isUseTopBar {
            topBarView.frame = CGRect.init(x: 0, y: 0, width: alertViewWidth, height: topBarHeight)
            
            //confirmButton.frame = CGRect.init(x: rect.width - 60, y: 0, width: 60, height: topBarHeight)
        }
        
        self.contentView?.frame = CGRect.init(x: 0, y: selectViewTop, width: alertViewWidth, height: rect.height)
        if isSetCancelView {
            cancelButton.frame = CGRect.init(x: 0, y: topBarHeight + rect.height + 10, width: alertViewWidth, height: cancelViewHeight)
        } 
    }
    
    func show(){
        self.show(inView: self.bgWindow)
    }
    
    func show(inView view:UIView? ,animate:Bool = true) {
        
        if style == .custom {
            self.addSubview(contentView!)
        }
        
        let superView : UIView
        
        if let v = view {
            superView = v
        }else{
            superView = self.bgWindow
        }
        //let center = CGPoint.init(x: contentView.center.x, y: contentView.center.y - 64 / 2)
        let center = superView.center
        
        if position == .bottom {
            var frame = self.frame
            frame.origin.y = superView.frame.height
            self.frame = frame
        }else{
            self.center = center
        }
        
        superView.addSubview(self.bgView)
        superView.addSubview(self)
        superView.isHidden = false
        
        if animate {
            UIView.animate(withDuration: animateDuration, delay: 0.0, options: .curveEaseIn, animations: {
                self.bgView.alpha = 0.5
                if self.position == .bottom {
                    var frame = self.frame
                    frame.origin.y = superView.frame.height - self.frame.height
                    self.frame = frame
                }else{
                    self.center = center
                }
            }, completion: { (finished) in
                if self.style == .list {
                    self.tableView.reloadData()
                }else if self.style == .plain {
//                    self.pickView.reloadComponent(0)
//                    if self.selectRow >= 0 {
//                        self.pickView.selectRow(self.selectRow, inComponent: 0, animated: true)
//                    }
                }
            })
        }
    }
    func dismiss(animate:Bool = true) {
        
        if animate {
            UIView.animate(withDuration: animateDuration, delay: 0.0, options: .curveEaseOut, animations: {
                self.bgView.alpha = 0.0
                if self.position == .bottom {
                    var frame = self.frame
                    frame.origin.y = self.superview!.frame.height
                    self.frame = frame
                }else{
                    self.center = self.superview!.center
                }
            }, completion: { (finished) in
                self.clearInfo()
            })
        }else{
            self.clearInfo()
        }
    }
    
    fileprivate func clearInfo() {
        bgView.removeFromSuperview()
        self.removeFromSuperview()
        bgWindow.isHidden = true
        
    }
    @objc private func tapClick() {
        self.dismiss()
    }
    fileprivate func viewDisAppear(row:Int) {
//        if self.delegate != nil && selectRow >= 0{
//            self.delegate?.jxSelectView(self, didSelectRowAt: row)
//        }
        self.dismiss()
    }
}
extension JXAlertView : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (actions?.isEmpty == false) {
            return actions?.count ?? 0
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return listHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = "\(indexPath.row)"
        if actions?.isEmpty == false {
            cell.textLabel?.text = actions?[indexPath.row]
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        if isUseTopBar {
//            selectRow = indexPath.row
//        }else{
//            self.viewDisAppear(row: indexPath.row)
//        }
        self.dismiss(animate: true)
    }
}


protocol JXAlertViewDelegate {
    func jxAlertView(_ :JXAlertView, clickButtonAtIndex index:Int)
    func jxAlertViewCancel(_ :JXAlertView)
    func willPresentJXAlertView(_ :JXAlertView)
    func didPresentJXAlertView(_ :JXAlertView)
}
