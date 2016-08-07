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
        manager.desiredAccuracy = kCLLocationAccuracyBest
        //        manager.distanceFilter = 99999
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startMonitoringSignificantLocationChanges()
//        manager.allowsBackgroundLocationUpdates = true
        
        return manager
    }()
    
    static func startUpdating() -> LocationUpdateController{
        let locationUpdateManager = LocationUpdateController()
        locationUpdateManager.timer = NSTimer.init(timeInterval: 10, target: locationUpdateManager, selector: #selector(LocationUpdateController.updateLocation(_:)), userInfo:nil, repeats: true)
        return locationUpdateManager
    }
    func stopUpdating(){
        if #available(iOS 9.0, *) {
            if self.locationManager != nil{
                self.locationManager.stopMonitoringSignificantLocationChanges()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    func updateLocation(locationManager:LocationUpdateController){
        if #available(iOS 9.0, *) {
            if CLLocationManager.locationServicesEnabled(){
                locationManager.locationManager.startMonitoringSignificantLocationChanges()
            }
            //startUpdatingLocation()
        } else {
            // Fallback on earlier versions
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        var allLocations = [AnyObject]()
        if !validateUpdateLocation(){
            manager.stopUpdatingLocation()
            return
        }
        if let storedLocations = NSUserDefaults.standardUserDefaults().objectForKey("userLocations") as? [AnyObject]
        {
            allLocations += storedLocations
        }
        
        
        if let newLoc = locations.first {
            let newLocation = [
                "latitude":newLoc.coordinate.latitude,
                "longitude":newLoc.coordinate.longitude
            ]
            allLocations.append(newLocation)
            
            if (NSUserDefaults.standardUserDefaults().objectForKey("userToken") as? String) != nil{
                NSUserDefaults.standardUserDefaults().setObject(locations, forKey: "userLocations")
                NSUserDefaults.standardUserDefaults().synchronize()
                APIClient.sendPOST(APIPath.UpdateLocation, params: newLocation)
            }
        }
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Location manager failed with error: %@", error)
        if error.domain == kCLErrorDomain && CLError(rawValue: error.code) == CLError.Denied {
            //user denied location services so stop updating manager
            if #available(iOS 9.0, *) {
                self.locationManager.stopUpdatingLocation()
            } else {
                // Fallback on earlier versions
            }
            //respect user privacy and remove stored location

        }
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
