//
//  LikeViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/23/16.
//  Copyright © 2016 Pedja Jevtic.azzz All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


public protocol LikeViewControllerDelegate  {
    func cardDidChangeState(cardIndex: Int)
}

class LikeViewController: MainViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet weak var loaderMap: UIImageView!
    @IBOutlet weak var commandView: UIView!
    @IBOutlet weak var heatMapBttn: UIButton!
    @IBOutlet weak var likeBttn: UIButton!
    @IBOutlet weak var loadMoreBttn: UIButton!
    
    @IBOutlet weak var collectionView:UICollectionView!
    private let reuseIdentifier = "LikeCell"
    @IBOutlet weak var noUsersLbl: UILabel!
    private var usersList = [AnyObject]()
    private var selectedUser = [String : AnyObject]()
    var progressView = RPCircularProgress()
    private var currentYear:Int = 0
    private var shouldUpdate = true
    
    @IBOutlet weak var dislikeBttn: UIButton!
    var matchedUserID = String()
    var matchedUserName = String()
    var matchedUserImgURL = String()
    var likedUsers = [AnyObject]()
    var timerCounter = 0
    var timer:NSTimer = NSTimer()
    
    /* The speed of animation. */
    private let animationSpeedDefault: Float = 0.9
    
    var layout = TisprCardStackViewLayout()
    
    internal var cardStackDelegate: TisprCardStackViewControllerDelegate? {
        didSet {
            layout.delegate = cardStackDelegate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usersList = [AnyObject]()
        
        loadMoreBttn.layer.cornerRadius = 5
        loaderMap.hidden = true
        loadMoreBttn.hidden = true
        
        collectionView .setCollectionViewLayout(layout, animated: true)
        
        self.heatMapBttn.layer.cornerRadius = self.heatMapBttn.frame.size.width / 2
        self.heatMapBttn.backgroundColor = UIColor.init(red: 17.0/255.0, green: 143.0/255.0, blue: 1, alpha: 1)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundView?.backgroundColor = UIColor.clearColor()
        collectionView.backgroundColor = UIColor.clearColor()
        //        self.commandView.hidden = true
        noUsersLbl.text = "Trenutno nema aktivnih korisnika."
        self.noUsersLbl.hidden = true
        
        setAnimationSpeed(animationSpeedDefault)
        layout.gesturesEnabled = true
        collectionView!.scrollEnabled = false
        setCardSize(CGSizeMake(self.view!.frame.size.width - 60, 2 * self.view!.frame.size.height/3 - 70))
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year], fromDate: NSDate())
        
        currentYear = components.year
        
        
        ViewHelper.addBackgroundImg(self)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Da li mi se sviđa?"
        self.navigationMenu.initMenuBttn()
        self.navigationMenu.initChatBttn()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LikeViewController.usersMatchListFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LikeViewController.usersMatchListSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LikeViewController.userMatchFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LikeViewController.userMatchSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        
        var latitude:Float = 0
        var longitude:Float = 0
        
        if let lat = NSUserDefaults.standardUserDefaults().objectForKey("latitude") as? Float{
            latitude = lat
        }
        if let long = NSUserDefaults.standardUserDefaults().objectForKey("longitude") as? Float{
            longitude = long
        }
        self.progressView = RPCircularProgress.init()
        progressView.enableIndeterminate(true)
        
        progressView.center = CGPointMake(self.view.center.x, self.collectionView.center.y)
        if(shouldUpdate){
            APIClient.sendPOST(APIPath.UsersForMatch, params: ["latitude":latitude, "longitude":longitude])
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view .addSubview(progressView)
        
        NSUserDefaults.standardUserDefaults().setObject("LikeView", forKey: "ActiveView")
        self.noUsersLbl.hidden = true
        
        if(collectionView.visibleCells().count > 0){
            progressView.removeFromSuperview()
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: - Heat map action
    @IBAction func openHeatMap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("OpenLocationView", object: nil)
    }
    //MARK: - CollectionView Delegates
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(usersList.count == likedUsers.count){
            if(usersList.count < 1){
                self.noUsersLbl.hidden = false
            }
            self.likeBttn.hidden = true
            self.dislikeBttn.hidden = true
        }else{
            self.noUsersLbl.hidden = self.usersList.count > 0 ? true : false
            self.likeBttn.hidden = self.usersList.count > 0 ? false : true
            self.dislikeBttn.hidden = self.usersList.count > 0 ? false : true
        }
        
        return self.usersList.count
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LikeDislikeCollectionViewCell
        
        // Configure the cell
        if let user = self.usersList[indexPath.row] as? [String:AnyObject]{
            if let userID = user["userID"] as? String{
                cell.userID = userID
            }
            if let city = user["city"] as? String{
                if(city != "0"){
                    cell.locationLbl.text = city
                }else{
                    cell.locationLbl.text = ""
                }
            }else{
                cell.locationLbl.text = ""
            }
            
            //            cell.age
            if let userName = user["firstName"] as? String{
                cell.nameLbl.text = userName
                if let imageURL = user["imageURL"]{
                    APIClient.load_image(imageURL, imageView: cell.userImg)
                }
                if let bYear = user["birthYear"]!.integerValue{
                    
                    if bYear > 0{
                        let age = currentYear - bYear
                        cell.nameLbl.text = "\(userName), \(age)"
                    }
                }
            }
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let user = self.usersList[indexPath.row] as? [String:AnyObject]{
            self.performSegueWithIdentifier("openUserProfile", sender: user)
        }
    }
    //method to change animation speed
    func setAnimationSpeed(speed: Float) {
        self.collectionView!.layer.speed = speed
    }
    
    //method to set size of cards
    func setCardSize(size: CGSize) {
        layout.cardSize = size
    }
    
    //method that should return count of cards
    func numberOfCards() -> Int {
        assertionFailure("Should be implemented in subsclass")
        return 0
    }
    
    //method that should return card by index
    func card(collectionView: UICollectionView, cardForItemAtIndexPath indexPath: NSIndexPath) -> LikeDislikeCollectionViewCell {
        assertionFailure("Should be implemented in subsclass")
        return LikeDislikeCollectionViewCell()
    }
    func moveCardUp() {
        //        if layout.index > 0 {
        //            self.layout.index -= 1
        //        }
    }
    
    func moveCardDown() {
        //        if self.layout.index <= numberOfCards() - 1 {
        //            self.layout.index += 1
        //        }
    }
    //MARK: - Like / Dislike action via buttons
    
    @IBAction func likeUser(sender: AnyObject) {
        
        if let user = usersList[layout.index] as? Dictionary<String, AnyObject>{
            if let userID = user["userID"] as? String{
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    // do some task
                    APIClient.sendPOST(APIPath.MatchUser, params: [
                        "status":1,
                        "userID":userID
                        ])
                    dispatch_async(dispatch_get_main_queue()) {
                        // update some UI
                    }
                }
            }
            likedUsers.append(user)
        }
        if self.layout.index == usersList.count - 1{
            //            self.noUsersLbl.hidden = false
            self.loaderMap.hidden = false
            self.loadMoreBttn.hidden = false
            self.likeBttn.hidden = true
            self.dislikeBttn.hidden =  true
            layout.index += 1
        }else if (self.layout.index < usersList.count){
            layout.index += 1
        }
    }
    @IBAction func dislikeUser(sender: AnyObject) {
        if usersList.count > layout.index {
            if let user = usersList[layout.index] as? Dictionary<String, AnyObject>{
                if let userID = user["userID"] as? String{
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        // do some task
                        APIClient.sendPOST(APIPath.MatchUser, params: [
                            "status":2,
                            "userID":userID
                            ])
                        dispatch_async(dispatch_get_main_queue()) {
                            // update some UI
                        }
                    }
                }
                
                likedUsers.append(user)
            }
        }
        if self.layout.index < usersList.count{
            if self.layout.index == usersList.count - 1{
                //                self.noUsersLbl.hidden = false
                self.loaderMap.hidden = false
                self.loadMoreBttn.hidden = false
                self.likeBttn.hidden = true
                self.dislikeBttn.hidden =  true
                layout.index += 1
            }else if (self.layout.index < usersList.count) {
                layout.index += 1
            }
        }
    }
    
    //MARK: - API Delegates
    func usersMatchListFail(n:NSNotification){
        if let data = n.object as? Dictionary<String, AnyObject>{
            
            if let method = data["method"] as? String{
                if (method != APIPath.UsersForMatch.rawValue){
                    return
                }
            }
        }
        //        print(n.object)
        //        let alert = UIAlertView.init(title: "Users match list failed", message: "\(n.object)", delegate: self, cancelButtonTitle: "OK")
        //        alert.show()
        self.progressView.removeFromSuperview()
    }
    func usersMatchListSuccess(n:NSNotification){
        if let response = n.object{
            if let method = response["method"] as? String{
                if (method != APIPath.UsersForMatch.rawValue){
                    return
                }
            }
        }
        if let response = n.object!["response"]{
            self.progressView.removeFromSuperview()
            self.layout.index = 0
            if let userList = response!["users"] as? [AnyObject]{
                self.usersList = userList
                self.noUsersLbl.hidden = usersList.count > 0 ? true : false
                self.likeBttn.hidden = self.usersList.count > 0 ? false : true
                self.dislikeBttn.hidden = self.usersList.count > 0 ? false : true
                self.loaderMap.hidden = true
                self.loadMoreBttn.hidden = true
                
                self.likedUsers.removeAll()
                self.collectionView.reloadData()
            }
        }
    }
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
    //MARK: - prepare view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if(segue.identifier! == "openUserProfile"){
            self.shouldUpdate = false
            if let userP = segue.destinationViewController as? UserProfileController {
                if let userDict = sender as? [String:AnyObject]{
                    userP.userName = userDict["firstName"] as! String
                    userP.userID = userDict["userID"] as! String
                    if let bYear = userDict["birthYear"]!.integerValue{
                        if bYear > 0{
                            let age = currentYear - bYear
                            userP.userName = "\(sender!["firstName"] as! String), \(age)"
                        }
                    }
                }
            }
            return
            
        }else if segue.identifier! == "showMatchView" {
            let matchView = segue.destinationViewController as? MatchViewController
            matchView!.matchedUserID = self.matchedUserID
            matchView!.matchedUserName = self.matchedUserName
            matchView!.matchedUserImgURL = self.matchedUserImgURL
        }
    }
    @IBAction func loadMoreusers(sender: AnyObject) {
        startTimer()
        self.loadMoreBttn.hidden = true
        
    }
    func startTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(LikeViewController.startAnimation), userInfo: nil, repeats: true)
        
    }
    func startAnimation(){
        
        if(timerCounter == 10){
            timer.invalidate()
            
            usersList.removeAll()
            
            var latitude:Float = 0
            var longitude:Float = 0
            
            if let lat = NSUserDefaults.standardUserDefaults().objectForKey("latitude") as? Float{
                latitude = lat
            }
            if let long = NSUserDefaults.standardUserDefaults().objectForKey("longitude") as? Float{
                longitude = long
            }
            self.progressView = ViewHelper.prepareProgressIndicator(self)

            APIClient.sendPOST(APIPath.UsersForMatch, params: ["latitude":latitude, "longitude":longitude])
            
            UIView.animateWithDuration(1.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                
                self.loadMoreBttn.alpha = 0
                self.loaderMap.alpha = 0
                
                }, completion:{ (finished: Bool) -> Void in
                    
                    self.loadMoreBttn.hidden = true
                    self.loaderMap.hidden = true
                    self.loadMoreBttn.alpha = 1
                    self.loaderMap.alpha = 1
                    
                    
            })
            return
            
        }
        timerCounter += 1
        let opacity:CGFloat = loaderMap.alpha == 1 ? 0.2 : 1;
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.loaderMap.alpha = opacity
            
            }, completion:{ (finished: Bool) -> Void in
                
        })
    }
    
}
