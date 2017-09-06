//
//  TraceSourceCell.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/22.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class TraceSourceCell: UITableViewCell {
    @IBOutlet weak var mainContentView: UIView!

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    @IBOutlet weak var labelDetail1: UILabel!
    @IBOutlet weak var labelDetail2: UILabel!
    @IBOutlet weak var labelDetail3: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    var imageViewBlock : ((_ index:Int)->())?
    
    
    var model : TraceSourceRecord? {
        didSet{
            self.labelDetail1.text = model?.createBy
            self.labelDetail2.text = model?.traceProcess
            self.labelDetail3.text = model?.location
            self.textView.text = model?.contents
            
            self.timeLabel.text = model?.operationTime
            if let isMine = model?.isMine,isMine == true {
                self.labelDetail1.textColor = JXMainColor
            }else{
                self.labelDetail1.textColor = UIColor.rgbColor(rgbValue: 0x333333)
            }
            
            
            if let array = model?.images {
                if array.count > 2 {
                    self.imageView1.setImageWith(URL.init(string: array[0])!, placeholderImage: nil)
                    self.imageView2.setImageWith(URL.init(string: array[1])!, placeholderImage: nil)
                    self.imageView3.setImageWith(URL.init(string: array[2])!, placeholderImage: nil)
                    
                    self.imageView1.isHidden = false
                    self.imageView2.isHidden = false
                    self.imageView3.isHidden = false
                }else if array.count == 2{
                    self.imageView1.setImageWith(URL.init(string: array[0])!, placeholderImage: nil)
                    self.imageView2.setImageWith(URL.init(string: array[1])!, placeholderImage: nil)
                    self.imageView3.image = nil
                    
                    self.imageView1.isHidden = false
                    self.imageView2.isHidden = false
                    self.imageView3.isHidden = true
                }else if array.count == 1{
                    self.imageView1.setImageWith(URL.init(string: array[0])!, placeholderImage: nil)
                    self.imageView2.image = nil
                    self.imageView3.image = nil
                    
                    self.imageView1.isHidden = false
                    self.imageView2.isHidden = true
                    self.imageView3.isHidden = true
                }else{
                    self.imageView1.image = nil
                    self.imageView2.image = nil
                    self.imageView3.image = nil
                    
                    self.imageView1.isHidden = true
                    self.imageView2.isHidden = true
                    self.imageView3.isHidden = true
                }
            }else{
                self.imageView1.image = nil
                self.imageView2.image = nil
                self.imageView3.image = nil
                
                self.imageView1.isHidden = true
                self.imageView2.isHidden = true
                self.imageView3.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imageView1.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tap(tap:))))
        self.imageView2.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tap(tap:))))
        self.imageView3.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tap(tap:))))
        
    }

    func tap(tap:UITapGestureRecognizer) {
        
        if
            let block = self.imageViewBlock,
            let index = tap.view?.tag{
            block(index)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
