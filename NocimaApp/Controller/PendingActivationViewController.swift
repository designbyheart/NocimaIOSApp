//
//  PendingActivationViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 6/23/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class PendingActivationViewController: UIViewController {
    
    @IBOutlet weak var spinner: UIImageView!
    @IBOutlet weak var facebookprofileImgView: UIImageView!
    var userImg = UIImage()
    
    @IBOutlet weak var facebookIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden=true; // for status bar hide
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.facebookIcon.layer.cornerRadius = facebookIcon.frame.size.width / 2
        self.facebookIcon.layer.masksToBounds = true
        self.facebookprofileImgView.layer.cornerRadius = facebookprofileImgView.frame.size.width/2
        self.facebookprofileImgView.layer.masksToBounds = true
        self.facebookprofileImgView.contentMode = UIViewContentMode.ScaleAspectFill
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(PendingActivationViewController.statusSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PendingActivationViewController.statusFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
        //        self.rotateView(self.spinner)
        let params: [NSObject : AnyObject] = ["redirect": false, "height": 300, "width": 300, "type": "large"]
        let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: params)
        pictureRequest.startWithCompletionHandler({
            (connection, result, error: NSError!) -> Void in
            if error == nil {
                print(result["data"]);
                if let data = result["data"]{
                    if let url = data!["url"] as? String{
                        self.downloadFbImage(NSURL.init(string: url)!, imageView: self.facebookprofileImgView)
                        self.facebookIcon.hidden = false
                        APIClient.sendPOST(APIPath.UploadFacebookImage, params: ["url":url])
                    }
                }
                
            } else {
                print("\(error)")
            }
        })
        if let myImgURL = NSUserDefaults.standardUserDefaults().objectForKey("myProfileImg") as? String {
            APIClient.load_image(myImgURL, imageView: self.facebookprofileImgView)
            facebookIcon.hidden = true
        }else{
            APIClient.sendPOST(APIPath.UserGallery, params: [:])
            self.facebookprofileImgView.image = userImg
        }
        APIClient.sendGET(APIPath.CheckUserStatus)
    }
    
    func downloadFbImage(url: NSURL, imageView:UIImageView){
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
    
    /*  let kRotationAnimationKey = "com.myapplication.rotationanimationkey" // Any key
     
     func rotateView(view: UIView, duration: Double = 1) {
     if view.layer.animationForKey(kRotationAnimationKey) == nil {
     let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
     
     rotationAnimation.fromValue = 0.0
     rotationAnimation.toValue = Float(M_PI * 2.0)
     rotationAnimation.duration = duration
     rotationAnimation.repeatCount = Float.infinity
     
     view.layer.addAnimation(rotationAnimation, forKey: kRotationAnimationKey)
     }
     }
     */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    //MARK: - API delegates
    func statusSuccess(n:NSNotification){
        var imageURL = ""
        if let response = n.object {
            if let method = response["method"] as? String {
                
                if method == APIPath.CheckUserStatus.rawValue{
                    if let response = response["response"] as? Dictionary<String, AnyObject>{
                        
                        if let userStatus = response["status"] as? Int{
                            if(userStatus == 1){
                                self.performSegueWithIdentifier("openLocationView", sender: self)
                            }
                        }}
                    return;
                }
                
                if (method != APIPath.UserGallery.rawValue) {
                    return;
                }
                
                if let response = response["response"]{
                    if let images = response!["images"] as? [AnyObject]{
                        for image in images {
                            if let position = image["position"] as? Int{
                                if position == 1 {
                                    imageURL = image["imageURL"] as! String
                                    break
                                }
                                if position == 0 {
                                    imageURL = image["imageURL"] as! String
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        if imageURL.characters.count > 0{
            APIClient.load_image(imageURL, imageView: facebookprofileImgView)
            NSUserDefaults.standardUserDefaults().setObject(imageURL, forKey: "myProfileImg")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    func statusFail(n:NSNotification){
    }
}
