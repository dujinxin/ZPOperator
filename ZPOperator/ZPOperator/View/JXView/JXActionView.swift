//
//  JXActionView.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/12/22.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

enum JXActionViewStyle : Int {
    case plain
    case list
    case custom
}

private let reuseIdentifier = "reuseIdentifier"

private let topBarHeight : CGFloat = 40
private let actionViewMargin : CGFloat = 0
private let actionViewWidth : CGFloat = UIScreen.main.bounds.width - 2 * actionViewMargin
private let listHeight : CGFloat = 40
private let bottomViewHeight : CGFloat = (deviceModel == .iPhoneX) ? 74 : 40 //(iPhoneX 底部 多出34)
private let animateDuration : TimeInterval = 0.3

class JXActionView: UIView {
    
    private var alertViewHeight : CGFloat = 0
    private var alertViewTopHeight : CGFloat = 0
    
    var title : String?
    var message : String?
    var actions : Array<String> = [String](){
        didSet{
            if actions.count > 5 {
                self.tableView.isScrollEnabled = true
                self.tableView.bounces = true
                self.tableView.showsVerticalScrollIndicator = true
            }else{
                self.tableView.isScrollEnabled = false
                self.tableView.bounces = false
                self.tableView.showsVerticalScrollIndicator = false
            }
            //self.resetFrame()
        }
    }
    
    var delegate : JXActionViewDelegate?
    var style : JXActionViewStyle = .plain

    var selectRow : Int = -1
    var contentHeight : CGFloat {
        set{//可以自己指定值带来替默认值eg: （myValue）
            var h : CGFloat = 0
            if newValue > 0 {
                h = newValue
                alertViewHeight = newValue
            }else{
                if style == .list{
                    let num : CGFloat = CGFloat(self.actions.count)
                    h = (num > 5 ? 5.5 : num) * listHeight
                    alertViewHeight = h
                }
            }
            if isUseTopBar {
                h += topBarHeight
            }
            self.frame = CGRect(x: actionViewMargin, y: 0, width: actionViewWidth, height: alertViewHeight + topBarHeight + bottomViewHeight + 10)
        }
        get{
            return self.frame.height
        }
    }
    
    var isScrollEnabled : Bool = false {
        didSet{
            if isScrollEnabled == true {
                self.tableView.isScrollEnabled = true
                self.tableView.bounces = true
                self.tableView.showsVerticalScrollIndicator = true
            }else{
                self.tableView.isScrollEnabled = false
                self.tableView.bounces = false
                self.tableView.showsVerticalScrollIndicator = false
            }
        }
    }
    
