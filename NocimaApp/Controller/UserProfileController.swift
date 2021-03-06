//
//  UserProfile.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 7/6/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class UserProfileController:MainViewController, UIScrollViewDelegate , UIGestureRecognizerDelegate{
    
    @IBOutlet weak var userLbl: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var userID = String()
    var userName = String()
    var userBirthYear = Int()
    var progressView = RPCircularProgress()
    var menuBttn = UIButton()
    //    var imageView = UIImageView()
    @IBOutlet weak var scrollImageView: UIImageView!
    
    @IBOutlet weak var femaleLbl: UIButton!
    @IBOutlet weak var maleLbl: UIButton!
    @IBOutlet weak var mainImageView:UIImageView!
    @IBOutlet weak var secondImageView:UIImageView!
    @IBOutlet weak var thirdImageView:UIImageView!
    @IBOutlet weak var fourthImageView:UIImageView!
    
    @IBOutlet weak var displayName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Profil"
        
        self.setupBackBttn()
        mainImageView.layer.cornerRadius = 8
        secondImageView.layer.cornerRadius = 5
        thirdImageView.layer.cornerRadius = 5
        fourthImageView.layer.cornerRadius = 5
        
        displayName.textColor = UIColor.whiteColor()
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(UserProfileController.hideScroll))
        tapGesture.delegate = self
        scrollImageView.addGestureRecognizer(tapGesture)
        
        ViewHelper.addBackgroundImg(self)
        
        let info = UILabel.init(frame: CGRectMake(20, self.view.frame.size.height - 40, self.view.frame.size.width - 40, 20))
        info.text = "Tapni na sliku da zumiras"
        info.font = UIFont.init(name: "Source Sans Pro", size: 13)
        info.textColor = UIColor.init(white: 0.55, alpha: 0.8)
        info.textAlignment = NSTextAlignment.Center
        self.view.insertSubview(info, belowSubview: scrollView)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(UserProfileController.statusSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserProfileController.statusFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
        self.displayName.text = self.userName
        
        self.progressView = RPCircularProgress.init()
        progressView.enableIndeterminate(true)
        self.view .addSubview(progressView)
        self.progressView.center = self.view.center
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        APIClient.sendPOST(APIPath.LoadImagesForUser, params: ["userID":self.userID])
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        for img in images {
            if let imgPosition = img["position"] as? Int{
                if let imgURL  = img["imageURL"] as? String{
                    switch(imgPosition){
                    case 1:
                        APIClient.load_image(imgURL, imageView: self.mainImageView)
                        break;
                    case 2:
                        APIClient.load_image(imgURL, imageView: self.secondImageView)
                        break;
                    case 3:
                        APIClient.load_image(imgURL, imageView: self.thirdImageView)
                        break;
                    case 4:
                        APIClient.load_image(imgURL, imageView: self.fourthImageView)
                        break;
                    default:
                        
                        break;
                    }
                    
                }
            }
        }
        //        var xPos:CGFloat = 0
        //        for imageData in images{
        //            if let imageURL = imageData["imageURL"] as? String{
        
        //                let imageView = UIImageView.init(frame: CGRectMake(xPos, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height))
        //                xPos = xPos + self.scrollView.frame.size.width
        //                imageView.backgroundColor = UIColor.blackColor()
        //                self.scrollView.addSubview(imageView)
        //                imageView.contentMode = UIViewContentMode.ScaleAspectFit
        //                APIClient.load_image(imageURL, imageView: imageView)
        
        //                if xPos == 0{
        //                    self.imageView = imageView
        //                }
        
        //            }
        //        }
        //        self.scrollView.contentSize = CGSizeMake(xPos, self.scrollView.frame.size.height)
    }
    func setupBackBttn(){
        self.menuBttn = UIButton(frame:CGRectMake(5, 30, 60, 40))
        self.menuBttn.setImage(UIImage(named: "backIcon"), forState: UIControlState.Normal)
        self.menuBttn.imageEdgeInsets = UIEdgeInsetsMake(13, 20, 12, 20)
        if let messageB:UIButton = self.menuBttn{
            messageB.addTarget(self, action: #selector(UserProfileController.goBack(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.scrollImageView
    }
    
    @IBAction func handleTapWithSender(sender:AnyObject) {
        switch(sender.tag){
        case 1:
            self.scrollImageView.image = self.mainImageView.image
            break;
        case 2:
            self.scrollImageView.image = self.secondImageView.image
            break;
        case 3:
            self.scrollImageView.image = self.thirdImageView.image
            break;
        case 4:
            self.scrollImageView.image = self.fourthImageView.image
            break;
        default:
            
            break;
        }
        scrollImageView.contentMode = UIViewContentMode.ScaleAspectFit
        scrollView.zoomScale = 2
        scrollView.hidden = false
        
    }
    func hideScroll(){
        self.scrollView.hidden = true
    }
}
