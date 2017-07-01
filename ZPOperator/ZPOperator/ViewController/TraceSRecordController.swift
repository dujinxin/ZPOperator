//
//  TraceSRecordController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/27.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import TZImagePickerController
import MBProgressHUD

class TraceSRecordController: ZPTableViewController {

    
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var operatorLabel: UILabel!
    @IBOutlet weak var processLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var placeHolderLabel: UILabel!

    @IBOutlet weak var textView: UITextView!
    
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
    
    
    var traceSource : TraceSourceDetailSubModel?
    var processId : NSNumber?
    var addressStr : String?
    var isProcessAlert : Int = 0
    
    var block : (()->())?
    var isAdd = true
    
    var traceRecordId : NSNumber?//溯源详情来源需要用
    
    
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
        

        productLabel.text = self.traceSource?.traceBatchName
        operatorLabel.text = "操作人：" + LoginVM.loginVMManager.userModel.userName!
        
        submitButton.layer.cornerRadius = 5
        submitButton.backgroundColor = UIColor.gray
        submitButton.isEnabled = false
        
        setImages(images: self.imageArray)
        
        
        imageView1.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(photo11)))
        imageView2.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(photo11)))
        imageView3.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(photo11)))
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationStatus(notify:)), name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: nil)
        //开启定位
        JXLocationManager.manager.startUpdateLocation()
        
        //一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用一百个字高度测试所用
        
        
        
        if isAdd == false { //修改
            self.vm.fetchTraceSourceRecord(id: self.traceRecordId!, goodsId: (self.traceSource?.goodsId)!, completion: { (data, msg, isSuccess) in
                
                if isSuccess{
                    //格式化数组
                    //self.addressArray.append(self.vm.traceSourceModify.stationLocation!)
                    for model in self.vm.traceSourceProgress.traceProcesses{
                        if model.id == self.vm.traceSourceModify.traceProcessRecord?.traceProcessId {
                            self.processLabel.text = model.name
                        }
                        self.processArray.append(model.name!)
                    }
                    
                    self.processId = self.vm.traceSourceModify.traceProcessRecord?.traceProcessId
                    
                    self.addressLabel.text = self.vm.traceSourceModify.traceProcessRecord?.location
                    self.textView.text = self.vm.traceSourceModify.traceProcessRecord?.contents
                    self.placeHolderLabel.isHidden = true
                }
            })
        }else{  //添加
            if let goodsId = traceSource?.goodsId,
                let traceBatchId = traceSource?.traceBatchId{//详情来源
                self.vm.loadProgress(goodsId: goodsId, traceBatchId: traceBatchId) { (data, msg, isSuccess) in
                    if isSuccess{
                        //格式化数组
                        //self.addressArray.append(self.vm.traceSourceProgress.stationLocation!)
                        for model in self.vm.traceSourceProgress.traceProcesses{
                            self.processArray.append(model.name!)
                        }
                    }
                }
                
            }else{//全程溯源
                if let batchId = batchId {
                    self.vm.fetchTraceSourceWholeRecord(batchId: batchId, completion: { (data, msg, isSuccess) in
                        if isSuccess{
                            //格式化数组
                            //self.addressArray.append(self.vm.traceSourceModify.stationLocation!)
                            for model in self.vm.traceSourceWholeModify.traceProcesses{
                                self.processArray.append(model.name!)
                            }
                            self.placeHolderLabel.isHidden = false
                            self.productLabel.text = self.vm.traceSourceWholeModify.traceSourceWholeProduct.goodsName
                        }
                    })
                }
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
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        if self.imageDataArray.count != 0 {
            self.uploadManager.qiniuUpload(datas: self.imageDataArray) { (array) in
                print("imageArrayUrl = \(array)")
                
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
        
        if let batchId = batchId {//全程 deliveredWholeUpdateRecord
            let id : NSNumber?
            
            if isAdd == false {
                id = batchId
            }else{
                id = nil
            }
            self.vm.updateTraceSourceWholeRecord(id: id, traceTemplateBatchId: (self.vm.traceSourceWholeModify.traceSourceWholeProduct.id)!, traceProcessId: self.processId!, location: (self.addressLabel.text)!, file: file, contents: self.textView.text) { (data, msg, isSuccess) in
                if isSuccess{
                    if let myblock = self.block {
                        myblock()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else{
                    ViewManager.showNotice(notice: msg)
                }
            }
        }else {
            let id : NSNumber?
            let successStr : String
            
            if isAdd == false {
                id = self.traceRecordId
                successStr = "修改成功"
            }else{
                id = nil
                successStr = "添加成功"
            }
            
            self.vm.updateTraceSourceRecord(id: id, traceTemplateBatchId: (self.traceSource?.traceBatchId)!, traceProcessId: self.processId!, location: (self.addressLabel.text)!, file: file?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed), contents: self.textView.text) { (data, msg, isSuccess) in
                MBProgressHUD.hide(for: self.view, animated: true)
                if isSuccess{
                    ViewManager.showNotice(notice: successStr)
                    if let myblock = self.block {
                        myblock()
                    }
                    self.navigationController?.popViewController(animated: true)
                }else{
                    ViewManager.showNotice(notice: msg)
                }
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
                if isAdd == false {
                    self.addressArray.append(self.vm.traceSourceModify.stationLocation!)
                }else {
                    if let station = self.vm.traceSourceWholeModify.Operator.station {//全程
                        self.addressArray.append(station)
                    }else{//详情
                        self.addressArray.append(self.vm.traceSourceProgress.stationLocation!)
                    }
                    
                }
                self.jxAlertView?.actions = addressArray
                self.jxAlertView?.show()
                
            }else{
                
            }
        }
    }
}
extension TraceSRecordController : JXAlertViewDelegate{
    func jxAlertView(_ alertView: JXAlertView, clickButtonAtIndex index: Int) {
        if isProcessAlert == 0{
            if let batchId = batchId {
                self.processLabel.text = self.vm.traceSourceWholeModify.traceProcesses[index].name
                self.processId = self.vm.traceSourceWholeModify.traceProcesses[index].id
            }else{
                self.processLabel.text = self.vm.traceSourceProgress.traceProcesses[index].name
                self.processId = self.vm.traceSourceProgress.traceProcesses[index].id
            }
        }else if isProcessAlert == 1{
            self.addressLabel.text = self.addressArray[index]
        }else{
            if index == 0 {
                let imagePickerVC = TZImagePickerController.init(maxImagesCount: 3 - self.imageArray.count, delegate: self)
                imagePickerVC?.allowTakePicture = false
                
                imagePickerVC?.allowPickingImage = true
                imagePickerVC?.allowPickingOriginalPhoto = true
                
                imagePickerVC?.sortAscendingByModificationDate = true
                
                imagePickerVC?.didFinishPickingPhotosHandle = { (images, assets, isSelectOriginalPhoto) -> () in
                    
                    print("images = \(images)")
                    print("assets = \(assets)")
                    if let images = images {
                        self.imageArray += images
                        self.setImages(images: self.imageArray)
                    }
                    
                    
                    
                    
                    for asset in assets! {
                        //PHImageManager.default().requestImage(for: <#T##PHAsset#>, targetSize: <#T##CGSize#>, contentMode: <#T##PHImageContentMode#>, options: <#T##PHImageRequestOptions?#>, resultHandler: <#T##(UIImage?, [AnyHashable : Any]?) -> Void#>)
                        //PHImageManager.default().requestImageData(for: <#T##PHAsset#>, options: <#T##PHImageRequestOptions?#>, resultHandler: <#T##(Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Void#>)
                        PHImageManager.default().requestImageData(for: asset as! PHAsset, options: nil, resultHandler: { (data, uti, orientation, dict) in
                            //
                            print(data)
                            print(uti)
                            print(orientation)
                            print(dict)
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
                submitButton.backgroundColor = UIColor.originColor
                submitButton.isEnabled = true
            }else{
                submitButton.backgroundColor = UIColor.gray
                submitButton.isEnabled = false
            }
        }else{
            submitButton.backgroundColor = UIColor.gray
            submitButton.isEnabled = false
        }
        
    }
}
extension TraceSRecordController {
    func locationStatus(notify:Notification) {
        print(notify)
        
//        if let isSuccess = notify.object as? Bool,
//            isSuccess == true{
//            self.addressArray.append(JXLocationManager.manager.address)
//        }
//        if isAdd == false {
//            self.vm.fetchTraceSourceRecord(id: self.traceRecordId!, goodsId: (self.traceSource?.goodsId)!, completion: { (data, msg, isSuccess) in
//                
//                if isSuccess{
//                    //格式化数组
//                    self.addressArray.append(self.vm.traceSourceModify.stationLocation!)
//                    for model in self.vm.traceSourceProgress.traceProcesses{
//                        if model.id == self.vm.traceSourceModify.traceProcessRecord?.traceProcessId {
//                            self.processLabel.text = model.name
//                        }
//                        self.processArray.append(model.name!)
//                    }
//                    
//                    self.processId = self.vm.traceSourceModify.traceProcessRecord?.traceProcessId
//                    
//                    self.addressLabel.text = self.vm.traceSourceModify.traceProcessRecord?.location
//                    self.textView.text = self.vm.traceSourceModify.traceProcessRecord?.contents
//                    self.placeHolderLabel.isHidden = true
//                }
//            })
//        }else{
//            if let goodsId = traceSource?.goodsId,
//                let traceBatchId = traceSource?.traceBatchId{
//                self.vm.loadProgress(goodsId: goodsId, traceBatchId: traceBatchId) { (data, msg, isSuccess) in
//                    if isSuccess{
//                        //格式化数组
//                        self.addressArray.append(self.vm.traceSourceModify.stationLocation!)
//                        for model in self.vm.traceSourceProgress.traceProcesses{
//                            self.processArray.append(model.name!)
//                        }
//                    }
//                }
//            
//            }
//        }
    }
}
extension TraceSRecordController :TZImagePickerControllerDelegate{
    func photo11() {
        
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

extension TraceSRecordController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.placeHolderLabel.isHidden = true
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView.text.characters.count > 0 {
            placeHolderLabel.isHidden = true
            submitButton.backgroundColor = UIColor.originColor
            submitButton.isEnabled = true
        }else{
            placeHolderLabel.isEnabled = false
            
            submitButton.backgroundColor = UIColor.gray
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
    
//    
//    func textChange(notify:NSNotification) {
//        
//        if notify.object is UITextField {
//            if oldTextField.text?.characters.count != 0 && newTextField.text?.characters.count != 0 && againTextField.text?.characters.count != 0 {
//                confirmButton.backgroundColor = UIColor.originColor
//                confirmButton.isEnabled = true
//            }else{
//                confirmButton.backgroundColor = UIColor.gray
//                confirmButton.isEnabled = false
//            }
//        }
//    }
}
extension TraceSRecordController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let newImage = UIImage.image(originalImage: image, to: UIScreen.main.bounds.width)
        
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
