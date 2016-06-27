//
//  LoginController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/19/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CoreLocation

class LoginViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var loginBttn: UIButton!
    let locationManager = CLLocationManager()
    var coord = CLLocationCoordinate2D()
    var openedTimes:Int = 0
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LoginViewController.statusSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.statusFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LoginViewController.updateSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.updateFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
        self.checkUserStatus()
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        
        //        super.performSegueWithIdentifier("openLocationView", sender: self)
        //
        //        self.updateUserData()
        //        return
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        loginManager.logInWithReadPermissions(self.facebookReadPermissions, fromViewController: self.parentViewController, handler: { (result, error) -> Void in
            if error != nil {
                print(error)
                let alert = UIAlertView.init(title: "Failed Fb login", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                //                self.loginSuccess(result.token)
            } else if result.isCancelled {
                print("Cancelled")
            } else {
                let alert = UIAlertView.init(title: "Success Fb Login", message: "\(result)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                //                print(result)
                self.loginSuccess(result.token)
            }
        })
    }
    func openLocation(){
        if(openedTimes == 0){
            super.performSegueWithIdentifier("openLocationView", sender: self)
            openedTimes += 1
        }
    }
    func openProfile(){
        super.performSegueWithIdentifier("openLike", sender: self)
    }
    //MARK: - Check user status
    func checkUserStatus(){
        //1. Check if token is set
        //2. If yes, check status
        //3. If not,login
        if (NSUserDefaults.standardUserDefaults().objectForKey("userToken") as? String) != nil{
            //check user status
            if let userStatus = NSUserDefaults.standardUserDefaults().objectForKey("userStatus") as? Int {
                if userStatus == 0 {
                    APIClient.sendGET(APIPath.CheckUserStatus)
                }else{
                    self.openLocation()
                }
            }else{
                APIClient.sendGET(APIPath.CheckUserStatus)
            }
        }else{
            print("login user with facebook")
        }
        /*
         if(NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil){
         if let userStatus = NSUserDefaults.standardUserDefaults().objectForKey("userStatus") as? Int{
         if(userStatus == 1){
         self.openLocation()
         }else{
         self.performSegueWithIdentifier("showPendingActivationView", sender: self)
         }
         }else{
         APIClient.sendGET(APIPath.CheckUserStatus)
         }
         self.performSegueWithIdentifier("showPendingActivationView", sender: self)
         }
         */
    }
    func loadUserData()
    {
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    
                    print(result)
                    
                    var userDetails  = [String: AnyObject]()
                    
                    userDetails["gender"] = result["gender"]
                    userDetails["lastName"] = result.valueForKey("last_name") as! String
                    userDetails["firstName"] = result.valueForKey("first_name") as! String
                    userDetails["email"] = result.valueForKey("email") as! String
                    userDetails["displayName"] = result.valueForKey("name") as! String
                    userDetails["facebookID"] = result.valueForKey("id") as! String
                    userDetails["latitude"] = self.coord.latitude
                    userDetails["longitude"] = self.coord.longitude
                    userDetails["deviceID"] = UIDevice.currentDevice().identifierForVendor!.UUIDString
                    
                    NSUserDefaults.standardUserDefaults().setObject(userDetails, forKey: "userDetails")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    APIClient.sendPOST(APIPath.UpdateUserData, params:userDetails);
                    
                }else{
                    print("Error: \(error)")
            
                    let alert = UIAlertView.init(title: "Facebook login failed", message: "FB error: \(error)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
                
            })
        }
    }
    func loginSuccess(result:FBSDKAccessToken){
        NSUserDefaults.standardUserDefaults().setObject(result.tokenString, forKey: "facebookToken")
        
        self.loadUserData()

    }
    //MARK: - API notifications
    func updateSuccess(n:NSNotification){
        if let data = n.object as? Dictionary<String, AnyObject>{
            if let method = data["method"] as? String{
                if (method != "storeUserData"){
                    return
                }
                if let response = data["response"] as? Dictionary<String, AnyObject>{
                    if let token = response["token"] as? String{
                        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "userToken")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        APIClient.sendPOST(APIPath.UpdateLocation, params: [
                            "latitude":coord.latitude,
                            "longitude":coord.longitude
                            ])
                        
                        if let userStatus = response["status"]?.integerValue! {
                            NSUserDefaults.standardUserDefaults().setObject(userStatus, forKey: "userStatus")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            if (userStatus == 0) {
                                self.performSegueWithIdentifier("showPendingActivationView", sender: self)
                            }else{
                                self.openLocation()
                            }
                        }
                    }else{
                        let alert = UIAlertView.init(title: "Authentication Failed", message: "Error in server response", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }
            }
        }
    }
    func updateFail(n:NSNotification){
        if let response = n.object as? [String:AnyObject]{
            if let method = response["method"] as? String{
                if method == APIPath.UpdateUserData.rawValue{
                    let alert = UIAlertView.init(title: "Update user failed", message: nil, delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        }
    }
    //MARK: - Location Delegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationArray = locations as NSArray
        if let locationObj = locationArray.lastObject as? CLLocation{
            self.coord = locationObj.coordinate
        }
    }
    //MARK: - Update user status response
    func statusSuccess(n:NSNotification){
        
        if let response = n.object {
            if let method = response["method"] as? String {
                if (method != APIPath.CheckUserStatus.rawValue) {
                    return;
                }
                if let response = response["response"]{
                    if let userStatus = response!["status"] as? Int{
                        if(userStatus != 1){
                            self.performSegueWithIdentifier("showPendingActivationView", sender: self)
                        }else{
                            self.openLocation()
                        }
                    }
                }
            }
        }
    }
    func statusFail(n:NSNotification){
        
    }
}
