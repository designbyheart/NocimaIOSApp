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
    var progressView = RPCircularProgress()
    
    var userChats = [AnyObject]()
    var selectedUserImg:UIImage = UIImage()
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
    }
    override func viewDidAppear(animated:Bool){
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MessagesViewController.loadMessagesSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.loadMessagesFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
        self.progressView = RPCircularProgress.init()
        progressView.enableIndeterminate(true)
        self.progressView.removeFromSuperview()
        self.view .addSubview(progressView)
        progressView.center = CGPointMake(self.view.center.x, self.view.center.y)
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            APIClient.sendPOST(APIPath.ChatHistory, params: [:])
            //            dispatch_async(dispatch_get_main_queue()) {
            //                // update some UI
            //            }
        }
        
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.progressView.removeFromSuperview()
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
        if let totalNew = chatItem["totalNew"] as? Int{
            cell.notificationIcon.hidden = totalNew == 0 ? true : false
        }
        if let blockBttn = cell.blockBttn{
            blockBttn.tag = indexPath.row
        }
        //        cell.blockBttn.tag = indexPath.row
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? UserChatListCell {
            if let img = cell.userImg.image{
                self.selectedUserImg = img
            }
        }
        
        self.performSegueWithIdentifier("openChatView", sender: self.userChats[indexPath.row])
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    //MARK: - Prepare segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "openChatView"{
            if let user = sender as? [String:AnyObject]{
                if let userID = user["userID"] as? String{
                    let chatVC = segue.destinationViewController as? ChatViewController
                    chatVC!.userID = userID
                    if let imageURL = user["imageURL"] as? String{
                        chatVC!.userThumbURL = imageURL
                    }
                    chatVC!.userImg = selectedUserImg
                    
                    if let userName = user["name"] as? String{
                        chatVC!.userName = userName
                        print(userName)
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
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        // do some task
                        APIClient.sendPOST(APIPath.ChatHistory, params: [:])
                        dispatch_async(dispatch_get_main_queue()) {
                            // update some UI
                        }
                    }
                    
                    return;
                }
                if (method != APIPath.ChatHistory.rawValue) {
                    return;
                }
                self.progressView.removeFromSuperview()
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
        self.progressView.removeFromSuperview()
    }
    @IBAction func blockUser(sender: AnyObject) {
        let alert = UIAlertController(title: "Blokiraj korisnika", message: "Blokirani korisnici se neće više pojavljivati u listi", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Odustani", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
            if action.style == .Default{
                if let user = self.userChats[sender.tag] as? [String:AnyObject]{
                    
                        if let userID = user["userID"] as? String{
                            self.userChats.removeAtIndex(sender.tag)
                            self.tableView.reloadData()
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                                // do some task
                                APIClient.sendPOST(APIPath.BlockUser, params:["userID":userID])
                                dispatch_async(dispatch_get_main_queue()) {
                                    // update some UI
                        }
                    }
                }
            }
            }}))
    }
}