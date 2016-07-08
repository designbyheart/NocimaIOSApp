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
        
        self.tableView.separatorColor = UIColor.init(white: 0.3, alpha: 0.3)
        
        self.navigationController?.navigationBarHidden = true
        
        noChatLbl.text = "Trenutno nema aktivnih dopisivanja"
        noChatLbl.hidden = true
        
        self.tableView.tableFooterView = UIView()
        
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
        //
        if let userName = chatItem["name"] as? String{
            cell.userNameLbl.text = userName
        }
        cell.userImg.image = UIImage.init(named: "defaultImg")
        
        if let userImg = chatItem["imageURL"] as? String {
            if userImg.characters.count > 0 {
                cell.userImg.contentMode = UIViewContentMode.ScaleAspectFill
                APIClient.load_image(userImg, imageView: cell.userImg)
            }
        }
        if let blockBttn = cell.blockBttn{
            blockBttn.tag = indexPath.row
        }
        //        cell.blockBttn.tag = indexPath.row
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
            if let loggedUser = NSUserDefaults.standardUserDefaults().objectForKey("userID") as? String{
                if var userID = sender!["receiverID"] as? String{
                    if loggedUser == userID{
                        if let senderID = sender!["senderID"] as? String{
                            userID = senderID
                        }
                    }
                    let chatVC = segue.destinationViewController as? ChatViewController
                    chatVC!.userID = userID
                    if let imageURL = sender!["imageURL"] as? String{
                        chatVC!.userThumbURL = imageURL
                    }
                    if let userName = sender!["name"] as? String{
                        chatVC!.userName = userName
                    }
                }
            }
        }
    }
    //MARK: - Load messages delegate
    func loadMessagesSuccess(n:NSNotification){
        if let response = n.object {
            if let method = response["method"] as? String {
                if(method == APIPath.BlockUser.rawValue){
                    APIClient.sendPOST(APIPath.ChatHistory, params: [:])
                    return;
                }
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
    @IBAction func blockUser(sender: AnyObject) {
        let alert = UIAlertController(title: "Blokiraj korisnika", message: "Blokirani korisnici se neće više pojavljivati u listi", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Odustani", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
            if action.style == .Default{
                if let user = self.userChats[sender.tag] as? [String:AnyObject]{
                    if let loggedUser = NSUserDefaults.standardUserDefaults().objectForKey("userID") as? String{
                        if var userID = user["receiverID"] as? String{
                            if loggedUser == userID{
                                if let senderID = user["senderID"] as? String{
                                    userID = senderID
                                }
                            }
                            APIClient.sendPOST(APIPath.BlockUser, params:["userID":userID])
                        }
                    }
                }}
        }))
    }
}
