//
//  IdentityAuthController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/11/17.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit

class IdentityAuthController: ZPTableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var iDTextField: UITextField!
    @IBOutlet weak var aImageView: UIImageView!
    @IBOutlet weak var bImageView: UIImageView!
    
    @IBOutlet weak var yesOrNoButton: UIButton!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    var currentImageViewTag = 10
    var frontBase64Str : String?
    var backBase64Str : String?
    
    var isFrontImageSaveSussessed = false
    var isBackImageSaveSussessed = false
    
    var faceStr : String?
    var faceImageData = Data()
    
    let identifyVM = IdentifyVM()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "身份认证"
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backToMain))
       
        self.yesOrNoButton.isSelected = true
        self.yesOrNoButton.setImage(UIImage.init(named: "address_selected")?.withRenderingMode(.alwaysTemplate), for: .selected)
        self.yesOrNoButton.setImage(UIImage.init(named: "address_unselected")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.yesOrNoButton.tintColor = JXMainColor
        

        self.aImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhoto(tap:))))
        self.bImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhoto(tap:))))
        
        self.rightLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(authInfo(tap:))))
        self.submitButton.layer.cornerRadius = 5.0
        
        Data.save(data: faceImageData, name: "facePhoto")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func backToMain() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    // MARK: - Table view data source

//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return nil
//    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    //身份证扫描自动检测 无需拍照
    func selectPhoto(tap:UITapGestureRecognizer) {
        currentImageViewTag = tap.view?.tag ?? 10
        
        let cvc = CWIDCardCaptureController()
        cvc.lisenceStr = AuthCodeString
        cvc.delegate = self
        if (currentImageViewTag == 10) {
            cvc.type = .front
        }else{
            cvc.type = .back
        }
        //设置图片清晰度阈值
        cvc.cardQualityScore = 0.62
        self.present(cvc, animated: true, completion: nil)
    }
    //身份证扫描自动检测 无需拍照
    func authInfo(tap:UITapGestureRecognizer) {
        
    }
    
    @IBAction func yesOrNo(_ sender: UIButton) {
        self.yesOrNoButton.isSelected = !self.yesOrNoButton.isSelected
//        if self.yesOrNoButton.isSelected == true {
//            self.yesOrNoButton.tintColor = JXMainColor
//        }else{
//            self.yesOrNoButton.tintColor = nil
//        }
    }
    @IBAction func submitEvent(_ sender: Any) {
        
        guard let name = nameTextField.text,name.isEmpty == false else {
            ViewManager.showNotice(notice: "名字输入有误")
            return
        }
        guard let idText = iDTextField.text,idText.isEmpty == false,String.validateID(id: idText) == true else {
            ViewManager.showNotice(notice: "身份证号输入有误")
            return
        }
        guard isFrontImageSaveSussessed == true, isBackImageSaveSussessed == true else {
            ViewManager.showNotice(notice: "请上传身份证照片")
            return
        }
        if self.yesOrNoButton.isSelected == false {
            ViewManager.showNotice(notice: "需要同意征信数据采集授权")
            return
        }
        
        self.showMBProgressHUD()
        identifyVM.zpsyIdentifyInfo(param:["idCard":idText,"name":name],completion: { (data, message, isSuccess) in
            self.hideMBProgressHUD()
            
            if
                isSuccess == true,
                let dict = data as? Dictionary<String,Any>,
                let authCode = dict["authCode"] as? Int,
                let msg = dict["msg"] as? String{
                ViewManager.showNotice(notice: msg)
                
                var dict = UserManager.manager.userDict
                dict["isAuthed"] = 1
                UserManager.manager.saveAccound(dict: dict)
                
                if authCode == 1 {
                    self.navigationController?.popToRootViewController(animated: true)
                    let _ = UIImage.delete(name: "idCardFront.jpg")
                    let _ = UIImage.delete(name: "idCardBack.jpg")
                    let _ = UIImage.delete(name: "facePhoto")
                    
                }
            }else{
                ViewManager.showNotice(notice: message)
            }
        })
        
        return
//        loginVM.identifyAuth { (data, msg, isSuccess) in
//            print(data,msg,isSuccess)
//            if isSuccess {
//                loginVM.identifyFaceInfo(param:["identity_photo":identify_photo,"data":faceStr,"id_number":"130722198809123454","name":"杜进新"],completion: { (d, m, isSucc) in
//                    print(d,m,isSucc)
//                })
//            }
//        }
        
        
        
//        loginVM.identifyAuth { (data, msg, isSuccess) in
//            print(data,msg,isSuccess)
//            if isSuccess {
//                loginVM.identifyInfo(param:["img_a":identify_photo,"img_b":self.backBase64Str!],completion: { (d, m, isSucc) in
//                    print(d,m,isSucc)
//                })
//            }
//        }
        
//        loginVM.identifyAuth { (data, msg, isSuccess) in
//            print(data,msg,isSuccess)
//            if isSuccess {
//                loginVM.identifyInfo(param:["identity_photo":identify_photo,"data":faceStr,"id_number":"130722198809123454","name":"杜进新"],completion: { (d, m, isSucc) in
//                    print(d,m,isSucc)
//                })
//            }
//        }
    }
}
extension IdentityAuthController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == iDTextField {
            if range.location > 17 {
                return false
            }
        }
        return true
    }
}
extension IdentityAuthController : cwIdCardRecoDelegate{
    func cwIdCardDetectionCardImage(_ cardImage: UIImage!, imageScore score: Double) {
        //UIImageWriteToSavedPhotosAlbum(cardImage, nil, nil, nil)
        
        //let imageData = UIImageJPEGRepresentation(cardImage, 0.8)
        if currentImageViewTag == 10 {
            //frontBase64Str = imageData?.base64EncodedString(options: .endLineWithLineFeed)
            aImageView.image = nil
            aImageView.image = cardImage
            //identifyVM.frontImage = cardImage
            isFrontImageSaveSussessed = UIImage.insert(image: cardImage, name: "idCardFront.jpg")
        }else{
            //backBase64Str = imageData?.base64EncodedString(options: .endLineWithLineFeed)
            bImageView.image = nil
            bImageView.image = cardImage
            //identifyVM.backImage = cardImage
            isBackImageSaveSussessed = UIImage.insert(image: cardImage, name: "idCardBack.jpg")
        }
    }
}
