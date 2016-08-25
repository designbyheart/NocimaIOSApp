//
//  ChatViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 6/15/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController,UIGestureRecognizerDelegate  {
    
    var userID = ""
    var userName = ""
    var userThumbURL = ""
    var titleView = UILabel()
    var userThumb = UIImageView()
    var matchedLbl = UILabel()
    var menuBttn = UIButton()
    var userImg = UIImage()
    var timer: NSTimer!
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 42/255, green: 43/255, blue: 45/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 37/255, green: 143/255, blue: 255/255, alpha: 1.0))
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.frame = CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height - 200)
        
        collectionView.registerClass(ChatHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: "Header")
        
        self.topContentAdditionalInset = 0
        self.collectionView.scrollsToTop = true
        
        self.setup()
        //        self.addDemoMessages()
        self.collectionView.backgroundView = UIImageView.init(image: UIImage.init(named: "viewBackground"))
        self.collectionView.contentInset = UIEdgeInsetsMake(30, -20, 20, -50)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        //        matchedLbl = UILabel.init(frame: CGRectMake(20, 220, self.view.frame.width * 0.8, 20))
        //        matchedLbl.font = UIFont.init(name: "Source Sans Pro", size: 17)
        //        matchedLbl.text = "Prijate"
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userThumb.image = userImg
        
        //        print(userID)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupTitle()
        self.setupBackBttn()
        
        //        APIClient.load_image(userThumbURL, imageView: userThumb)
        self.messages .removeAll()
        self.collectionView?.reloadData()
        
        if let savedMsg = NSUserDefaults.standardUserDefaults().objectForKey("messages\(self.userID)") {
            self.prepareMessages(savedMsg as! [AnyObject])
            self.reloadMessagesView()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ChatViewController.loadedMessagesSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.loadedMessagesFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        
        self.messages.removeAll()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // do some task
        APIClient.sendPOST(APIPath.ListUserMessages, params: ["userID":self.userID])
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
            }
        }
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5 , target: self, selector: #selector(ChatViewController.loadMessages), userInfo: nil, repeats: true)
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        timer.invalidate()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func openUserProfile(){
        if let viewControllers = self.navigationController?.viewControllers{
            if let activeController = viewControllers.last {
                if !activeController.isKindOfClass(UserProfileController){
                    self.performSegueWithIdentifier("openUserProfile", sender: self)
                }
            }
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "openUserProfile"){
            if let userP = segue.destinationViewController as? UserProfileController {
                userP.userName = self.userName
                userP.userID = self.userID
            }
        }
    }
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    func setupTitle(){
        
        
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
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    //MARK - API delegates
    func loadMessages(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // do some task
            APIClient.sendPOST(APIPath.ListUserMessages, params: ["userID":self.userID])
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
            }
        }
        
    }
    
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
        self.messages.removeAll()
        for m in messageList {
            if var messageContent = m["message"] as? String{
                if let senderID = m["senderID"] as? String{
                    if self.userID != senderID{
                        self.senderId = senderID
                    }else{
                        self.senderId = m["receiverID"] as? String
                    }
                }
                let sender = m["senderID"] as? String
                
                if let base64Decoded = NSData(base64EncodedString: messageContent, options:   NSDataBase64DecodingOptions(rawValue: 0))
                    .map({ NSString(data: $0, encoding: NSUTF8StringEncoding) })
                {
                    // Convert back to a string
                    if let decoded  = base64Decoded as? String  {
                        messageContent = decoded
                        
                    }else{
                        messageContent = m["message"] as! String
                    }
                }
                
                
                let message = JSQMessage(senderId: sender, displayName:sender, text: messageContent)
                self.messages += [message]
            }
        }
        self.reloadMessagesView()
    }
}
extension String
{
    func base64Decoded() -> String {
        
        if let base64Decoded = NSData(base64EncodedString: self, options:   NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            .map({ NSString(data: $0, encoding: NSUTF8StringEncoding) })
        {
            // Convert back to a string
            if let decoded  = base64Decoded as? String  {
                return decoded
            }else{
                
            }
        }else{
//            print(self)
        }
        return self
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
    
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width, 220.0);
    }
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var headerView = UICollectionReusableView()
        
        if(indexPath.section == 0){
            switch kind {
                
            case UICollectionElementKindSectionHeader:
                
                self.titleView .removeFromSuperview()
                self.userThumb.removeFromSuperview()
                
                headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath)
                
                userThumb.frame = CGRectMake(headerView.center.x - 50, 40, 100, 100)
                userThumb.layer.cornerRadius = 15
                userThumb.contentMode = UIViewContentMode.ScaleAspectFill
                userThumb.backgroundColor = UIColor.blackColor()
                userThumb.layer.masksToBounds = true
                userThumb.userInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action:#selector(ChatViewController.openUserProfile))
                if userThumb.image == nil{
                    userThumb.image = UIImage.init(named: "defaultImg")
                }
                tap.delegate = self
                userThumb.addGestureRecognizer(tap)
                headerView.addSubview(userThumb)
                
                let titleWidth = headerView.frame.size.width * 0.8
                self.titleView = UILabel(frame: CGRectMake(self.view.frame.size.width * 0.1, 0, titleWidth, 40))
                self.titleView.textColor = UIColor.whiteColor()
                self.titleView.backgroundColor = UIColor.clearColor()
                self.titleView.textAlignment = NSTextAlignment.Center
                self.titleView.font = UIFont.init(name: "Source Sans Pro", size: 25)
                self.titleView.center = CGPointMake(headerView.center.x, 10)
                self.titleView.text = self.userName
                headerView.addSubview(self.titleView)
                
                return headerView
                
            default:
                
                assert(false, "Unexpected element kind")
                
            }
            
        }
        return headerView
    }
}

extension JSQMessagesCollectionViewCellOutgoing {
    public func messageContentSmaller() {
        self.messageBubbleContainerView?.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
    }
}
//MARK - Toolbar
extension ChatViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        var messageText:String = text
        
        let utf8str = text.dataUsingEncoding(NSUTF8StringEncoding)
        
        if let base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        {
            messageText = base64Encoded
        }
        
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.finishSendingMessage()
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // do some task
            APIClient.sendPOST(APIPath.NewMessage, params: ["userID":self.userID, "message":messageText])
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
            }
        }
        
        
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}

