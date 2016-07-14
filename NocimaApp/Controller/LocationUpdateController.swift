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
    @available(iOS 9.0, *)
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 99999
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        
        return manager
    }()
    
    static func startUpdating(){
        let locationUpdateManager = LocationUpdateController()
        if #available(iOS 9.0, *) {
            locationUpdateManager.locationManager.startUpdatingLocation()
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
    func validateUpdateLocation()-> Bool{
        var isValid = false
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH"
        let hour = Int(formatter.stringFromDate(NSDate()))

        if hour  > 21 && hour < 5 {
            isValid = true 
        }
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("userToken") as? String) != nil{
            isValid = true
        }
        return isValid
    }
}
