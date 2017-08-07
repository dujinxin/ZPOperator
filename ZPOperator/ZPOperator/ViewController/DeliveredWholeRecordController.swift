//
//  DeliveredWholeRecordController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/30.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import TZImagePickerController

class DeliveredWholeRecordController: ZPTableViewController {
    
    
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var operatorLabel: UILabel!
    @IBOutlet weak var processLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var textView: JXPlaceHolderTextView!
    
    @IBOutlet weak var contentView1: UIView!
    @IBOutlet weak var contentView2: UIView!
    @IBOutlet weak var contentView3: UIView!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    var traceSourceRecord : TraceSourceRecord?
    var processId : NSNumber?//溯源批次id
    var processName : String?//溯源批次名称
    
    var addressStr : String?
    var isProcessAlert : Int = 0
    
    var block : (()->())?
    var isAddTraceSource = true
    var traceRecordId : NSNumber?//修改时用

    var batchId : NSNumber? //全程溯源来源需要用
    
    var vm = TraceSRecordVM()
    var jxAlertView : JXAlertView?
    var uploadManager = QiNiuUploadManager()
    
    var processArray = Array<String>()
    var addressArray = Array<String>()
    
    var imageArray = Array<UIImage>()
    var imageDataArray = Array<Data>()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.jxAlertView = JXAlertView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 300), style: .list)
        
        self.jxAlertView?.position = .bottom
        self.jxAlertView?.isSetCancelView = true
        self.jxAlertView?.delegate = self
        
