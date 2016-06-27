//
//  MenuViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/28/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var subview: UIView!
    @IBOutlet var tableView: UITableView!
    
    let menuData = [
        ["img":"doYouLikeIcon", "title":"Da li mi se sviđa?"],
        ["img":"heatmapIcon", "title":"Gde izaći?"],
        ["img":"myProfileIcon", "title":"Moj profil"],
        ["img":"settingsIcon", "title":"Podešavanja"],
        ];
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        subview = UIView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        self.tableView = UITableView.init(frame: CGRectMake(0, self.view.frame.size.height*0.25, self.view.frame.size.width, self.view.frame.size.height*0.5))
        tableView.dataSource = self
        self.tableView.delegate = self
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerClass(MenuCell.classForCoder(), forCellReuseIdentifier: "menuCell")
        
        //Auto-set the UITableViewCells height (requires iOS8+)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        
        self.view .addSubview(self.tableView)
        
        let blurEffect = UIBlurEffect(style:UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //        blurEffectView.alpha = 0.8
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        view.insertSubview(blurEffectView, belowSubview: tableView)
        
        self.prepareLogoutBttn()
    }
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath) as! MenuCell
        cell.titleLbl.text = "aloha"
        let menuItem = menuData[indexPath.row]
        if let titleStr = menuItem["title"] as String!{
            cell.titleLbl.text = titleStr
        }
        cell.backgroundColor = UIColor.clearColor()
        cell.iconImg.image = UIImage.init(named: menuData[indexPath.row]["img"]!)
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            NSNotificationCenter.defaultCenter().postNotificationName("OpenLikeView", object: nil)
            break
        case 1:
            NSNotificationCenter.defaultCenter().postNotificationName("OpenLocationView", object: nil)
            break
        case 2:
            NSNotificationCenter.defaultCenter().postNotificationName("OpenMyProfileView", object: nil)
            break
            
        case 3:
            NSNotificationCenter.defaultCenter().postNotificationName("OpenSettingsView", object: nil)
            break
            
        default:
            break
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    //mark: - Logout function
    func prepareLogoutBttn(){
        
        let logoutBttn = UIButton.init(frame: CGRectMake(57, self.view.frame.size.height - 130, 200, 50))
        logoutBttn .setTitle("Izloguj me", forState: UIControlState.Normal)
        logoutBttn.titleLabel?.font = UIFont.init(name: "SourceSansPro-Light", size: 24)
        logoutBttn.addTarget(self, action:#selector(MenuViewController.logout(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        self.view .addSubview(logoutBttn)
        
        let logoutImg = UIImageView.init(frame: CGRectMake(logoutBttn.frame.origin.x + 8, (logoutBttn.frame.origin.y + 17), 20, 20))
        logoutImg.image = UIImage.init(named: "logoutIcon")
        logoutImg.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(logoutImg)
    }
    func logout(bttn:AnyObject){
        if (NSUserDefaults().objectForKey("facebookToken") as? String) != nil{
            NSUserDefaults.standardUserDefaults().removeObjectForKey("facebookToken")
        }
        if (NSUserDefaults().objectForKey("userToken") as? String) != nil{
            NSUserDefaults.standardUserDefaults().removeObjectForKey("userToken")
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        NSNotificationCenter.defaultCenter().postNotificationName("OpenLoginView", object: nil)
    }
}
