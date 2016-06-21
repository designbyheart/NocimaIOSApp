//
//  LoginController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/19/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import CoreLocation

class LoginViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var loginBttn: UIButton!
    let locationManager = CLLocationManager()
    var coord = CLLocationCoordinate2D()

    let facebookReadPermissions = ["public_profile", "email", "user_friends", "user_birthday", "user_photos"]
    
    override func viewDidLoad() {
        self.loginBttn.layer.cornerRadius = 5;
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil){
            self.openLocation()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LoginViewController.updateSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.updateFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        
        //        super.performSegueWithIdentifier("openLocationView", sender: self)
        //
        //        self.updateUserData()
        //        return
        
        let loginManager = FBSDKLoginManager()
        
        loginManager.logInWithReadPermissions(self.facebookReadPermissions, fromViewController: self.parentViewController, handler: { (result, error) -> Void in
            if error != nil {
                print(error)
                //                self.loginSuccess(result.token)
            } else if result.isCancelled {
                print("Cancelled")
            } else {
                print(result)
                self.loginSuccess(result.token)
            }
        })
    }
    func openLocation(){
        super.performSegueWithIdentifier("openLocationView", sender: self)
    }
    func openProfile(){
        super.performSegueWithIdentifier("openLike", sender: self)
    }
    func showUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, gender, first_name, last_name, locale, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            var userDetails  = [String: AnyObject]()
            
            userDetails["gender"] = result["gender"]
            
            userDetails["id"] = result["id"]
            userDetails["last_name"] = result["last_name"]
            userDetails["first_name"] = result["first_name"]
            userDetails["email"] = result["email"]
            userDetails["name"] = result["name"]
            userDetails["facebookID"] = result["id"]
            
            NSUserDefaults.standardUserDefaults().setObject(userDetails, forKey: "userDetails")
            NSUserDefaults.standardUserDefaults().synchronize()
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                
                if let userEmail : NSString = result.valueForKey("email") as? NSString {
                    print("User Email is: \(userEmail)")
                }
            }
        })
    }
    func loginSuccess(result:FBSDKAccessToken){
        
        
        NSUserDefaults.standardUserDefaults().setObject(result.tokenString, forKey: "facebookToken")
        //                                        print(result.token.tokenString)
        //                                        print("LoggedIn")
        //        self.showUserData()
        
        self.openProfile()
        //                        self.openLocation()
    }
    //    func updateUserData(){
    //        let params = [
    //            "firstName":"Djape",
    //            "lastName":"Jevtic",
    //            "displayName":"Pedja Jevtic",
    //            "facebookID":"123345456578878",
    //            "deviceID":"someDeviceID",
    //            "email":"designbyheart@gmail.com"
    //        ];
    //        APIClient.sendPOST(APIPath.UpdateUserData, params:params);
    //    }
    //MARK: - API notifications
    func updateSuccess(n:NSNotification){
        if let data = n.object as? Dictionary<String, AnyObject>{
            
            if let response = data["response"] as? Dictionary<String, AnyObject>{
                if let token = response["token"] as? String{
                    NSUserDefaults.standardUserDefaults().setObject(token, forKey: "userToken")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    APIClient.sendPOST(APIPath.UpdateLocation, params: [
                        "latitude":coord.latitude,
                        "longitude":coord.longitude
                        ])
                    self.openLocation()
                }
            }
        }
    }
    func updateFail(n:NSNotification){
        let alert = UIAlertView.init(title: "Failed", message: nil, delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    //MARK: - Location Delegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationArray = locations as NSArray
        if let locationObj = locationArray.lastObject as? CLLocation{
            self.coord = locationObj.coordinate
            
            print(coord.latitude)
            print(coord.longitude)
        }
        print("location \(locations)")
    }
    
}
