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
    @IBAction func loginWithFacebook(sender: AnyObject) {
        super.performSegueWithIdentifier("openLocationView", sender: self)
        return
        let loginManager = FBSDKLoginManager()
    
        loginManager.logInWithReadPermissions(self.facebookReadPermissions, fromViewController: self.parentViewController, handler: { (result, error) -> Void in
            if error != nil {
                print(FBSDKAccessToken.currentAccessToken())
            } else if result.isCancelled {
                print("Cancelled")
            } else {
//                print(result.token.tokenString)
//                print("LoggedIn")
//                self.showUserData()
//                self.openProfile()
                self.openLocation()
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
}
