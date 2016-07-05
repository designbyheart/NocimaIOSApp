//
//  ChatViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 6/15/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController  {
    
    var userID = String()
    var userName = String()
    var userThumbURL = String()
    var titleView = UILabel()
    var userThumb = UIImageView()
    var matchedLbl = UILabel()
    var menuBttn = UIButton()
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 42/255, green: 43/255, blue: 45/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 37/255, green: 143/255, blue: 255/255, alpha: 1.0))
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupTitle()
        self.setupBackBttn()
        self.collectionView.frame = CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height - 180)
        
        
        self.setup()
        //        self.addDemoMessages()
        self.collectionView.backgroundView = UIImageView.init(image: UIImage.init(named: "viewBackground"))
        self.collectionView.contentInset = UIEdgeInsetsMake(240, -20, 20, -20)
        
        userThumb = UIImageView.init(frame: CGRectMake(0, 0, 80, 80))
        userThumb.center = CGPointMake(self.view.frame.size.width / 2 + 50, 120)
        userThumb.layer.cornerRadius = 15
        userThumb.layer.masksToBounds = true
        self.view .addSubview(userThumb)
        
        //        matchedLbl = UILabel.init(frame: CGRectMake(20, 220, self.view.frame.width * 0.8, 20))
        //        matchedLbl.font = UIFont.init(name: "Source Sans Pro", size: 17)
        //        matchedLbl.text = "Prijate"
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.titleView.text = self.userName
        APIClient.load_image(userThumbURL, imageView: userThumb)
        
        if let savedMsg = NSUserDefaults.standardUserDefaults().objectForKey("messages\(self.userID)") {
            self.prepareMessages(savedMsg as! [AnyObject])
            self.reloadMessagesView()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ChatViewController.loadedMessagesSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.loadedMessagesFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
        
        APIClient.sendPOST(APIPath.ListUserMessages, params: ["userID":userID])
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    func setupTitle(){
        let titleWidth = self.view.frame.size.width * 0.8
        self.titleView = UILabel(frame: CGRectMake((self.view.frame.size.width-titleWidth)/2 + 50, 30, titleWidth, 40))
        self.titleView.textColor = UIColor.whiteColor()
        self.titleView.textAlignment = NSTextAlignment.Center
        self.titleView.font = UIFont.init(name: "Source Sans Pro", size: 25)
        self.view.addSubview(self.titleView)
        
    }
    func setupBackBttn(){
        self.menuBttn = UIButton(frame:CGRectMake(5, 30, 60, 40))
        self.menuBttn.setImage(UIImage(named: "backIcon"), forState: UIControlState.Normal)
        self.menuBttn.imageEdgeInsets = UIEdgeInsetsMake(13, 20, 12, 20)
        if let messageB:UIButton = self.menuBttn{
            messageB.addTarget(self, action: #selector(ChatViewController.goBack(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
        self.view .addSubview(menuBttn)
        
    }
    @IBAction func goBack(sender:AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    //MARK - API delegates
    func loadedMessagesSuccess(n:NSNotification){
        if let data = n.object as? Dictionary<String, AnyObject>{
            if let method = data["method"] as? String{
                if (method != APIPath.ListUserMessages.rawValue){
                    return
                }
                if let response = data["response"] as? [String:AnyObject]{
                    if let msg = response["messages"] as? [AnyObject]{
                        //                        NSUserDefaults.standardUserDefaults().setObject(msg, forKey: "messages\(self.userID)")
                        //                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.prepareMessages(msg)
                    }
                }
            }
        }
    }
    func loadedMessagesFail(n:NSNotification){
        
    }
    func prepareMessages(messageList:[AnyObject]){
        for m in messageList {
            if let senderID = m["senderID"] as? String{
                if self.userID != senderID{
                    self.senderId = senderID
                }else{
                    self.senderId = m["receiverID"] as? String
                }
            }
            let sender = m["senderID"] as? String
            let messageContent = m["message"] as? String
            let message = JSQMessage(senderId: sender, displayName:sender, text: messageContent)
            self.messages += [message]
        }
        self.reloadMessagesView()
    }
}

//MARK - Setup
extension ChatViewController {
    //    func addDemoMessages() {
    //        for i in 1...10 {
    //            let sender = (i%2 == 0) ? "Server" : self.senderId
    //            let messageContent = "Message nr. \(i)"
    //            let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
    //            self.messages += [message]
    //        }
    //        self.reloadMessagesView()
    //    }
    func setup() {
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
    }
}

extension ChatViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        
            if data.senderId == self.userID{
                return self.incomingBubble
            }else{
                return self.outgoingBubble
            }
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}
//extension JSQMessagesCollectionViewCellOutgoing {
//    public func messageContentSmaller() {
//        self.messageBubbleContainerView?.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
//        
//    }
//}
//MARK - Toolbar
extension ChatViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.finishSendingMessage()
        
        APIClient.sendPOST(APIPath.NewMessage, params: ["userID":self.userID, "message":text])
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}