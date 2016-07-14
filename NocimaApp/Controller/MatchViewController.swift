//
//  MatchViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 6/26/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class MatchViewController: MainViewController {
    
    var matchedUserID = String()
    var matchedUserName = String()
    var matchedUserImgURL = String()
    var matchedUImg:UIImage!
    var userImage = UIImage()
    
    @IBOutlet weak var sendMessageBttn: UIButton!
    @IBOutlet weak var keepPlayingBttn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matchedUserImg.layer.cornerRadius = matchedUserImg.frame.size.width / 2
        userImg.layer.cornerRadius = userImg.frame.size.width / 2
        matchedUserImg.layer.masksToBounds = true
        userImg.layer.masksToBounds = true
        
        sendMessageBttn.layer.cornerRadius = 5
        sendMessageBttn.layer.masksToBounds = true
        keepPlayingBttn.layer.cornerRadius = 5
        keepPlayingBttn.layer.masksToBounds = true
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        APIClient.load_image(matchedUserImgURL, imageView: self.matchedUserImg)
        if self.matchedUImg != nil {
            matchedUserImg.image = self.matchedUImg
        }
        if let urlString = NSUserDefaults.standardUserDefaults().objectForKey("myProfileImg") {
            APIClient.load_image(urlString, imageView: self.userImg)
        }
        
        statusLbl.text = "Ti i \(matchedUserName.capitalizedString) se sviđate jedno drugom."
        
        
    }
    
    @IBOutlet weak var matchedUserImg: UIImageView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBAction func keepPlaying(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true) {
            
        }
    }
    @IBAction func sendMessage(sender: AnyObject) {
        self.performSegueWithIdentifier("openChatView", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "openChatView" {
            if let chatView = segue.destinationViewController as? ChatViewController{
                
                chatView.userID = matchedUserID
                chatView.userName = self.matchedUserName
                chatView.userThumbURL = matchedUserImgURL
                
            }
        }
        
    }
}
