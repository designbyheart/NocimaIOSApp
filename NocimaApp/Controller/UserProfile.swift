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
    var imageView = UIImageView()
    
    
    
    override func viewDidLoad() {
        self.setupBackBttn()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        
        self.scrollView.delegate = self
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(UserProfile.statusSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserProfile.statusFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
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
                xPos = xPos + self.scrollView.frame.size.width
//                imageView.backgroundColor = UIColor.blackColor()
                self.scrollView.addSubview(imageView)
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                APIClient.load_image(imageURL, imageView: imageView)
                
                if xPos == 0{
                    self.imageView = imageView
                }
                
            }
        }
        self.scrollView.contentSize = CGSizeMake(xPos, self.scrollView.frame.size.height)
    }
    func setupBackBttn(){
        self.menuBttn = UIButton(frame:CGRectMake(5, 30, 60, 40))
        self.menuBttn.setImage(UIImage(named: "backIcon"), forState: UIControlState.Normal)
        self.menuBttn.imageEdgeInsets = UIEdgeInsetsMake(13, 20, 12, 20)
        if let messageB:UIButton = self.menuBttn{
            messageB.addTarget(self, action: #selector(UserProfile.goBack(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
        self.view .addSubview(menuBttn)
        
    }
    @IBAction func goBack(sender:AnyObject){
                
        self.dismissViewControllerAnimated(true, completion: { 
            
        });
    }
    //MARK: - API delegates
    func statusSuccess(n:NSNotification){
        if let response = n.object {
            if let method = response["method"] as? String {
                
                
                if (method != APIPath.LoadImagesForUser.rawValue) {
                    return;
                }
                
                if let response = response["response"]{
                    if let images = response!["images"] as? [AnyObject]{
                        self.loadImages(images)
                        self.progressView.removeFromSuperview()
                    }
                    
                }
            }
        }
    }
    func statusFail(n:NSNotification){
        self.progressView.removeFromSuperview()
    }
//    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return self.imageView
//    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        
    }
}