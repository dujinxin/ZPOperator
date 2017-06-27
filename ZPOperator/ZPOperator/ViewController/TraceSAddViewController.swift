//
//  TraceSAddViewController.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/23.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import UIKit
import MapKit

class TraceSAddViewController: UIViewController,UITextFieldDelegate{

    
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var productButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    lazy var vm = TraceSAddVM()
    
    var block : (()->())?
    
    var address : String = ""
    
    
    let locationManager = CLLocationManager.init()
    let geoCoder = CLGeocoder.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.vm.loadMainData(append: true, completion: { (data, msg, isSuccess) in
//            if isSuccess {
//                self.addressButton.setTitle(self.vm.station, for: UIControlState.normal)
//            }else{
//                print("message = \(msg)")
//            }
//        })
        
        //let locationManager = CLLocationManager.init()
        locationManager.delegate = self
        locationManager.distanceFilter = 100
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        
    }
    
    @IBAction func addressButton(_ sender: UIButton) {
    }

    @IBAction func productAction(_ sender: UIButton) {
    }
    
    @IBAction func submit(_ sender: Any) {
 
        
        let model = self.vm.dataArray[0]
        
        self.vm.submitTS(goodId:String.init(format: "%@", model.id!), completion: { (data, msg, isSuccess) in
            if isSuccess {
                print("message = \(msg)")
                if let myblock = self.block {
                    myblock()
                }
                self.navigationController?.popViewController(animated: true)
            }else{
                print("message = \(msg)")
            }
        })
    }
    
    //MARK :  UITextFieldDelegate
    
    
}


extension TraceSAddViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error = \(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("auth status changed = \(status.rawValue)")
        if status != .restricted {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations = \(locations)")
        
        
        if let location = locations.last {
            geoCoder.reverseGeocodeLocation(location) { (CLPlacemarks, error) in
                //
                if let clplacemark = CLPlacemarks?.last ,
                   let addressDict = clplacemark.addressDictionary{
                    
                    let formattedAddressLines = addressDict["FormattedAddressLines"] as? NSArray
                    
                    
                
                    if let city = addressDict["City"],
                       let subLocality = addressDict["SubLocality"]{
                        self.address = "\(city)\(subLocality)"
                        if let name = addressDict["Name"]{
                            self.address += "\(name)"
                        }else if let street = addressDict["Street"]{
                            self.address += "\(street)"
                        }
                    }else{
                        self.address = formattedAddressLines?.lastObject as! String
                    }
                    print("clplacemark.addressDictionary = %@", addressDict)
                    print("address = \(self.address)")
                    
                    self.locationManager.stopUpdatingLocation()
                }
                
            }
        }
        
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("pause")
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("resume")
    }
}

