//
//  WelcomeViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 6/29/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import Alamofire

class WelcomeViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDelegate {
    
    
    @IBOutlet weak var addHorizontalContraint: NSLayoutConstraint!
    @IBOutlet weak var addVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var maleBttn: UIButton!
    @IBOutlet weak var femaleBttn: UIButton!
    @IBOutlet weak var saveBttn: UIButton!
    
    @IBOutlet weak var addBttn: UIButton!
    @IBOutlet var imageView: UIImageView!
    var profileImgView = UIImageView()
    let imagePicker = UIImagePickerController()
    var years = [Int]()
    
    @IBOutlet weak var editImg: UIImageView!
    var gender = "male"
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTxt.layer.cornerRadius = 3
        nameTxt.autocorrectionType = UITextAutocorrectionType.No
        profileImg.layer.cornerRadius = 3
        saveBttn.layer.cornerRadius = 3
        
        imagePicker.delegate = self
        
        for year in 1970...2003 {
            years.append(year)
        }
        years = years.reverse()
        self.gender = "male"
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(WelcomeViewController.updateProfileSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(WelcomeViewController.updateProfileFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
        //        pickerView.selectedRowInComponent(<#T##component: Int##Int#>)
        
    }
    
    //MARK: - UITextField Delegates
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if(nameTxt.isFirstResponder()){
            nameTxt.resignFirstResponder()
        }
        
        return true
    }
    //MARK: - Setup a gender
    
    @IBAction func updateGender(sender: AnyObject) {
        if((self.gender == "male" && sender.tag == 1)
            || (self.gender == "female" && sender.tag == 2)
            ){
            return
        }
        let isMale = sender.tag == 1 ? true : false
        
        let blueColor = UIColor(red:0.144,  green:0.562,  blue:1, alpha:1)
        //        let lightFont = UIFont.init(name: "SourceSansPro-Light", size: 18)
        //        let boldFont = UIFont.init(name: "SourceSansPro-Regular", size: 18)
        
        if isMale{
            maleBttn.setTitleColor(blueColor, forState: UIControlState.Normal)
            femaleBttn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            
            self.gender = "male"
            
        }else{
            maleBttn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            femaleBttn.setTitleColor(blueColor, forState: UIControlState.Normal)
            
            self.gender = "female"
        }
    }
    //MARK: - Image picker
    @IBAction func loadImageButtonTapped(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImg.contentMode = .ScaleAspectFill
            profileImg.image = pickedImage
            
            editImg.image = UIImage.init(named: "editIcon")
            self.addVerticalConstraint.constant = 100
            self.addHorizontalContraint.constant = 130
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: - update profile
    @IBAction func updateProfile(sender:AnyObject){
        if(self.profileImg.image == nil){
            let alert = UIAlertView.init(title: "Podsetnik", message: "Izaberite sliku za profil", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        let params = [
            "gender":self.gender,
            "firstName":self.nameTxt.text!,
            "birthYear":years[pickerView.selectedRowInComponent(0)]
        ];
        let img = self.profileImg.image
       let resizedImg = APIClient.ResizeImage(img!, targetSize: CGSizeMake(img!.size.width * 0.5, img!.size.height * 0.5))
        // example image data
        //        let image = profileImg.image   /// UIImage(named: "177143.jpg")
        let imageData = UIImageJPEGRepresentation(resizedImg, 70)
        // CREATE AND SEND REQUEST ----------
        let urlRequest = APIClient.urlRequestWithComponents("\(APIClient.apiRoot(APIPath.WelcomeData.rawValue))", parameters: params as! Dictionary<String, AnyObject>, imageData: imageData!)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON { (response) in
                if let imgURL = response.result.value!["imageURL"] as? String{
                    NSUserDefaults.standardUserDefaults().setObject(imgURL, forKey: "myProfileImg")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    APIClient.load_image(imgURL, imageView: self.profileImgView)
                }
                let alert = UIAlertView.init(title: "Success", message: "Korisnik je ažuriran", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                self.performSegueWithIdentifier("openPendingView", sender: self)
        }
    }
    func updateProfileSuccess(n:NSNotification){
        if let response = n.object {
            if let method = response["method"] as? String {
                if (method != APIPath.WelcomeData.rawValue) {
                    return;
                }
            }
            if let resp = response["response"]{
                if let success = resp!["success"] as? String{
                    let alert = UIAlertView.init(title: "Success", message: "\(success)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    self.performSegueWithIdentifier("openPendingView", sender: self)
                }else{
                    
                    let alert = UIAlertView.init(title: "Error", message: "\(resp!["error"])", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
                
            }
        }
    }
    func updateProfileFail(n:NSNotification){
        if let response = n.object {
            if let method = response["method"] as? String {
                if (method != APIPath.WelcomeData.rawValue) {
                    return;
                }
            }
        }
        let alert = UIAlertView.init(title: "Fail", message: "\(n.object)", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    //MARK: - PickerView Delegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if self.years.count > row {
            return "\(self.years[row])"
        }
        return ""
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = "\(years[row])"
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "openPendingView"){
            let pV = segue.destinationViewController as? PendingActivationViewController
            pV?.userImg = self.imageView.image!
        }
    }
}
