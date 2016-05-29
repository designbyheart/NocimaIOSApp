//
//  LikeViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/23/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class LikeViewController: MainViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Do you like?"
        self.navigationMenu.initMenuBttn()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSUserDefaults.standardUserDefaults().setObject("LikeView", forKey: "ActiveView")
    }
    
    override func openLocationView(n: AnyObject) {
        super.openLocationView(n)
        self.performSegueWithIdentifier("openSettingsView", sender: self)
    }
    override func openSettingsView(n:AnyObject) {
        super.openSettingsView(n)
        self.performSegueWithIdentifier("openSettingsView", sender: self)
    }
    override func openMyProfileView(n:AnyObject) {
        super.openMyProfileView(n)
        self.performSegueWithIdentifier("openMyProfileView", sender: self)
    }
}
