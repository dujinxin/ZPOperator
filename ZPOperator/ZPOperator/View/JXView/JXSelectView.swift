//
//  JXSelectView.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/24.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

enum JXSelectViewStyle : Int {
    case list
    case pick
    case custom
}
enum JXSelectViewShowPosition {
    case top
    case middle
    case bottom
}

private let reuseIdentifier = "reuseIdentifier"
private let topBarHeight : CGFloat = 60
private let pickViewCellHeight : CGFloat = 44
private let tableViewCellHeight : CGFloat = 44
private let selectViewWidth : CGFloat = UIScreen.main.bounds.width
private let pickViewHeight : CGFloat = 216
private let animateDuration : TimeInterval = 0.3

class JXSelectView: UIView {
    
    //var rect = CGRect.init()
    private var selectViewHeight : CGFloat = pickViewHeight
    private var selectViewTop : CGFloat = 0
    var selectRow : Int = -1
    
    var style : JXSelectViewStyle = .list
    let position : JXSelectViewShowPosition = .bottom
    private var contentView : UIView?
    var isUseTopBar : Bool = false {
        didSet{
            if isUseTopBar == true {
                selectViewTop = topBarHeight
                self.addSubview(self.topBarView)
                //self.topBarView.addSubview(self.cancelButton)
                //self.topBarView.addSubview(self.confirmButton)
            }
            self.resetFrame()
        }
    }
    
    
    var delegate : JXSelectViewDelegate?
    var dataSource : JXSelectViewDataSource?
    
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
    var isEnabled : Bool = true {
        didSet{
            
        }
    }
    
    
    var topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.groupTableViewBackground
        return view
    }()
    lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: UIControlState.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.addTarget(self, action: #selector(tapClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("确定", for: UIControlState.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.addTarget(self, action: #selector(tapClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
   
    lazy var tableView : UITableView = {
        let table = UITableView.init(frame: CGRect.init(), style: .plain)
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.bounces = false
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        //table.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        return table
    }()
    lazy var pickView: UIPickerView = {
        let pick = UIPickerView.init(frame: CGRect.init())
        pick.delegate = self
        pick.dataSource = self
        return pick
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
    
    
    init(frame: CGRect, style:JXSelectViewStyle) {
        super.init(frame: frame)
        //self.rect = frame
        self.backgroundColor = UIColor.white
        self.style = style
        
        if style == .list {
            self.contentView = self.tableView
        }else{
            self.contentView = self.pickView
        }
        selectViewHeight = frame.height
        self.resetFrame()
        
    }
    init(frame:CGRect, customView:UIView) {
        super.init(frame: frame)
        //self.rect = frame
        self.backgroundColor = UIColor.white
        self.style = .custom
        self.contentView = customView
        selectViewHeight = customView.bounds.height
        self.resetFrame()
    }
    func resetFrame(height:CGFloat = 0.0) {
        var h : CGFloat
        if height > 0 {
            h = height
            selectViewHeight = height
        }else{
            if style == .list{
                let num = self.dataSource?.jxSelectView(self, numberOfRowsInSection: 0) ?? 0
                h = CGFloat(num > 5 ? 5 : num) * tableViewCellHeight
                if num > 5 {
                    tableView.isScrollEnabled = true
                    tableView.bounces = true
                    tableView.showsVerticalScrollIndicator = true
                }else{
                    tableView.isScrollEnabled = false
                    tableView.bounces = false
                    tableView.showsVerticalScrollIndicator = false
                }
            } else if style == .pick{
                h = pickViewHeight
            } else {
                h = selectViewHeight
            }
        }
        if isUseTopBar {
            h += topBarHeight
        }
        self.frame = CGRect.init(x: 0, y: 0, width: selectViewWidth, height:h)
        self.layoutSubviews()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isUseTopBar {
            topBarView.frame = CGRect.init(x: 0, y: 0, width: selectViewWidth, height: topBarHeight)
            cancelButton.frame = CGRect.init(x: 0, y: 0, width: 60, height: topBarHeight)
            confirmButton.frame = CGRect.init(x: selectViewWidth - 60, y: 0, width: 60, height: topBarHeight)
        }
        
        
        if style == .pick {
            self.contentView?.frame = CGRect.init(x: 0, y: selectViewTop, width: selectViewWidth, height: pickViewHeight)
        } else {
            self.contentView?.frame = CGRect.init(x: 0, y: selectViewTop, width: selectViewWidth, height: selectViewHeight)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(){
        self.show(inView: self.bgWindow)
    }
    
    func show(inView view:UIView? ,animate:Bool = true) {
        
        self.addSubview(self.contentView!)
        self.resetFrame(height: selectViewHeight)
        
        
        let superView : UIView
        
        if let v = view {
            superView = v
        }else{
            superView = self.bgWindow
        }
        //let center = CGPoint.init(x: contentView.center.x, y: contentView.center.y - 64 / 2)
        let center = superView.center
        
        if position == .top {
            var frame = self.frame
            frame.origin.y = 0.0 - self.frame.height
            self.frame = frame
        }else if position == .bottom {
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
                if self.position == .top{
                    var frame = self.frame
                    frame.origin.y = 0.0
                    self.frame = frame
                }else if self.position == .bottom {
                    var frame = self.frame
                    frame.origin.y = superView.frame.height - self.frame.height
                    self.frame = frame
                }else{
                    self.center = center
                }
            }, completion: { (finished) in
                if self.style == .list {
                    self.tableView.reloadData()
                }else if self.style == .pick {
                    self.pickView.reloadComponent(0)
                    if self.selectRow >= 0 {
                        self.pickView.selectRow(self.selectRow, inComponent: 0, animated: true)
                    }
                }
            })
        }
    }
    func dismiss(animate:Bool = true) {
        
        if animate {
            UIView.animate(withDuration: animateDuration, delay: 0.0, options: .curveEaseOut, animations: {
                self.bgView.alpha = 0.0
                if self.position == .top {
                    var frame = self.frame
                    frame.origin.y = 0.0 - self.frame.height
                    self.frame = frame
                }else if self.position == .bottom {
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
        if self.delegate != nil && selectRow >= 0{
            self.delegate?.jxSelectView(self, didSelectRowAt: row)
        }
        self.dismiss()
    }
}

extension JXSelectView : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (dataSource != nil) {
            return dataSource?.jxSelectView(self, numberOfRowsInSection: section) ?? 0
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataSource != nil {
            return dataSource?.jxSelectView(self, heightForRowAt: indexPath.row) ?? tableViewCellHeight
        }
        return tableViewCellHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        //let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: reuseIdentifier)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell?.textLabel?.numberOfLines = 1
            if isEnabled == false{
                cell?.selectionStyle = .none
            }
            if dataSource != nil {
                if let view = dataSource?.jxSelectView!(self, viewForRow: indexPath.row) {
                    view.tag = 666
                    cell?.contentView.addSubview(view)
                }
            }
        }

        if let view = cell?.contentView.viewWithTag(666){
            view.isHidden = false
        }else{
            cell?.textLabel?.text = dataSource?.jxSelectView(self, contentForRow: indexPath.row, InSection: indexPath.section)
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isEnabled {
            tableView.deselectRow(at: indexPath, animated: true)
            if isUseTopBar {
                selectRow = indexPath.row
            }else{
                self.viewDisAppear(row: indexPath.row)
                self.dismiss(animate: true)
            }
        }else{
            
        }
        
    }
}
extension JXSelectView : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.dataSource != nil {
            return self.dataSource?.jxSelectView(self, numberOfRowsInSection: component) ?? 0
        }
        return 0
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.dataSource != nil {
            return self.dataSource?.jxSelectView(self, contentForRow: row, InSection: component)
        }
        return nil
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return selectViewWidth
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickViewCellHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isUseTopBar {
            selectRow = row
        }else{
            self.viewDisAppear(row: row)
        }
    }
    
    
}
@objc protocol JXSelectViewDataSource {
    
    func jxSelectView(_ :JXSelectView, numberOfRowsInSection section:Int) -> Int
    func jxSelectView(_ :JXSelectView, heightForRowAt row:Int) -> CGFloat
    func jxSelectView(_ :JXSelectView, contentForRow row:Int, InSection section:Int) -> String
    
    @objc optional func jxSelectView(_ :JXSelectView, viewForRow row:Int) -> UIView?
    
}
protocol JXSelectViewDelegate {
    
    func jxSelectView(_ :JXSelectView, didSelectRowAt row:Int)
}