//        productLabel.text = self.traceBatch
//        operatorLabel.text = "操作人 " + LoginVM.loginVMManager.userModel.userName!
        
        textView.placeHolderText = "请输入溯源信息内容"
        
        submitButton.layer.cornerRadius = 5
        submitButton.backgroundColor = JXGrayColor
        submitButton.isEnabled = false
        
        setImages(images: self.imageArray)
        
        
        imageView1.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(photo11)))
        imageView2.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(photo11)))
        imageView3.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(photo11)))
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationStatus(notify:)), name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: nil)
        //开启定位
        JXLocationManager.manager.startUpdateLocation()
        
        //一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用
        

        
        
        if isAddTraceSource == false { //修改
            
            self.processName = self.traceSourceRecord?.traceProcess
            self.processId = self.traceSourceRecord?.traceProcessId
            self.processLabel.text = self.processName
            
            if
                let contents = self.traceSourceRecord?.contents,
                contents.isEmpty == false {
                self.textView.text = contents
            }
            if let batchId = batchId {
                self.vm.fetchTraceSourceWholeRecord(batchId: batchId, completion: { (data, msg, isSuccess) in
                    if isSuccess{
                        //格式化数组
                        self.productLabel.text = self.vm.traceSourceWholeModify.traceSourceWholeProduct.goodsName
                        self.operatorLabel.text = "发货批次号 " + (self.vm.traceSourceWholeModify.traceSourceWholeProduct.code ?? "")
                        for model in self.vm.traceSourceWholeModify.traceProcesses{
                            self.processArray.append(model.name!)
                        }
                        self.addressLabel.text = self.vm.traceSourceWholeModify.Operator.station
                        
                        self.submitButton.backgroundColor = JXOrangeColor
                        self.submitButton.isEnabled = true
                    }
                })
            }
        }else{  //添加
            if let batchId = batchId {
                self.vm.fetchTraceSourceWholeRecord(batchId: batchId, completion: { (data, msg, isSuccess) in
                    if isSuccess{
                        //格式化数组
                        self.productLabel.text = self.vm.traceSourceWholeModify.traceSourceWholeProduct.goodsName
                        self.operatorLabel.text = "发货批次号 " + (self.vm.traceSourceWholeModify.traceSourceWholeProduct.code ?? "")
                        for model in self.vm.traceSourceWholeModify.traceProcesses{
                            self.processArray.append(model.name!)
                        }
                        
                        self.processLabel.text = "请选择"
                    }
                })
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: nil)
    }
    @IBAction func delete1(_ sender: Any) {
        self.imageArray.remove(at: 0)
        self.imageDataArray.remove(at: 0)
        self.setImages(images: self.imageArray)
    }
    @IBAction func delete2(_ sender: Any) {
        self.imageArray.remove(at: 1)
        self.imageDataArray.remove(at: 1)
        self.setImages(images: self.imageArray)
    }
    @IBAction func delete3(_ sender: Any) {
        self.imageArray.remove(at: 2)
        self.imageDataArray.remove(at: 2)
        self.setImages(images: self.imageArray)
    }
    
    @IBAction func submit(_ sender: UIButton) {
        guard let _ = self.addressLabel.text else {
            ViewManager.showNotice(notice: "请选择操作地点")
            return
        }
        guard let _ = self.processId else {
            ViewManager.showNotice(notice: "请选择操作过程")
            return
        }
        
        self.showMBProgressHUD()
        if self.imageDataArray.count != 0 {
            self.uploadManager.qiniuUpload(datas: self.imageDataArray) { (array) in
                print("imageArrayUrl = \(String(describing: array))")
                
                if let arr = array,
                    arr.count != 0 {
                    var file = ""
                    for i in 0..<arr.count {
                        file += arr[i]
                        if i != arr.count - 1 {
                            file += ","
                        }
                    }
                    self.submitLast(file: file)
                }
            }
        }else{
            self.submitLast(file: nil)
        }
    }
    
    func submitLast(file:String?) {
        let id : NSNumber?
        if isAddTraceSource == false {
            id = self.traceSourceRecord?.id
        }else{
            id = nil
        }
        self.vm.updateTraceSourceWholeRecord(id: id, traceTemplateBatchId: batchId!, traceProcessId: self.processId!, traceProcessName: self.processName!, location: (self.addressLabel.text)!, file: file, contents: self.textView.text) { (data, msg, isSuccess) in
            self.hideMBProgressHUD()
            ViewManager.showNotice(notice: msg)
            if isSuccess{
                if let myblock = self.block {
                    myblock()
                }
                self.navigationController?.popViewController(animated: true)
            }else{
                
            }
        }
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 10
        }else if section == 2 {
            return 64
        }else{
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    //    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        if indexPath.section == 1 && indexPath.row == 2 {
    //            return 180
    //        }else{
    //            return 44
    //        }
    //    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.textView.resignFirstResponder()
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                isProcessAlert = 0
                self.jxAlertView?.actions = processArray
                self.jxAlertView?.show()
            }else if indexPath.row == 1{
                isProcessAlert = 1
                self.addressArray.removeAll()
                if JXLocationManager.manager.address.characters.count > 0 {
                    self.addressArray.append(JXLocationManager.manager.address)
                }
                if isAddTraceSource == false {
                    self.addressArray.append(self.vm.traceSourceWholeModify.Operator.station!)
                }else {
                    self.addressArray.append(self.vm.traceSourceWholeModify.Operator.station!)
                }
                self.jxAlertView?.actions = addressArray
                self.jxAlertView?.show()
                
            }else{
                
            }
        }
    }
}
extension DeliveredWholeRecordController : JXAlertViewDelegate{
    func jxAlertView(_ alertView: JXAlertView, clickButtonAtIndex index: Int) {
        if isProcessAlert == 0 {
            self.processLabel.text = self.vm.traceSourceWholeModify.traceProcesses[index].name
            self.processId = self.vm.traceSourceWholeModify.traceProcesses[index].id
            self.processName = self.vm.traceSourceWholeModify.traceProcesses[index].name
        }else if isProcessAlert == 1{
            self.addressLabel.text = self.addressArray[index]
        }else {
            if index == 0 {
                let imagePickerVC = TZImagePickerController.init(maxImagesCount: 3 - self.imageArray.count, delegate: self)
                imagePickerVC?.allowTakePicture = false
                
                imagePickerVC?.allowPickingImage = true
                imagePickerVC?.allowPickingOriginalPhoto = true
                
                imagePickerVC?.sortAscendingByModificationDate = true
                
                imagePickerVC?.didFinishPickingPhotosHandle = { (images, assets, isSelectOriginalPhoto) -> () in
                    
                    if let images = images {
                        self.imageArray += images
                        self.setImages(images: self.imageArray)
                    }
            
                    for asset in assets! {
                        
                        PHImageManager.default().requestImageData(for: asset as! PHAsset, options: nil, resultHandler: { (data, uti, orientation, dict) in
                            //
                            //print(data)
                            //print(uti)
                            //print(orientation)
                            //print(dict)
                            guard let data = data else{
                                //获取到data
                                return
                            }
                            //成功后才加入。。。待完善    请求失败时与外部的image数组不同步
                            self.imageDataArray.append(data)
                            
                            if data.count > 10 * 1024 * 1024 {
                                print("图片大于10M")
                            }
                        })
                    }
                }
                self.present(imagePickerVC!, animated: true, completion: nil)
            }else{
                
                let vc = UIImagePickerController.init()
                vc.delegate = self
                vc.sourceType = .camera
                self.present(vc, animated: true, completion: nil)
                
            }
        }
        if let address = addressLabel.text,
            let process = processLabel.text,
            let text = textView.text{
            if text.characters.count > 0 && address.characters.count > 0 && process.characters.count > 0 {
                submitButton.backgroundColor = JXOrangeColor
                submitButton.isEnabled = true
            }else{
                submitButton.backgroundColor = JXGrayColor
                submitButton.isEnabled = false
            }
        }else{
            submitButton.backgroundColor = JXGrayColor
            submitButton.isEnabled = false
        }
        
    }
}
extension DeliveredWholeRecordController {
    func locationStatus(notify:Notification) {
        //print(notify)
        if let isSuccess = notify.object as? Bool {
            if isSuccess {
                self.addressLabel.text = JXLocationManager.manager.address
            }else{
                
            }
        }
    }
}
extension DeliveredWholeRecordController :TZImagePickerControllerDelegate{
    func photo11() {
        self.textView.resignFirstResponder()
        isProcessAlert = 2
        self.jxAlertView?.actions = ["从相册中选择（最多三张）","拍照"]
        self.jxAlertView?.show()
    }
    
