//
//  LocationUpdateController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 7/14/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import CoreLocation

class LocationUpdateController: NSObject, CLLocationManagerDelegate {

    var locations = [AnyObject]()
    var timer = NSTimer()
    @available(iOS 9.0, *)
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
//        manager.distanceFilter = 99999
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        
        return manager
    }()
    
    static func startUpdating(){
        let locationUpdateManager = LocationUpdateController()
        locationUpdateManager.timer = NSTimer.init(timeInterval: 10, target: locationUpdateManager, selector: #selector(LocationUpdateController.updateLocation(_:)), userInfo:nil, repeats: true)
        
    }
    func updateLocation(locationManager:LocationUpdateController){
        if #available(iOS 9.0, *) {
            locationManager.locationManager.startUpdatingLocation()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        if !validateUpdateLocation(){
            manager.stopUpdatingLocation()
            return
        }
        if let storedLocations = NSUserDefaults.standardUserDefaults().objectForKey("userLocations") as? [AnyObject]
        {
            locations = storedLocations
        }
        
        
        
        let newLocation = [
            "latitude":newLocation.coordinate.latitude,
            "longitude":newLocation.coordinate.longitude
        ]
        locations.append(newLocation)
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("userToken") as? String) != nil{
            NSUserDefaults.standardUserDefaults().setObject(locations, forKey: "userLocations")
            NSUserDefaults.standardUserDefaults().synchronize()
            APIClient.sendPOST(APIPath.UpdateLocation, params: newLocation)
        }
        
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    func validateUpdateLocation()-> Bool{
        var isValid = false
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH"
        let hourString = formatter.stringFromDate(NSDate())
        let hour  = Int(hourString)
        
        if hour  > 21 && hour < 5 {
            isValid = true 
        }
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("userToken") as? String) != nil{
            isValid = true
        }
        return isValid
    }
}
