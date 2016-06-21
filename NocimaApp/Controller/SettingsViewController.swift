//
//  SettingsViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/29/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class SettingsViewController: MainViewController {
    
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
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Settings"
        self.navigationMenu.initMenuBttn()
        
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
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        
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
        NSUserDefaults.standardUserDefaults().removeObjectForKey("facebookToken")
        self.performSegueWithIdentifier("openLogin", sender: self)
    }
}