    func setImages(images:Array<UIImage>?)  {
        guard let array = images else {
            return
        }
        //self.imageArray += array
        
        if array.count == 3 {
            self.imageView1.image = array[0]
            self.imageView2.image = array[1]
            self.imageView3.image = array[2]
            
            self.imageView1.isUserInteractionEnabled = false
            self.imageView2.isUserInteractionEnabled = false
            self.imageView3.isUserInteractionEnabled = false
            
            self.contentView1.isHidden = false
            self.contentView2.isHidden = false
            self.contentView3.isHidden = false
            
            self.button1.isHidden = false
            self.button2.isHidden = false
            self.button3.isHidden = false
            
        }else if array.count == 2{
            self.imageView1.image = array[0]
            self.imageView2.image = array[1]
            self.imageView3.image = UIImage(named: "addPhoto")
            
            self.imageView1.isUserInteractionEnabled = false
            self.imageView2.isUserInteractionEnabled = false
            self.imageView3.isUserInteractionEnabled = true
            
            self.contentView1.isHidden = false
            self.contentView2.isHidden = false
            self.contentView3.isHidden = false
            
            self.button1.isHidden = false
            self.button2.isHidden = false
            self.button3.isHidden = true
            
        }else if array.count == 1{
            self.imageView1.image = array[0]
            self.imageView2.image = UIImage(named: "addPhoto")
            
            self.imageView1.isUserInteractionEnabled = false
            self.imageView2.isUserInteractionEnabled = true
            
            self.contentView1.isHidden = false
            self.contentView2.isHidden = false
            self.contentView3.isHidden = true
            
            self.button1.isHidden = false
            self.button2.isHidden = true
            
        }else{
            self.imageView1.image = UIImage(named: "addPhoto")
            
            self.imageView1.isUserInteractionEnabled = true
            
            
            self.contentView1.isHidden = false
            self.contentView2.isHidden = true
            self.contentView3.isHidden = true
            
            self.button1.isHidden = true
            
        }
    }
}

extension DeliveredWholeRecordController: UITextViewDelegate{

    func textViewDidChange(_ textView: UITextView) {

        if processLabel.text?.isEmpty == false && addressLabel.text?.isEmpty == false{
            submitButton.backgroundColor = JXOrangeColor
            submitButton.isEnabled = true
        }else{
            submitButton.backgroundColor = JXGrayColor
            submitButton.isEnabled = false
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if processLabel.text?.isEmpty == false && addressLabel.text?.isEmpty == false && textView.text.isEmpty == false{
            submitButton.backgroundColor = JXOrangeColor
            submitButton.isEnabled = true
        }else{
            submitButton.backgroundColor = JXGrayColor
            submitButton.isEnabled = false
        }
        
        
        if textView.text.characters.count > 100 {
            if let string = textView.text {
                textView.text = string.substring(to: string.index(string.startIndex, offsetBy: 100))
                
                ViewManager.showNotice(notice: "字符个数不能大于100")
            }
        }
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
}
extension DeliveredWholeRecordController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let newImage = UIImage.image(originalImage: image, to: kScreenWidth)
        
        if let im = newImage {
            self.imageArray.append(im)
            self.setImages(images: self.imageArray)
            
            if let data = UIImageJPEGRepresentation(im, 0.01){
                self.imageDataArray.append(data)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
