//
//  UserProfile.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 7/6/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class UserProfile: MainViewController,UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userLbl: UILabel!
    var userID = String()
    var userName = String()
    var progressView = RPCircularProgress()
    var menuBttn = UIButton()
    
    
    
    override func viewDidLoad() {
        self.setupBackBttn()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userLbl.text = self.userName
        APIClient.sendPOST(APIPath.LoadImagesForUser, params: ["userID":self.userID])
        
        self.progressView = RPCircularProgress.init()
        progressView.enableIndeterminate(true)
        self.view .addSubview(progressView)
        self.progressView.center = self.view.center
    }
    //MARK: - gallery delegates
    func galleryLoadingSuccess(n:NSNotification){
        self.progressView.removeFromSuperview()
        if let data = n.object as? Dictionary<String, AnyObject>{
            if let method = data["method"] as? String{
                if (method != APIPath.LoadImagesForUser.rawValue){
                    return
                }
                if let response = data["response"] as? [String:AnyObject]{
                    if let images = response["images"] as? [AnyObject]{
                        self.loadImages(images)
                        NSUserDefaults.standardUserDefaults().setObject(images, forKey: "gallery")
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                }
            }
        }
    }
    func galleryLoadingFail(n:NSNotification){
        self.progressView.removeFromSuperview()
        if let data = n.object as? Dictionary<String, AnyObject>{
            if let method = data["method"] as? String{
                if (method != APIPath.LoadImagesForUser.rawValue){
                    return
                }
                if let response = data["response"] as? Dictionary<String, AnyObject>{
                    print(response)
                }
            }
        }
    }
    func loadImages(images:Array<AnyObject>){
        var xPos:CGFloat = 0
        for imageData in images{
            if let imageURL = imageData["imageURL"] as? String{
                
                let imageView = UIImageView.init(frame: CGRectMake(xPos, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height))
                xPos += self.scrollView.frame.size.width
                self.scrollView.addSubview(imageView)
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                APIClient.load_image(imageURL, imageView: imageView)
                /*if let position = imageData["position"] as? Int{
                    switch(position){
                    case 1:
                        NSUserDefaults.standardUserDefaults().setObject(imageURL, forKey: "myProfileImg")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        self.downloadImage(NSURL.init(string: imageURL)!, imageView: self.mainImageView)
                        break
                    case 2:
                        self.downloadImage(NSURL.init(string: imageURL)!, imageView: self.secondImageView)
                        break
                    case 3:
                        self.downloadImage(NSURL.init(string: imageURL)!, imageView: self.thirdImageView)
                        break
                    case 4:
                        self.downloadImage(NSURL.init(string: imageURL)!, imageView: self.fourthImageView)
                        break
                        
                    default:
                        self.downloadImage(NSURL.init(string: imageURL)!, imageView: self.mainImageView)
                        break;
                    }
                }*/
            }
        }
    }
    func setupBackBttn(){
        self.menuBttn = UIButton(frame:CGRectMake(5, 30, 60, 40))
        self.menuBttn.setImage(UIImage(named: "backIcon"), forState: UIControlState.Normal)
        self.menuBttn.imageEdgeInsets = UIEdgeInsetsMake(13, 20, 12, 20)
        if let messageB:UIButton = self.menuBttn{
            messageB.addTarget(self, action: #selector(ChatViewController.goBack(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
        self.view .addSubview(menuBttn)
        
    }
    @IBAction func goBack(sender:AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
}
