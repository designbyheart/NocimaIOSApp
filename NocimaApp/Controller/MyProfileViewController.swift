//
//  MyProfileViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/29/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class MyProfileViewController: MainViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDelegate {
    
    
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
        if let titleView = self.navigationMenu.titleView{
            titleView.text = "My Profile"
        }
        self.navigationMenu.initMenuBttn()
        
        let params: [NSObject : AnyObject] = ["redirect": false, "height": 800, "width": 800, "type": "large"]
        if let userDetails = NSUserDefaults.standardUserDefaults().objectForKey("userDetails"){
            
            if let firstName = userDetails["firstName"] as? String{
                self.displayNameLbl.text = firstName
            }else{
                self.displayNameLbl.text = ""
            }
            if let gender = userDetails["gender"] as? String{
                if(gender == "male"){
                    self.maleLbl.titleLabel?.font = UIFont.init(name:"SourceSansPro-Regular", size: 22)
                    self.femaleLbl.titleLabel?.font = UIFont.init(name:"SourceSansPro-Light", size: 22)
                }else{
                    self.maleLbl.titleLabel?.font = UIFont.init(name:"SourceSansPro-Light", size: 22)
                    self.femaleLbl.titleLabel?.font = UIFont.init(name:"SourceSansPro-Regular", size: 22)
                }
            }
            
            if (userDetails["facebookID"] as? String) != nil{
                let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: params)
                pictureRequest.startWithCompletionHandler({
                    (connection, result, error: NSError!) -> Void in
                    if error == nil {
                        if let data = result["data"]{
                            if let url = data!["url"] as? String{
                                NSUserDefaults.standardUserDefaults().setObject(url, forKey: "myProfileImg")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                self.downloadImage(NSURL.init(string: url)!, imageView: self.mainImageView)
                            }
                        }
                        
                    } else {
                        print("\(error)")
                    }
                })
            }
        }        
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
    
    //MARK: - upload image actions
    
    @IBAction func uploadPrimaryImg(sender: AnyObject) {
        print("primary")
    }
    @IBAction func uploadSecondaryImg(sender: AnyObject) {
        print("secondary")
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