    var isUseTopBar : Bool = false {
        didSet{
            if isUseTopBar {
                alertViewTopHeight = topBarHeight
                if (self.topBarView.superview == nil){
                    self.addSubview(self.topBarView)
                }
            }else{
                alertViewTopHeight = 0
                if (self.topBarView.superview != nil){
                    self.topBarView.removeFromSuperview()
                }
            }
        }
    }
    var isUseBottomView : Bool = false {
        didSet{
            if isUseBottomView {
                self.addSubview(self.bottomBarView)
            }
        }
    }
    private var contentView : UIView?
    var customView: UIView? {
        didSet{
            self.contentView = customView
        }
    }
    lazy var topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.groupTableViewBackground
        return view
    }()
    lazy var bottomBarView: BottomBarView = {
        let view = BottomBarView()
        view.backgroundColor = UIColor.white
        
        view.cancelBlock = {(_) in
            self.tapClick()
        }
        return view
    }()
    lazy var tableView : UITableView = {
        let table = UITableView.init(frame: CGRect.init(), style: .plain)
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.bounces = false
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.separatorStyle = .none
        table.register(ActionlistViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        return table
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
    
    
    init(frame: CGRect, style:JXActionViewStyle) {
        super.init(frame: frame)
        //self.rect = frame
        //self.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        self.backgroundColor = UIColor.clear
        self.style = style
        
        if style == .list {
            self.contentView = self.tableView
        }else if style == .custom{
            
        }else{
            
        }
        alertViewHeight = frame.height
        //self.resetFrame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func resetFrame(height:CGFloat = 0.0) {
        var h : CGFloat = 0
        if height > 0 {
            h = height
            alertViewHeight = height
        }else{
            if style == .list{
                let num : CGFloat = CGFloat(self.actions.count)
                h = (num > 5 ? 5.5 : num) * listHeight
                alertViewHeight = h
            }
        }
        if isUseTopBar {
            h += topBarHeight
        }
        if isUseBottomView {
            h += bottomViewHeight + 10
        }
        self.frame = CGRect.init(x: (UIScreen.main.bounds.width - actionViewWidth)/2, y: 0, width: actionViewWidth, height:h)
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isUseTopBar {
            topBarView.frame = CGRect(x: 0, y: 0, width: actionViewWidth, height: alertViewTopHeight)
            //confirmButton.frame = CGRect.init(x: rect.width - 60, y: 0, width: 60, height: topBarHeight)
        }
        
        self.contentView?.frame = CGRect(x: 0, y: alertViewTopHeight, width: actionViewWidth, height: alertViewHeight)
        if isUseBottomView {
            self.bottomBarView.frame = CGRect(x: 0, y: alertViewTopHeight + alertViewHeight + 10, width: actionViewWidth, height: bottomViewHeight)
        }
    }
    
    func show(){
        self.show(inView: self.bgWindow)
    }
    
    func show(inView view:UIView? ,animate:Bool = true) {
        
        self.addSubview(self.contentView!)
        self.resetFrame()
        
        let superView : UIView
        
        if let v = view {
            superView = v
        }else{
            superView = self.bgWindow
        }
        var frame = self.frame
        frame.origin.y = superView.frame.height
        self.frame = frame

        
        superView.addSubview(self.bgView)
        superView.addSubview(self)
        superView.isHidden = false
        
        if animate {
            UIView.animate(withDuration: animateDuration, delay: 0.0, options: .curveEaseIn, animations: {
                self.bgView.alpha = 0.5

                var frame = self.frame
                frame.origin.y = superView.frame.height - self.frame.height
                self.frame = frame
            }, completion: { (finished) in
                if self.style == .list {
                    self.tableView.reloadData()
                }else if self.style == .plain {
                    
                }
            })
        }
    }
    func dismiss(animate:Bool = true) {
        
        if animate {
            UIView.animate(withDuration: animateDuration, delay: 0.0, options: .curveEaseOut, animations: {
                self.bgView.alpha = 0.0

                var frame = self.frame
                frame.origin.y = self.superview!.frame.height
                self.frame = frame
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
extension JXActionView : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (actions.isEmpty == false) {
            return actions.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return listHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ActionlistViewCell
        
        if actions.isEmpty == false {
            cell.titleLabel.text = actions[indexPath.row]
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
        
        
        //self.delegate?.willPresentJXActionView!(self)
        self.delegate?.jxActionView(self, clickButtonAtIndex: indexPath.row)
        self.dismiss()
        //self.delegate?.didPresentJXActionView!(self)
        
    }
}

class ActionlistViewCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = JX333333Color
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = JXSeparatorColor
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.separatorView)
        self.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.separatorView.frame = CGRect.init(x: 0, y: self.bounds.height - 0.5, width: self.bounds.width, height: 0.5)
    }
}
class BottomBarView: UIView {
    var isPlaying : Bool = true
    var isFullScreen : Bool = false

    lazy var cancelItem: UIButton = {
        let button = UIButton()
        //button.setTitle("暂停", for: .selected)
        button.setTitle(LanguageManager.localizedString("Cancel"), for: .normal)
        button.setTitleColor(JX333333Color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.isSelected = true
        button.tag = 10
        button.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
        return button
    }()
    
    var cancelBlock : ((_ isPlaying:Bool)->())?
    var additionBlock : ((_ isPlaying:Bool)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let height : CGFloat = (deviceModel == .iPhoneX) ? 34.0 : 0.0
        
        self.cancelItem.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - height)
    }
    func initSubViews() {
        addSubview(self.cancelItem)
    }
    
    func buttonClick(button:UIButton) {
        button.isSelected = !button.isSelected
        
        switch button.tag {
        case 10:
            if let block = cancelBlock {
                isPlaying = !isPlaying
                block(isPlaying)
            }
        default:
            
            if let block = additionBlock {
                isFullScreen = !isFullScreen
                block(isFullScreen)
            }
        }
    }
}
@objc protocol JXActionViewDelegate {
    
    func jxActionView(_ actionView :JXActionView, clickButtonAtIndex index:Int)
    @objc optional func jxActionViewCancel(_ :JXActionView)
    @objc optional func willPresentJXActionView(_ :JXActionView)
    @objc optional func didPresentJXActionView(_ :JXActionView)
    
}
