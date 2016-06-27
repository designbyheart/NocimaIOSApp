//
//  MainViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/29/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var navigationMenu = NavigationView()
    var menu = MenuViewController()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(patternImage: UIImage.init(named:"viewBackground")!)
        //UIColor.init(colorWithPatternImage:"viewBackground")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.menu.view.center = CGPointMake(self.view.center.x * -1, self.view.center.y)
        self.view .addSubview(menu.view)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openLocationView(_:)), name: "OpenLocationView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openMyProfileView(_:)), name: "OpenMyProfileView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openSettingsView(_:)), name: "OpenSettingsView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openLoginView(_:)), name: "OpenLoginView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openLikeView(_:)), name: "OpenLikeView", object: nil)
    }
    override func viewDidAppear(animated: Bool) {
        if let menuB:UIButton = self.navigationMenu.menuBttn{
            menuB .addTarget(self, action: #selector(MainViewController.openMenu(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
//            messsageB.addTarget(self, action: #selector(MainViewController.openMessages), forControlEvents: UIControlEvents.TouchUpOutside)
        }
    }
    
    func openMenu(sender: AnyObject){
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.menu.view.center = self.view.center
            }, completion: { finished in
                self.navigationMenu.titleView.hidden = true
                if let menuB:UIButton = self.navigationMenu.menuBttn{
                    menuB.hidden = true
                }
        })
        
    }
    func openMessages(){
        self.performSegueWithIdentifier("openMessages", sender: self)
    }
    func closeMenu(){
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.menu.view.center = CGPointMake(self.view.center.x * -1, self.view.center.y)
            }, completion: { finished in
                self.navigationMenu.titleView.hidden = false
                if let menuB:UIButton = self.navigationMenu.menuBttn{
                    menuB.hidden = false
                }
        })
    }
    
    func openLocationView(n:AnyObject) {
        if let viewControllers = self.navigationController?.viewControllers{
            if let activeController = viewControllers.last {
                if !activeController.isKindOfClass(LocationViewController){
                    self.performSegueWithIdentifier("openLocationView", sender: self)
                }
            }
        }
        closeMenu()
    }
    func openLikeView(n:AnyObject) {
        if let viewControllers = self.navigationController?.viewControllers{
            if let activeController = viewControllers.last {
                if !activeController.isKindOfClass(LikeViewController){
                    self.performSegueWithIdentifier("openLikeView", sender: self)
                }
            }
        }
        closeMenu()
    }
    func openSettingsView(n:AnyObject) {
        if let viewControllers = self.navigationController?.viewControllers{
            if let activeController = viewControllers.last {
                if !activeController.isKindOfClass(SettingsViewController){
                    self.performSegueWithIdentifier("openSettingsView", sender: self)
                }
            }
        }

        closeMenu()
    }
    func openMyProfileView(n:AnyObject) {
        if let viewControllers = self.navigationController?.viewControllers{
            if let activeController = viewControllers.last {
                if !activeController.isKindOfClass(MyProfileViewController){
                    self.performSegueWithIdentifier("openMyProfileView", sender: self)
                }
            }
        }

        closeMenu()
    }
    func openLoginView(n:AnyObject){
        if let viewControllers = self.navigationController?.viewControllers{
            if let activeController = viewControllers.last {
                if !activeController.isKindOfClass(LoginViewController){
                    self.performSegueWithIdentifier("openLoginView", sender: self)
                }
            }
        }
        
        closeMenu()
        
    }
}
