//
//  MyProfileViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/29/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class MyProfileViewController: MainViewController {
    
    
    @IBOutlet weak var displayNameLbl: UITextField!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var fourthImageView: UIImageView!
    @IBOutlet weak var maleLbl: UIButton!
    @IBOutlet weak var femaleLbl: UIButton!
    
    //MARK: - Main functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainImageView.layer.cornerRadius = 5
        mainImageView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "My Profile"
        self.navigationMenu.initMenuBttn()
        
        let userData = NSUserDefaults.standardUserDefaults().objectForKey("userDetails")
        if let firstName = userData!["firstName"] as? String{
            self.displayNameLbl.text = firstName
        }else{
            self.displayNameLbl.text = ""
        }
        if let gender = userData!["gender"] as? String{
            if(gender == "male"){
                self.maleLbl.titleLabel?.font = UIFont.init(name:"SourceSansPro-Regular", size: 22)
                self.femaleLbl.titleLabel?.font = UIFont.init(name:"SourceSansPro-Light", size: 22)
            }else{
                self.maleLbl.titleLabel?.font = UIFont.init(name:"SourceSansPro-Light", size: 22)
                self.femaleLbl.titleLabel?.font = UIFont.init(name:"SourceSansPro-Regular", size: 22)
            }
        }
        let params: [NSObject : AnyObject] = ["redirect": false, "height": 800, "width": 800, "type": "large"]
        let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: params)
        pictureRequest.startWithCompletionHandler({
            (connection, result, error: NSError!) -> Void in
            if error == nil {
                print(result["data"]);
                if let data = result["data"]{
                    if let url = data!["url"] as? String{
                        self.downloadImage(NSURL.init(string: url)!, imageView: self.mainImageView)
                    }
                }
                
            } else {
                print("\(error)")
            }
        })
        //request(.GET, "https://robohash.org/123.png").response { (request, response, data, error) in
        //  self.myImageView.image = UIImage(data: data, scale:1)
        //        }
        
    }
    func downloadImage(url: NSURL, imageView:UIImageView){
        print("Download Started")
        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        
        APIClient.getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print(response?.suggestedFilename ?? "")
                print("Download Finished")
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}


/**
 retrieving photos from facebook
 
 
 if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_likes"]) {
 FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]
 initWithGraphPath:@"me" parameters:nil];
 FBSDKGraphRequest *requestLikes = [[FBSDKGraphRequest alloc]
 initWithGraphPath:@"me/likes" parameters:nil];
 FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
 [connection addRequest:requestMe
 completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
 //TODO: process me information
 }];
 [connection addRequest:requestLikes
 completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
 //TODO: process like information
 }];
 [connection start];
 }
 
 */
