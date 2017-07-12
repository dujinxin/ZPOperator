//
//  JXLocationManager.swift
//  ZPOperator
//
//  Created by 杜进新 on 2017/6/27.
//  Copyright © 2017年 dujinxin. All rights reserved.
//

import Foundation
import MapKit

class JXLocationManager :NSObject{
    
    static let manager = JXLocationManager.init()
    
    
    let locationManager : CLLocationManager!
    let geoCoder = CLGeocoder.init()
    
    
    var address : String = ""
    
    
    override init() {
       
        locationManager = CLLocationManager.init()
        
        super.init()
      
        locationManager.delegate = self
        locationManager.distanceFilter = 100
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //locationManager.requestAlwaysAuthorization()
  
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    func startUpdateLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    func stopUpdateLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension JXLocationManager: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("JXLocationManager error = \(error.localizedDescription)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: false)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("JXLocationManager auth status changed = \(status.rawValue)")
        if status == .restricted {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: false)
        }else{
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("JXLocationManager didUpdateLocations = \(locations)")
        
        if let location = locations.last {
            geoCoder.reverseGeocodeLocation(location) { (CLPlacemarks, error) in
                //
                if let error = error {
                    print("JXLocationManager reverseGeocodeLocation error = \(String(describing: error.localizedDescription))")
                }
                guard let clplacemarks = CLPlacemarks,
                      let clplacemark = clplacemarks.last ,
                      let addressDict = clplacemark.addressDictionary else{
                        
                    self.stopUpdateLocation()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: false)
                        
                    return
                }
                
                let formattedAddressLines = addressDict["FormattedAddressLines"] as? NSArray
           
                if  let city = addressDict["City"],
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
                //print("clplacemark.addressDictionary = %@", addressDict)
                //print("address = \(self.address)")
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: true)
                
                self.stopUpdateLocation()
            }
        }else{
            //只要开启定位一般不会走到这里
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationLocatedStatus), object: false)
        }
        
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("JXLocationManager pause")
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("JXLocationManager resume")
    }
}
