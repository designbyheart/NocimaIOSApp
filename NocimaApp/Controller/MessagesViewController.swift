//
//  MessagesViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 6/4/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class MessagesViewController: MainViewController {
    @IBOutlet weak var tableView: UITableView!
    var userChats = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "HeatMap"
        self.navigationMenu.initMenuBttn()
    }
    
    //MARK: - TableView delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userChats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCellWithIdentifier("userChatCell", forIndexPath: indexPath) as! MenuCell
       
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
}
