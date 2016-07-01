//
//  WelcomeViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 6/29/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

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
        let params = [
        "gender":self.gender,
        "firstName":self.nameTxt.text!,
        "birthYear":years[pickerView.selectedRowInComponent(0)]
        ];
        APIClient.sendPOST(APIPath.WelcomeData, params: params as! Dictionary<String, AnyObject>);
    }
    func updateProfileSuccess(n:NSNotification){
        let alert = UIAlertView.init(title: "Success", message: "\(n.object)", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    func updateProfileFail(n:NSNotification){
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
}
