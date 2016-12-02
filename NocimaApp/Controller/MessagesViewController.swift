//
//  MessagesViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 6/4/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class MessagesViewController: MainViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noChatLbl: UILabel!
    @IBOutlet weak var matchesLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var matchedUsers = [AnyObject]()
    @IBOutlet weak var scrollView: UIScrollView!
    var progressView = RPCircularProgress()
    var scrollViewHeightConst = NSLayoutConstraint()
    
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
        ViewHelper.addBackgroundImg(self)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for c in self.scrollView.constraints {
            if (c.identifier == "scrollViewHeight"){
                self.scrollViewHeightConst = c
            }
        }
        if(self.matchedUsers.count < 1){
            scrollViewHeightConst.constant = 0
        }
        self.view.layoutIfNeeded()
        
    }
    override func viewDidAppear(animated:Bool){
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MessagesViewController.loadMessagesSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.loadMessagesFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
        if(self.userChats.count < 1){
            self.progressView = RPCircularProgress.init()
            progressView.enableIndeterminate(true)
            self.progressView.removeFromSuperview()
            self.view .addSubview(progressView)
            progressView.center = CGPointMake(self.view.center.x, self.view.center.y)
        }
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            APIClient.sendPOST(APIPath.ChatHistoryV2, params: [:])
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
    func loginUser(username: String, pass: String){
        
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
        
        //        cell.userImg.image = UIImage.init(named: "defaultImg")
        //        cell.userImg.layer.cornerRadius = cell.userImg.frame.size.width/2
        
        if let userImg = chatItem["imageURL"] as? String {
            if userImg.characters.count > 0 {
                APIClient.loadImgFromURL(userImg,imageView:cell.userImg)
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
                        APIClient.sendPOST(APIPath.ChatHistoryV2, params: [:])
                        dispatch_async(dispatch_get_main_queue()) {
                            // update some UI
                        }
                    }
                    
                    return;
                }
                if (method != APIPath.ChatHistoryV2.rawValue) {
                    return;
                }
                self.progressView.removeFromSuperview()
                if let res = response["response"]{
                    if let chatHistory = res!["coresponders"] as? [AnyObject]{
                        if chatHistory.count > 0{
                            userChats = chatHistory
                            self.tableView.reloadData()
                            self.noChatLbl.hidden = true
                        }else{
                            self.noChatLbl.hidden = false
                        }
                    }
                    if let matches = res!["matches"] as? [AnyObject]{
                        self.matchedUsers = matches
                        self.reloadMatches()
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
    func reloadMatches(){
        self.scrollViewHeightConst.constant = 100;
        self.matchesLbl.hidden = false
        self.collectionView.reloadData()
        
        //TODO update scroll view and restore matches 
//        var leftPadding:CGFloat = 10
//        for user in self.matchedUsers {
//            let uButton = UIButton.init(frame:CGRectMake(leftPadding, 10, 60, 60))
//            if let userImg = user["imageURL"] as? String {
//                if userImg.characters.count > 0 {
//                    APIClient.loadImgFromURL(userImg,imageView:uButton.imageView)
//                }
//            }
//            uButton.setImage(UIIMage, forState: <#T##UIControlState#>)
//            if let uName = user["name"] as? String{
////                let nameLbl = UILabel.
//            }
//        }
    }
    //MARK: - Collection view delegates
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.matchedUsers.count
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
     let cell = collectionView.dequeueReusableCellWithReuseIdentifier("matchUserCell", forIndexPath: indexPath) as! MatchedCollectionViewCell
        
        if let user = self.matchedUsers[indexPath.row] as? [String: AnyObject]{
            if let imgURL = user["imageURL"] as? String{
                APIClient.load_image(imgURL, imageView: cell.userImage)
            }
            cell.userNameLbl.text = user["name"] as? String
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MatchedCollectionViewCell {
            if let img = cell.userImage.image{
                self.selectedUserImg = img
            }
        }
        
        self.performSegueWithIdentifier("openChatView", sender: self.matchedUsers[indexPath.row])

    }
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSizeMake(100, 100)
    }
}
