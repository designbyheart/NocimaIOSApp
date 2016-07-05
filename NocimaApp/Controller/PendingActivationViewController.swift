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
                    }
                }
                
            } else {
                print("\(error)")
            }
        })
        self.facebookprofileImgView.image = userImg
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
}
