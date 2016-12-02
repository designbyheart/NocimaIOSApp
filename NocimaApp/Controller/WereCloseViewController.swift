//
//  WereCloseViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 10/6/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class WereCloseViewController: MainViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var infoLbl: UILabel!
    
    @IBOutlet weak var userInfoLbl: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    var selectedUser = [String:AnyObject]()
    var progressView = RPCircularProgress()
    var matchedUserID = String()
    var matchedUserImgURL = String()
    var matchedUserName = String()
    var wereStatus = false
    
    var usersList = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wereStatus = NSUserDefaults.standardUserDefaults().boolForKey("wereCloseStatus")
        self.activeSwitch.setOn(self.wereStatus, animated: true)
        
        // Do any additional setup after loading the view.
        self.infoLbl.text = "Vaša lokacija neće biti javno dostupna i koristiće se samo lokacije na kojima ste bili u poslednjih sat vremena"
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Slučajno..."
        //        self.navigationMenu.initMenuBttn()
        self.navigationMenu.initMenuBttn()
//        self.navigationMenu.initChatBttn()
        
        ViewHelper.addBackgroundImg(self)
        self.tableView.tableFooterView = UIView.init()
        
        //        let user = ["latitude": 44.803,
        //                    "longitude": 20.4845,
        //                    "userID": "wmogAQ8XqECg",
        //                    "gender": "female",
        //                    "created": "2016-10-06 23:39:03",
        //                    "firstName": "Marina",
        //                    "imageURL": "https://scontent.xx.fbcdn.net/v/t1.0-1/p720x720/13432159_1383413055009059_2606841574348438422_n.jpg?oh=ae11dfd465665105b595e6c0b5fda42f&oe=586CDEA2",
        //                    "distance": 2]
        self.userInfoLbl.text = "";
        //        self.usersList.append(user)
        self.tableView.reloadData()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WereCloseViewController.loadedUsersFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WereCloseViewController.loadedUsersSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WereCloseViewController.userMatchFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WereCloseViewController.userMatchSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WereCloseViewController.userMatched), name: "userMatched", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WereCloseViewController.userNotMatched), name: "userNotMatched", object: nil)
    
        
    }
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        
        
        
        //        if (self.selectedUser["firstName"] as? String) != nil{
        if(self.wereStatus == true){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                // do some task
                APIClient.sendPOST(APIPath.WereClose, params: [:])
                
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    self.progressView = RPCircularProgress.init()
                    self.progressView.enableIndeterminate(true)
                    self.progressView.center = self.view.center
                    self.view.addSubview(self.progressView)
                }
            }
        }
        //        }else{
        //            print("jbga")
        //        }
        
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: - loading from api
    func loadedUsersSuccess(n: NSNotification){
        if let response = n.object{
            if let method = response["method"] as? String{
                if (method != APIPath.WereClose.rawValue){
                    return
                }
            }
            if let r = response["response"] as? [String:AnyObject]{
                self.progressView.removeFromSuperview()
                if let users = r["users"] as? [AnyObject]{
                    self.usersList =  users
                    if(users.count < 1){
                        
//                        let user = ["latitude": 44.803,
//                                    "longitude": 20.4845,
//                                    "userID": "wmogAQ8XqECg",
//                                    "gender": "female",
//                                    "created": "2016-10-06 23:39:03",
//                                    "firstName": "Marina",
//                                    "imageURL": "https://scontent.xx.fbcdn.net/v/t1.0-1/p720x720/13432159_1383413055009059_2606841574348438422_n.jpg?oh=ae11dfd465665105b595e6c0b5fda42f&oe=586CDEA2",
//                                    "distance": 2]
                        self.userInfoLbl.text = "";
//                        self.usersList.append(user)
                    }
                    self.tableView.reloadData()
                    
                    if(self.usersList.count < 1){
                        self.userInfoLbl.text = "Trenutno nema korisnika \nsa kojim ste se sreli"
                    }else{
                        self.userInfoLbl.text = ""
                    }
                }
            }
        }
    }
    func loadedUsersFail(n: NSNotification){
        
    }
    //MARK: - table view delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("wereCloseCell", forIndexPath: indexPath) as? WereCloseTableViewCell {
            
            if let user = self.usersList[indexPath.row] as? [String:AnyObject]{
                
                if let userImg = user["imageURL"] as? String {
                    if userImg.characters.count > 0 {
                        APIClient.loadImgFromURL(userImg,imageView:cell.userImg)
                    }
                }
                
                cell.userNameLbl.text = user["firstName"] as? String
                if let distance = user["distance"]!.floatValue {
                    cell.distanceLbl.text = "\(distance) km daleko"
                }
            }
            return cell
        }else{
            return UITableViewCell.init()
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let user = self.usersList[indexPath.row] as? [String:AnyObject]{
            self.selectedUser = user
            self.performSegueWithIdentifier("openWereCloseDetails", sender: self)
            
            self.usersList.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
    }
    //MARK: - Feature Activation
    @IBAction func activateWereClose(sender: AnyObject) {
        if let wSwitch = sender as? UISwitch{
            let status = wSwitch.on
            NSUserDefaults.standardUserDefaults().setBool(status, forKey: "wereCloseStatus")
            NSUserDefaults.standardUserDefaults().synchronize()
            if(status == true){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    // do some task
                    APIClient.sendPOST(APIPath.WereClose, params: [:])
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        // update some UI
                        self.progressView = RPCircularProgress.init()
                        self.progressView.enableIndeterminate(true)
                        self.progressView.center = self.view.center
                        self.view.addSubview(self.progressView)
                    }
                }
            }
        }
    }
    //MARK: - Prepare for transition
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "openWereCloseDetails"){
            if let wereCloseDetails = segue.destinationViewController as? WereCloseLikeViewController{
                wereCloseDetails.selectedUser = self.selectedUser
            }
        }else if(segue.identifier == "showMatchView"){
            if let matchView = segue.destinationViewController as? MatchViewController{
                matchView.matchedUserID = self.matchedUserID
                matchView.matchedUserName = self.matchedUserName
                matchView.matchedUserImgURL = self.matchedUserImgURL
            }
        }
    }
    //MARK: - API match delegates
    func userMatchFail(n:NSNotification){
        
    }
    func userMatchSuccess(n:NSNotification){
        if let response = n.object{
            if let method = response["method"] as? String{
                if (method != APIPath.MatchUser.rawValue){
                    return
                }
            }
            if let res = response["response"]{
                if let result = res!["result"] as? Int{
                    if (result == 1){
                        self.matchedUserID = (res!["matchedUserID"] as? String)!
                        self.matchedUserName = (res!["userName"] as? String)!
                        self.matchedUserImgURL = (res!["imageURL"] as? String)!
                        if let viewControllers = self.navigationController?.viewControllers{
                            if let activeController = viewControllers.last {
                                if !activeController.isKindOfClass(MessagesViewController){
                                    self.performSegueWithIdentifier("showMatchView", sender: self)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func userMatched(){
        //should show match view
        
    }
    func userNotMatched(){
        //        if let objIndex = self.usersList.indexOf(self.selectedUser) as? Int{
        //
        //        }
    }
}
