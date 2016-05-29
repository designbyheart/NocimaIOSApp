//
//  MyProfileViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/29/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class MyProfileViewController: MainViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "My Profile"
        self.navigationMenu.initMenuBttn()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSUserDefaults.standardUserDefaults().setObject("MyProfileView", forKey: "ActiveView")
    }
    
    override func openLikeView(n:AnyObject) {
        super.openLikeView(n)
        self.performSegueWithIdentifier("openLikeView", sender: self)
    }
    override func openLocationView(n: AnyObject) {
        super.openLocationView(n)
        self.performSegueWithIdentifier("openSettingsView", sender: self)
    }
    override func openSettingsView(n:AnyObject) {
        super.openSettingsView(n)
        self.performSegueWithIdentifier("openSettingsView", sender: self)
    }
    
    
}
