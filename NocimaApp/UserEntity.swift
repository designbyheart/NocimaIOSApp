//
//  UserEntity.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 7/2/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class UserEntity: NSObject {
    
    static func updateUserDetails(userData:Dictionary<String, AnyObject>){
        var updatedUserDetails = [String:AnyObject]()
        print(userData)
        
        updatedUserDetails["firstName"] = userData["firstName"] as? String
        updatedUserDetails["email"] = userData["email"] as? String
        updatedUserDetails["birthday"] = userData["birthYear"] as? Int
        updatedUserDetails["gender"] = userData["gender"] as? String
        updatedUserDetails["status"] = userData["status"] as? Int
        NSUserDefaults.standardUserDefaults().setObject(updatedUserDetails, forKey: "userDetails")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
}
