//
//  LoginController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/19/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginController: UIViewController {
    
    @IBOutlet weak var loginBttn: UIButton!
    let facebookReadPermissions = ["public_profile", "email", "user_friends", "user_birthday", "user_photos"]
    
    override func viewDidLoad() {
        //                let fontFamilyNames = UIFont.familyNames()
        //                for familyName in fontFamilyNames {
        //                    print("------------------------------")
        //                    print("Font Family Name = [\(familyName)]")
        //                    let names = UIFont.fontNamesForFamilyName(familyName)
        //                    print("Font Names = [\(names)]")
        //                }
        self.loginBttn.layer.cornerRadius = 5;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("facebookToken") != nil){
            self.openLocation()
        }
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        
        //        super.performSegueWithIdentifier("openLocationView", sender: self)
        //
        let loginManager = FBSDKLoginManager()
        
        loginManager.logInWithReadPermissions(self.facebookReadPermissions, fromViewController: self.parentViewController, handler: { (result, error) -> Void in
            if error != nil {
//                print(FBSDKAccessToken.currentAccessToken())
                self.loginSuccess(result.token)
            } else if result.isCancelled {
                print("Cancelled")
            } else {
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
    //                                print(result.token.tokenString)
    //                                print("LoggedIn")
    self.showUserData()
    //                                self.openProfile()
    //                self.openLocation()
    }
}
