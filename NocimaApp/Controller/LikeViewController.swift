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
    @IBOutlet weak var commandView: UIView!
    @IBOutlet weak var heatMapBttn: UIButton!
    @IBOutlet weak var likeBttn: UIButton!
    
    @IBOutlet weak var collectionView:UICollectionView!
    private let reuseIdentifier = "LikeCell"
    @IBOutlet weak var noUsersLbl: UILabel!
    private var usersList = [AnyObject]()
    var progressView = RPCircularProgress()
    
    @IBOutlet weak var dislikeBttn: UIButton!
    var matchedUserID = String()
    var matchedUserName = String()
    var matchedUserImgURL = String()
    var likedUsers = [AnyObject]()
    
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
        
        collectionView .setCollectionViewLayout(layout, animated: true)
        
        self.heatMapBttn.layer.cornerRadius = self.heatMapBttn.frame.size.width / 2
        collectionView.delegate = self
        collectionView.dataSource = self
        //        self.commandView.hidden = true
        noUsersLbl.text = "Trenutno nema aktivnih korisnika."
        
        setAnimationSpeed(animationSpeedDefault)
        layout.gesturesEnabled = true
        collectionView!.scrollEnabled = false
        setCardSize(CGSizeMake(collectionView!.bounds.width - 60, 2 * collectionView!.bounds.height/3))
        
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
        self.view .addSubview(progressView)
        progressView.center = CGPointMake(self.view.center.x, self.collectionView.center.y)
        APIClient.sendPOST(APIPath.UsersForMatch, params: ["latitude":latitude, "longitude":longitude])
        self.noUsersLbl.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSUserDefaults.standardUserDefaults().setObject("LikeView", forKey: "ActiveView")
    }
    
    //MARK: - Heat map action
    @IBAction func openHeatMap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("OpenLocationView", object: nil)
    }
    //MARK: - CollectionView Delegates
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(usersList.count == likedUsers.count){
            self.noUsersLbl.hidden = false
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
                cell.locationLbl.text = city
            }
            if let userName = user["firstName"] as? String{
                cell.nameLbl.text = userName
                if let imageURL = user["imageURL"]{
                    APIClient.load_image(imageURL, imageView: cell.userImg)
                }
            }
        }
        return cell
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
                APIClient.sendPOST(APIPath.MatchUser, params: [
                    "status":1,
                    "userID":userID
                    ])
            }
            likedUsers.append(user)
        }
        if self.layout.index < usersList.count{
            layout.index += 1
        }
    }
    @IBAction func dislikeUser(sender: AnyObject) {
        if usersList.count > layout.index {
        if let user = usersList[layout.index] as? Dictionary<String, AnyObject>{
            if let userID = user["userID"] as? String{
                APIClient.sendPOST(APIPath.MatchUser, params: [
                    "status":2,
                    "userID":userID
                    ])
            }
            
            likedUsers.append(user)
            }
        }
        if self.layout.index < usersList.count{
            if self.layout.index == usersList.count - 1{
                self.noUsersLbl.hidden = false
                self.likeBttn.hidden = true
                self.dislikeBttn.hidden =  true
            }
            layout.index += 1
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
            if let userList = response!["users"] as? [AnyObject]{
                self.usersList = userList
                self.noUsersLbl.hidden = usersList.count > 0 ? true : false
                self.likeBttn.hidden = self.usersList.count > 0 ? false : true
                self.dislikeBttn.hidden = self.usersList.count > 0 ? false : true
                
                self.likedUsers.removeAll()
            }
        }
        
        self.collectionView.reloadData()
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
            if segue.identifier! == "showMatchView" {
                let matchView = segue.destinationViewController as? MatchViewController
                matchView!.matchedUserID = self.matchedUserID
                matchView!.matchedUserName = self.matchedUserName
                matchView!.matchedUserImgURL = self.matchedUserImgURL
            }
        }
}
