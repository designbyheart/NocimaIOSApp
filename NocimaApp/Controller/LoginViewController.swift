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

enum SubmitType:Int {
    case None
    case Login
    case Register
    case Reset
    
    
}
class LoginViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var splashScreen: UIImageView!
    @IBOutlet weak var loginBttn: UIButton!
    @IBOutlet weak var resetBttn: UIButton!
    @IBOutlet weak var subTitle: UILabel!
    let locationManager = CLLocationManager()
    var coord = CLLocationCoordinate2D()
    var openedTimes:Int = 0
    var loginView = UIView()
    let facebookReadPermissions = ["public_profile", "email","user_birthday"]
    //, "user_friends", "user_birthday", "user_photos"]
    @IBOutlet weak var infoIcon: UIImageView!
    @IBOutlet weak var gbIcon: UIImageView!
    var userNameTxt = UITextField()
    var passwordTxt = UITextField()
    
    @IBOutlet weak var privacyLbl: UILabel!
    @IBOutlet weak var topContraint: NSLayoutConstraint!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    //MARK - View methods
    override func viewDidLoad() {
        self.loginBttn.layer.cornerRadius = 5;
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        loginBtn.layer.cornerRadius = 5
        registerBtn.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LoginViewController.statusSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.statusFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LoginViewController.updateSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.updateFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
        self.checkUserStatus()
        if NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil{
            if(coord.latitude != 0 && coord.longitude != 0){
                APIClient.sendPOST(APIPath.UpdateLocation, params: [
                    "latitude":coord.latitude,
                    "longitude":coord.longitude
                    ])
            }
        }
        //        self.openWelcomeScreen()
        self.splashScreen.hidden = true
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
                //                print(error)
                let alert = UIAlertView.init(title: "Failed Fb login", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                //                self.loginSuccess(result.token)
            } else if result.isCancelled {
                //                print("Cancelled")
            } else {
                self.loginSuccess(result.token)
            }
        })
    }
    func openLocation(){
        if(openedTimes == 0){
            print("deviceID \(UIDevice.currentDevice().identifierForVendor?.UUIDString)")
            super.performSegueWithIdentifier("openLocationView", sender: self)
            if let pushToken = NSUserDefaults.standardUserDefaults().objectForKey("pushNotificationToken"){
                APIClient.sendPOST(APIPath.UploadPushToken, params: ["token":pushToken, "deviceID":(UIDevice.currentDevice().identifierForVendor?.UUIDString)!])
            }
            
            
            openedTimes += 1
        }
    }
    func openWelcomeScreen(){
        if let viewControllers = self.navigationController?.viewControllers{
            if let activeController = viewControllers.last {
                if !activeController.isKindOfClass(WelcomeViewController){
                    self.performSegueWithIdentifier("openWelcomeView", sender: self)
                }
            }
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
            //            print("login user with facebook")
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
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, gender,birthday"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    
                    //                    print(result)
                    
                    var userDetails  = [String: AnyObject]()
                    
                    userDetails["gender"] = result["gender"] as! String
                    userDetails["lastName"] = result.valueForKey("last_name") as! String
                    userDetails["firstName"] = result.valueForKey("first_name") as! String
                    if let email = result.valueForKey("email") as? String {
                        userDetails["email"] = email
                    }
                    userDetails["displayName"] = result.valueForKey("name") as! String
                    userDetails["facebookID"] = result.valueForKey("id") as! String
                    userDetails["status"] = 1
                    if let birthday = result.valueForKey("birthday") as? String{
                        userDetails["birthday"] = birthday
                    }
                    if CLLocationManager.locationServicesEnabled() {
                        userDetails["latitude"] = self.coord.latitude
                        userDetails["longitude"] = self.coord.longitude
                    }
                    if let identifierForVendor =  UIDevice.currentDevice().identifierForVendor{
                        userDetails["deviceID"] = identifierForVendor.UUIDString
                    }
                    
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
                if (method != APIPath.UpdateUserData.rawValue &&
                    method != APIPath.Register.rawValue &&
                    method != APIPath.Login.rawValue){
                    return
                }
                if let response = data["response"] as? Dictionary<String, AnyObject>{
                    print(response)
                    if let userID = response["userID"] as? String{
                        NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "userID")
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    if let token = response["token"] as? String{
                        if(token.characters.count > 10){
                            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "userToken")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            if(coord.latitude == 0 && coord.longitude == 0){
                                APIClient.sendPOST(APIPath.UpdateLocation, params: [
                                    "latitude":coord.latitude,
                                    "longitude":coord.longitude
                                    ])
                            }
                        }
                        if let userStatus = response["status"] as? Int {
                            NSUserDefaults.standardUserDefaults().setObject(userStatus, forKey: "userStatus")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            if (userStatus == 0) {
                                if (method == APIPath.Register.rawValue){
                                    self.openWelcomeScreen()
                                    return
                                }
                                self.performSegueWithIdentifier("showPendingActivationView", sender: self)
                            }else{
                                self.openLocation()
                            }
                        }else{
                            //consider status = 0
                            if let userDetails = NSUserDefaults.standardUserDefaults().objectForKey("userDetails"){
                                if (userDetails["facebookID"] as? String) != nil{
                                    self.openLocation()
                                    return
                                }else{
                                    self.openWelcomeScreen()
                                    return
                                }
                            }
                            self.openWelcomeScreen()
                            return
                        }
                    }else{
                        if method == APIPath.CheckUserStatus.rawValue {
                            let alert = UIAlertView.init(title: "Authentication Failed", message: "Error in server response", delegate: self, cancelButtonTitle: "OK")
                            alert.show()
                        }
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
            NSUserDefaults.standardUserDefaults().setObject(self.coord.latitude, forKey: "latitude")
            NSUserDefaults.standardUserDefaults().setObject(self.coord.longitude, forKey: "longitude")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    //MARK: - Update user status response
    func statusSuccess(n:NSNotification){
        
        if let response = n.object {
            if let method = response["method"] as? String {
                if (method != APIPath.CheckUserStatus.rawValue &&
                    method != APIPath.Login.rawValue &&
                    method != APIPath.Register.rawValue) {
                    return;
                }
                if let response = response["response"]{
                    if(method == APIPath.Login.rawValue || method == APIPath.Register.rawValue){
                        if let token = response!["token"] as? String{
                            if(token.characters.count > 10){
                                NSUserDefaults.standardUserDefaults().setObject(token, forKey: "userToken")
                                NSUserDefaults.standardUserDefaults().synchronize()
                            }
                        }
                        if(coord.latitude != 0 && coord.longitude != 0){
                            APIClient.sendPOST(APIPath.UpdateLocation, params: [
                                "latitude":coord.latitude,
                                "longitude":coord.longitude
                                ])
                        }
                        if let error = response!["error"] as? String {
                            let alert = UIAlertView.init(title: "Login", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                            alert.show()
                            return;
                        }else{
                            self.updateSuccess(n)
                        }
                        
                    }
                    
                    if(method == APIPath.CheckUserStatus.rawValue){
                        UserEntity.updateUserDetails(response! as! Dictionary<String, AnyObject>)
                        if let userStatus = response!["status"] as? Int{
                            if(userStatus != 1){
                                if let userID = response!["userID"] as? String{
                                    print(userID)
                                    self.performSegueWithIdentifier("showPendingActivationView", sender: self)
                                }
                            }else{
                                self.openLocation()
                            }
                        }}
                }
            }
        }
    }
    func statusFail(n:NSNotification){
        
    }
    //MARK: - user authentication
    @IBAction func regularLogin(sender: AnyObject) {
        self.showView("Uloguj se", type: SubmitType.Login)
    }
    @IBAction func regularRegister(sender: AnyObject) {
        self.showView("Registruj se", type: SubmitType.Register)
    }
    func showView(viewTitleStr:String, type:SubmitType){
//        registerBtn.hidden = true
//        loginBtn.hidden = true
        //        loginBttn.hidden = true
//        privacyLbl.hidden = true
//        infoIcon.hidden = true
//        resetBttn.hidden = true
        //        gbIcon.hidden = true
        self.removeVisibleView(1)
        
        if self.loginView.tag == 0{
            self.loginView.removeFromSuperview()
            self.loginView = UIView.init(frame: CGRectMake(40, self.view.frame.size.height + 20, self.view.frame.size.width - 80, 340))
            self.loginView.tag = type.rawValue
            
            var startPointY:CGFloat = 15
            let width = self.loginView.frame.size.width - 60
            
            self.loginView.backgroundColor = UIColor.clearColor()
            self.loginView.layer.cornerRadius = 5
            
            let viewTitle = UILabel.init(frame: CGRectMake(20, startPointY, width + 20, 30))
            viewTitle.text = viewTitleStr
            viewTitle.font = UIFont.init(name: "SourceSansPro-Light", size: 22)
            viewTitle.textAlignment = NSTextAlignment.Center
            viewTitle.textColor = UIColor.whiteColor()
            self.loginView.addSubview(viewTitle)
            
            startPointY += 45
            let usernameTxt = UITextField.init(frame: CGRectMake(30, startPointY, width, 44))
            startPointY += 64
            usernameTxt.backgroundColor = UIColor.whiteColor()
            usernameTxt.textAlignment = NSTextAlignment.Center
            usernameTxt.font = UIFont.init(name: "SourceSansPro-Regular", size: 17)
            usernameTxt.placeholder = "Unesi email adresu"
            usernameTxt.layer.cornerRadius = 3
            usernameTxt.delegate = self
            usernameTxt.autocapitalizationType = UITextAutocapitalizationType.None
            usernameTxt.autocorrectionType = UITextAutocorrectionType.No
            usernameTxt.keyboardType = UIKeyboardType.EmailAddress
            usernameTxt.tag = type.rawValue
            self.userNameTxt = usernameTxt
            self.loginView.addSubview(usernameTxt)
            
            if(type != SubmitType.Reset){
                
                let passTxt = UITextField.init(frame: CGRectMake(30, startPointY, width, 44))
                startPointY += 74
                passTxt.backgroundColor = UIColor.whiteColor()
                passTxt.textAlignment = NSTextAlignment.Center
                passTxt.font = UIFont.init(name: "SourceSansPro-Regular", size: 17)
                passTxt.placeholder = "Unesi lozinku"
                passTxt.layer.cornerRadius = 3
                passTxt.delegate = self
                passTxt.tag = type.rawValue
                passTxt.secureTextEntry = true
                self.passwordTxt = passTxt
                self.loginView.addSubview(passTxt)
                
            }
            self.view.addSubview(self.loginView)
            
            let submitBttn = UIButton.init(frame: CGRectMake(30, startPointY, width, 44))
            submitBttn.setTitle("Pošalji", forState: UIControlState.Normal)
            submitBttn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            submitBttn.titleLabel?.font = UIFont.init(name: "SourceSansPro-Regular", size: 18)
            submitBttn.layer.cornerRadius = 3
            submitBttn.tag = type.rawValue
            submitBttn.addTarget(self, action: #selector(LoginViewController.submitForm(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            submitBttn.backgroundColor = UIColor.jsq_messageBubbleBlueColor()
            //UIColor.init(red: 255.0/27.0, green: 255.0/143.0, blue: 255.0/255.0, alpha: 1)
            self.loginView.addSubview(submitBttn)
            startPointY += 65
            
            let cancelBttn = UIButton.init(frame: CGRectMake(30, startPointY, width, 44))
            cancelBttn.setTitle("Odustani", forState: UIControlState.Normal)
            cancelBttn.titleLabel?.font = UIFont.init(name: "SourceSansPro-Light", size: 16)
            cancelBttn.addTarget(self, action: #selector(LoginViewController.cancelAllViews(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.loginView.addSubview(cancelBttn)
            
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            self.loginView.center = CGPointMake(self.view.center.x, self.view.frame.size.height - 220)
            
            }, completion: { (finished: Bool) -> Void in
                //                self.removeVisibleView(2)
        })
        
    }
    @IBAction func cancelAllViews(sender: AnyObject){
        if(userNameTxt.isFirstResponder()){
            userNameTxt.resignFirstResponder()
        }
        if(passwordTxt.isFirstResponder()){
            passwordTxt.resignFirstResponder()
        }
        self.removeVisibleView(1)
        self.removeVisibleView(2)
    }
    func removeVisibleView(targetView: Int){
        if(self.loginView.tag > 0){
//            registerBtn.hidden = false
//            loginBtn.hidden = false
            //            loginBttn.hidden = false
            //            privacyLbl.hidden = false
            //            infoIcon.hidden = false
            //            gbIcon.hidden = false
//            resetBttn.hidden = false
            
            self.loginView.removeFromSuperview()
            self.loginView.tag = 0
        }
    }
    @IBAction func submitForm(sender:UIButton){
        if(sender.tag != SubmitType.Reset.rawValue){
            if(userNameTxt.text?.characters.count < 1 || passwordTxt.text?.characters.count < 1){
                return;
            }
        }else{
            if(userNameTxt.text?.characters.count < 1){
                return;
            }
        }
        var params:Dictionary<String,AnyObject> = [
            "email":userNameTxt.text!
        ];
        if sender.tag != SubmitType.Reset.rawValue{
            params["password"] = passwordTxt.text!
        }
        
        if(sender.tag == SubmitType.Login.rawValue){
            APIClient.sendPOST(APIPath.Login, params: params)
        }else if(sender.tag == SubmitType.Register.rawValue){
            APIClient.sendPOST(APIPath.Register, params:params)
        }else if(sender.tag == SubmitType.Reset.rawValue){
            APIClient.sendPOST(APIPath.ResetPass, params:params)
        }else{
    
        }
        
    }
    //MARK: - text fields delegates
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    //MARK: - keyboard delegates
    
    func keyboardWillShow(notification: NSNotification) {
        self.subTitle.hidden = true
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.loginView.center = CGPointMake(self.view.center.x, self.view.frame.size.height - 220 - contentInsets.bottom + 70)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.topContraint.constant = 60
                
                }, completion: { (finished: Bool) -> Void in
                    
            })
            
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        self.subTitle.hidden = false
        self.loginView.center = CGPointMake(self.view.center.x, self.view.frame.size.height - 220)
        UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.topContraint.constant = 140
            }, completion: { (finished: Bool) -> Void in
                
        })
    }
    //MARK: - reset pass
    
    @IBAction func resetPassword(sender: AnyObject) {
        self.showView("Resetuj lozinku", type: SubmitType.Reset)
    }
    
}
