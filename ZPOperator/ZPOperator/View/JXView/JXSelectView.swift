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
private let topBarHeight : CGFloat = 40
private let animateDuration : TimeInterval = 0.3

class JXSelectView: UIView {
    
    var rect = CGRect.init()
    var selectViewTop : CGFloat = 0
    var selectRow : Int = -1
    
    var style : JXSelectViewStyle = .list
    let position : JXSelectViewShowPosition = .bottom
    var customView : UIView?
    var isUseTopBar : Bool = false {
        didSet{
            selectViewTop = topBarHeight
            self.addSubview(self.topBarView)
            self.topBarView.addSubview(self.cancelButton)
            self.topBarView.addSubview(self.confirmButton)
            self.layoutSubviews()
        }
    }
    
    
    var delegate : JXSelectViewDelegate?
    var dataSource : JXSelectViewDataSource?
    
    
    lazy var topBarView: UIView = {
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
        table.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
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
        self.rect = frame
        self.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        self.backgroundColor = UIColor.white
        self.style = style
        
        if style == .list {
            self.addSubview(self.tableView)
        }else{
            self.addSubview(self.pickView)
        }
    }
    init(frame:CGRect, customView:UIView) {
        super.init(frame: frame)
        self.rect = frame
        self.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        self.backgroundColor = UIColor.white
        self.style = .custom
        self.customView = customView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isUseTopBar {
            topBarView.frame = CGRect.init(x: 0, y: 0, width: rect.width, height: topBarHeight)
            cancelButton.frame = CGRect.init(x: 0, y: 0, width: 60, height: topBarHeight)
            confirmButton.frame = CGRect.init(x: rect.width - 60, y: 0, width: 60, height: topBarHeight)
        }
        
        
        if style == .list {
            tableView.frame = CGRect.init(x: 0, y: selectViewTop, width: rect.width, height: rect.height)
        } else if style == .pick {
            pickView.frame = CGRect.init(x: 0, y: selectViewTop, width: rect.width, height: 216)
        } else {
            if customView != nil {
                customView?.frame = CGRect.init(x: 0, y: selectViewTop, width: rect.width, height: rect.height)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(){
        self.show(inView: self.bgWindow)
    }
    
    func show(inView view:UIView? ,animate:Bool = true) {
        
        if customView != nil && style == .custom {
            self.addSubview(customView!)
        }
        
        let contentView : UIView
        
        if let v = view {
            contentView = v
        }else{
            contentView = self.bgWindow
        }
        //let center = CGPoint.init(x: contentView.center.x, y: contentView.center.y - 64 / 2)
        let center = contentView.center
        
        if position == .top {
            var frame = self.frame
            frame.origin.y = 0.0 - self.frame.height
            self.frame = rect
        }else if position == .bottom {
            var frame = self.frame
            frame.origin.y = contentView.frame.height
            self.frame = frame
        }else{
            self.center = center
        }
        
        contentView.addSubview(self.bgView)
        contentView.addSubview(self)
        contentView.isHidden = false
        
        if animate {
            UIView.animate(withDuration: animateDuration, delay: 0.0, options: .curveEaseIn, animations: {
                self.bgView.alpha = 0.5
                if self.position == .top{
                    var frame = self.frame
                    frame.origin.y = 0.0
                    self.frame = frame
                }else if self.position == .bottom {
                    var frame = self.frame
                    frame.origin.y = contentView.frame.height - self.frame.height
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
    
    func clearInfo() {
        bgView.removeFromSuperview()
        self.removeFromSuperview()
        bgWindow.isHidden = true
    }
    func tapClick() {
        self.dismiss()
    }
    func viewDisAppear(row:Int) {
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
            return dataSource?.jxSelectView(self, heightForRowAt: indexPath.row) ?? 44
        }
        return 44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = "\(indexPath.row)"
        if dataSource != nil {
            cell.textLabel?.text = dataSource?.jxSelectView(self, contentForRow: indexPath.row, InSection: indexPath.section)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isUseTopBar {
            selectRow = indexPath.row
        }else{
            self.viewDisAppear(row: indexPath.row)
        }
        self.dismiss(animate: true)
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
        return self.rect.width
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isUseTopBar {
            selectRow = row
        }else{
            self.viewDisAppear(row: row)
        }
    }
    
    
}
protocol JXSelectViewDataSource {
    
    func jxSelectView(_ :JXSelectView, numberOfRowsInSection section:Int) -> Int
    
    func jxSelectView(_ :JXSelectView, contentForRow row:Int, InSection section:Int) -> String
    func jxSelectView(_ :JXSelectView, heightForRowAt row:Int) -> CGFloat
}
protocol JXSelectViewDelegate {
    
    func jxSelectView(_ :JXSelectView, didSelectRowAt row:Int)
}
