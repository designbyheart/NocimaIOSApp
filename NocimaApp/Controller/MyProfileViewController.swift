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
    let imagePicker = UIImagePickerController()
    
    var imgIndex = 0
    
    //MARK: - Main functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainImageView.layer.cornerRadius = 5
        mainImageView.layer.masksToBounds = true
        imagePicker.delegate = self
        
        
        self.secondImageView.layer.cornerRadius = 3
        self.thirdImageView.layer.cornerRadius = 3
        self.fourthImageView.layer.cornerRadius = 3
        self.mainImageView.layer.cornerRadius = 3
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        if let titleView = self.navigationMenu.titleView{
            titleView.text = "My Profile"
        }
        self.navigationMenu.initMenuBttn()
        self.navigationMenu.initChatBttn()
        
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
            
            //        let params: [NSObject : AnyObject] = ["redirect": false, "height": 800, "width": 800, "type": "large"]
//            if (userDetails["facebookID"] as? String) != nil{
//                let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: params)
//                pictureRequest.startWithCompletionHandler({
//                    (connection, result, error: NSError!) -> Void in
//                    if error == nil {
//                        if let data = result["data"]{
//                            if let url = data!["url"] as? String{
//                                NSUserDefaults.standardUserDefaults().setObject(url, forKey: "myProfileImg")
//                                NSUserDefaults.standardUserDefaults().synchronize()
//                                self.downloadImage(NSURL.init(string: url)!, imageView: self.mainImageView)
//                            }
//                        }
//                        
//                    } else {
//                        print("\(error)")
//                    }
//                })
//            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MyProfileViewController.galleryLoadingSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyProfileViewController.galleryLoadingFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
        APIClient.sendPOST(APIPath.UserGallery, params:["test":1]);
        
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
        self.imgIndex = 1
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
           presentViewController(imagePicker, animated: true, completion: nil)
    }
    @IBAction func uploadSecondaryImg(sender: AnyObject) {
        self.imgIndex = sender.tag
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
           presentViewController(imagePicker, animated: true, completion: nil)
    }

    //MARK: - Image picker delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            var img = UIImageView()
            switch self.imgIndex {
            case 1:
                img = self.mainImageView
                break
                
            case 2:
                img = self.secondImageView
                break
                
            case 3:
                img = self.thirdImageView
                break
                
            case 4:
                img = self.fourthImageView
                break
            default:
                break
            }
            img.contentMode = .ScaleAspectFill
            img.image = pickedImage
            
//            image.image = UIImage.init(named: "editIcon")
//            self.addVerticalConstraint.constant = 100
//            self.addHorizontalContraint.constant = 130
        }
        dismissViewControllerAnimated(true, completion: nil)
        
        
        //start uploading image
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: - gallery delegates
    func galleryLoadingSuccess(n:NSNotification){
        if let data = n.object as? Dictionary<String, AnyObject>{
            if let method = data["method"] as? String{
                if (method != APIPath.UserGallery.rawValue){
                    return
                }
                if let response = data["response"] as? Dictionary<String, AnyObject>{
                    print(response)
                }
            }
        }
    }
    func galleryLoadingFail(n:NSNotification){
        if let data = n.object as? Dictionary<String, AnyObject>{
            if let method = data["method"] as? String{
                if (method != APIPath.UserGallery.rawValue){
                    return
                }
                if let response = data["response"] as? Dictionary<String, AnyObject>{
                    print(response)
                }
            }
        }
    }
}

