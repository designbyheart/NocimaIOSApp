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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openLocationView(_:)), name: "OpenLocationView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openMyProfileView(_:)), name: "OpenMyProfileView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openSettingsView(_:)), name: "OpenSettingsView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openLoginView(_:)), name: "OpenLoginView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openWereCloseView(_:)), name: "OpenWereCloseView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openLikeView(_:)),
                                                         name: "OpenLikeView", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.openMenu(_:)), name: "openMenu", object: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.menu.view.center = CGPointMake(self.view.center.x * -1, self.view.center.y)
        self.view .addSubview(menu.view)
        
        
        if let menuB:UIButton = self.navigationMenu.menuBttn{
            menuB .addTarget(self, action: #selector(MainViewController.openMenu(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
        if let messageB:UIButton = self.navigationMenu.chatBttn{
            messageB.addTarget(self, action: #selector(MainViewController.openMessages(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
//    func startBttns(){
//        if let messageB:UIButton = self.navigationMenu.chatBttn{
//            messageB.addTarget(self, action: #selector(MainViewController.openMessages(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
//        }
//    }
    
    func openMenu(sender: AnyObject){
        NSNotificationCenter.defaultCenter().postNotificationName(WereCloseLikeViewController.dismissCommandName, object: nil)
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.menu.view.center = self.view.center
            }, completion: { finished in
                self.navigationMenu.titleView.hidden = true
                if let menuB:UIButton = self.navigationMenu.menuBttn{
                    menuB.hidden = true
                }
                if let chatB:UIButton = self.navigationMenu.chatBttn{
                    chatB.hidden = true
                }
        })
        
    }
    func openMessages(sender: AnyObject){
        if let viewControllers = self.navigationController?.viewControllers{
            if let activeController = viewControllers.last {
                if !activeController.isKindOfClass(MessagesViewController){
                    self.performSegueWithIdentifier("openMessageList", sender: self)
                }
            }
        }
        closeMenu()
    }
    func closeMenu(){
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.menu.view.center = CGPointMake(self.view.center.x * -1, self.view.center.y)
            }, completion: { finished in
                self.navigationMenu.titleView.hidden = false
                if let menuB:UIButton = self.navigationMenu.menuBttn{
                    menuB.hidden = false
                }
                if let chatB:UIButton = self.navigationMenu.chatBttn{
                    chatB.hidden = false
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
                if !activeController.isKindOfClass(LikeViewController) && activeController.canPerformSegue("openLikeView"){
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
    func openWereCloseView(n:AnyObject) {
        if let viewControllers = self.navigationController?.viewControllers{
            if let activeController = viewControllers.last {
                if !activeController.isKindOfClass(WereCloseViewController){
                    self.performSegueWithIdentifier("openWereClose", sender: self)
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

extension UIViewController {
    func canPerformSegue(id: String) -> Bool {
        let segues = self.valueForKey("storyboardSegueTemplates") as? [NSObject]
        let filtered = segues?.filter({ $0.valueForKey("identifier") as? String == id })
        return (filtered?.count > 0) ?? false
    }
    
    // Just so you dont have to check all the time
    func performSegue(id: String, sender: AnyObject?) -> Bool {
        if canPerformSegue(id) {
            self.performSegueWithIdentifier(id, sender: sender)
            return true
        }
        return false
    }
}
