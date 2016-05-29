//
//  MenuViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/28/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var subview: UIView!
    @IBOutlet var tableView: UITableView!
    
    let menuData = [
        ["img":"someImg", "title":"Do you like?"],
        ["img":"someImg", "title":"HeatMap"],
        ["img":"someImg", "title":"My Profile"],
        ["img":"someImg", "title":"Settings"],
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
        self.tableView.estimatedRowHeight = 60
        
        self.view .addSubview(self.tableView)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //        blurEffectView.alpha = 0.8
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        view.insertSubview(blurEffectView, belowSubview: tableView)
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
            return 60.0
        }
}
