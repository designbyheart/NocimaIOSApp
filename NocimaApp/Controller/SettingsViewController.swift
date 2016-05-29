//
//  SettingsViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/29/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class SettingsViewController: MainViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Settings"
        self.navigationMenu.initMenuBttn()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSUserDefaults.standardUserDefaults().setObject("SettingsView", forKey: "ActiveView")
    }
    
    override func openLikeView(n:AnyObject) {
        super.openLikeView(n)
        self.performSegueWithIdentifier("openLikeView", sender: self)
    }
    override func openLocationView(n: AnyObject) {
        super.openLocationView(n)
        self.performSegueWithIdentifier("openSettingsView", sender: self)
    }
    override func openMyProfileView(n:AnyObject) {
        super.openMyProfileView(n)
        self.performSegueWithIdentifier("openMyProfileView", sender: self)
    }
}
