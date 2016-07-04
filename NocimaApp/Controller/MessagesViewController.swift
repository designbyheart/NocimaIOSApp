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
    @IBOutlet weak var noChatLbl: UILabel!
    
    var userChats = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Moja dopisivanja"
//        self.navigationMenu.initMenuBttn()
        self.navigationMenu.initBackBttn()
        
        self.navigationController?.navigationBarHidden = true
        
        noChatLbl.text = "Trenutno nema aktivnih dopisivanja"
        noChatLbl.hidden = true
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MessagesViewController.loadMessagesSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.loadMessagesFail(_:)), name: APINotification.Fail.rawValue, object: nil)

        APIClient.sendPOST(APIPath.ChatHistory, params: [:])
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
        let cell = tableView.dequeueReusableCellWithIdentifier("userChatCell", forIndexPath: indexPath) as! UserChatListCell
        let chatItem = self.userChats[indexPath.row]
        
        if let userName = chatItem["name"] as? String{
            cell.userNameLbl.text = userName
        }
        if let userImg = chatItem["imageURL"] as? String{
            APIClient.load_image(userImg, imageView: cell.userImg)
        }
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("openChatView", sender: self.userChats[indexPath.row])
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    //MARK: - Prepare segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "openChatView"{
            if let userID = sender!["userID"] as? String{
                let chatVC = segue.destinationViewController as? ChatViewController
                chatVC!.userID = userID
                if let imageURL = sender!["imageURL"] as? String{
                    chatVC!.userThumbURL = imageURL
                }
                if let userName = sender!["userName"] as? String{
                    chatVC!.userName = userName
                }
            }
        }
    }
    //MARK: - Load messages delegate
    func loadMessagesSuccess(n:NSNotification){
        if let response = n.object {
            if let method = response["method"] as? String {
                if (method != APIPath.ChatHistory.rawValue) {
                    return;
                }
                if let res = response["response"]{
                    if let chatHistory = res!["chats"] as? [AnyObject]{
                        if chatHistory.count > 0{
                            userChats = chatHistory
                            self.tableView.reloadData()
                            self.noChatLbl.hidden = true
                        }else{
                            self.noChatLbl.hidden = false
                        }
                    }
                }
            }
        }
    }
    func loadMessagesFail(n:NSNotification){
        
    }
}
