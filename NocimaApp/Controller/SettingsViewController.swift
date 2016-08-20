//
//  SettingsViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/29/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsViewController: MainViewController {
    
    @IBOutlet weak var saveBttn: UIButton!
    @IBOutlet weak var radius: UISlider!
    @IBOutlet weak var fromSlider: UISlider!
    @IBOutlet weak var toSlider: UISlider!
    @IBOutlet weak var deleteAccountBttn: UIButton!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var toLbl: UILabel!
    @IBOutlet weak var radiusLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteAccountBttn.layer.cornerRadius = 3
        deleteAccountBttn.addTarget(self, action: #selector(SettingsViewController.deleteAccountConfirmation(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.saveBttn.layer.cornerRadius = 3
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Podešavanja"
        self.navigationMenu.initMenuBttn()
        self.navigationMenu.initChatBttn()
        
        if let rad = NSUserDefaults.standardUserDefaults().objectForKey("radius"){
            radiusLbl.text = rad as? String
            radius.value = rad.floatValue
        }
        if let from = NSUserDefaults.standardUserDefaults().objectForKey("from"){
            fromLbl.text = from as? String
            fromSlider.value = from.floatValue
        }
        if let to = NSUserDefaults.standardUserDefaults().objectForKey("to"){
            toLbl.text = to as? String
            toSlider.value = to.floatValue
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SettingsViewController.saveSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.saveFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
        print(DateHelper.calculateAge())
        
        if(DateHelper.calculateAge() > 18){
            self.fromSlider.maximumValue = 99
            self.fromSlider.minimumValue = 18
            self.toSlider.maximumValue = 99
            self.toSlider.minimumValue = 19
        }else{
            self.fromSlider.maximumValue = 18
            self.fromSlider.minimumValue = 13
            self.toSlider.maximumValue = 18
            self.toSlider.minimumValue = 14
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func fromValChanged(sender: UISlider) {
        
        fromLbl.text = NSString(format: "%.0f", sender.value) as String
        if(sender.value > toSlider.value){
            toSlider.value = sender.value + 1
            toLbl.text = NSString(format: "%.0f", toSlider.value) as String
        }
        NSUserDefaults.standardUserDefaults().setObject(fromLbl.text, forKey: "from")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    @IBAction func toValChanged(sender: UISlider) {
        toLbl.text = NSString(format: "%.0f", sender.value) as String
        if(fromSlider.value > sender.value){
            fromSlider.value = sender.value - 2
            fromLbl.text = NSString(format: "%.0f", fromSlider.value) as String
        }
        NSUserDefaults.standardUserDefaults().setObject(toLbl.text, forKey: "to")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func radiusValChanged(sender: UISlider) {
        radiusLbl.text = NSString(format: "%.0f", sender.value) as String
        NSUserDefaults.standardUserDefaults().setObject(radiusLbl.text, forKey: "radius")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    //mark: - Deleting Account
    func deleteAccountConfirmation(sender:AnyObject){
        //        let confirmView = UIAlertView.init(title: "Delete account", message: "Are you sure? ", delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "Cancel", nil)
        //        confirmView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        //        self.presentViewController(confirmView, animated: true, completion: nil)
        let alert = UIAlertController(title: "Brisanje naloga", message: "Da li ste sigurni?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            switch action.style{
            case .Default:
                print("cancel default")
                break
                
            case .Cancel:
                print("cancel cancel")
                
            case .Destructive:
                print("destructive cancel")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                self.deleteAccount()
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    func deleteAccount(){
        
        //        let loginManager = FBSDKLoginManager()
        //        loginManager.logOut()
        let facebookRequest: FBSDKGraphRequest! = FBSDKGraphRequest(graphPath: "/me/permissions", parameters: nil, HTTPMethod: "DELETE")
        
        facebookRequest.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            
            if(error == nil && result != nil){
                print("Permission successfully revoked. This app will no longer post to Facebook on your behalf.")
                print("result = \(result)")
            } else {
                if let error: NSError = error {
                    if let errorString = error.userInfo["error"] as? String {
                        print("errorString variable equals: \(errorString)")
                    }
                } else {
                    print("No value for error key")
                }
            }
        }
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("facebookToken")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userToken")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userDetails")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("latitude")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("longitude")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("clubList")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userStatus")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userID")
        
        self.performSegueWithIdentifier("openLogin", sender: self)
    }
    @IBAction func saveSettings(sender: AnyObject) {
        let params = [
            "radius":radius.value,
            "from":fromSlider.value,
            "to":toSlider.value
        ]
        APIClient.sendPOST(APIPath.UpdateSettings, params: params)
    }
    //MARK: - API notification
    func saveSuccess(n:NSNotification){
        self.openMenu(self)
    }
    func saveFail(n:NSNotification){
        
    }
    //MARK: - Open terms and privacy
    
    @IBAction func openConditions(sender: AnyObject) {
        let sender:Int = 2
        self.performSegue("openTermsView", sender: sender)
    }
    @IBAction func openPrivacy(sender: AnyObject) {
        let sender:Int = 1
        self.performSegue("openTermsView", sender: sender)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        var format = NSPropertyListFormat.XMLFormat_v1_0 //format of the property list

        let plistPath:String? = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")!
        var plistData = [String:AnyObject]()

        print(plistPath)
        
        let plistXML = NSFileManager.defaultManager().contentsAtPath(plistPath!)!

        do{
            plistData = try NSPropertyListSerialization.propertyListWithData(plistXML,
                                                                             options: .MutableContainersAndLeaves,
                                                                             format: &format)
                as! [String:AnyObject]
        }
        catch{
            print("Error reading plist: \(error), format: \(format)")
        }
//        print(plistData)
        
        if let termsVC = segue.destinationViewController as? TermsConditionsViewController{
            
            if let s = sender as? Int{
                switch(s){
                case 1:
                    termsVC.isPrivacy = true
                    termsVC.titleString = "Politika privatnosti"
                    if let content = plistData["privacy"] as? String{
                        termsVC.content = content
                    }
                    break;
                case 2:
                    termsVC.isPrivacy = false
                    termsVC.titleString = "Uslovi korišćenja"
                    if let content = plistData["conditions"] as? String{
                        termsVC.content = content
                    }
                    break;
                    
                default:
                    
                    break;
                }
            }
        }
        
    }
}
