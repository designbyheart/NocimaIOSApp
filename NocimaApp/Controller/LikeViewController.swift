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
    
    @IBOutlet weak var dislikeBttn: UIButton!
    var matchedUserID = String()
    var matchedUserName = String()
    var matchedUserImgURL = String()
    
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
        setCardSize(CGSizeMake(collectionView!.bounds.width - 60, 2*collectionView!.bounds.height/3))
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Da li mi se sviđa?"
        self.navigationMenu.initMenuBttn()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LikeViewController.usersMatchListFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LikeViewController.usersMatchListSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LikeViewController.userMatchFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LikeViewController.userMatchSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
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
        self.noUsersLbl.hidden = self.usersList.count > 0 ? true : false
        self.likeBttn.hidden = self.usersList.count > 0 ? false : true
        self.dislikeBttn.hidden = self.usersList.count > 0 ? false : true
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
        if self.layout.index < usersList.count{
            layout.index += 1
        }
        if self.layout.index < usersList.count{
            layout.index += 1
        }
        print(usersList[layout.index])
        if let user = usersList[layout.index] as? Dictionary<String, AnyObject>{
            if let userID = user["userID"] as? String{
                APIClient.sendPOST(APIPath.MatchUser, params: [
                    "status":1,
                    "userID":userID
                    ])
            }
        }
        print("like me \(layout.index)")
    }
    @IBAction func dislikeUser(sender: AnyObject) {
//        APIClient.sendPOST(APIPath.MatchUser, params: [
//            "status":status,
//            "userID":c.userID!
//            ])
        print("dislike me \(layout.index)")
    }
    
    //MARK: - API Delegates
    func usersMatchListFail(n:NSNotification){
        let alert = UIAlertView.init(title: "Users match list failed", message: nil, delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    func usersMatchListSuccess(n:NSNotification){
        if let response = n.object!["response"]{
            if let userList = response!["users"] as? [AnyObject]{
                self.usersList = userList
                self.noUsersLbl.hidden = self.usersList.count > 0 ? true : false
                self.likeBttn.hidden = self.usersList.count > 0 ? false : true
                self.dislikeBttn.hidden = self.usersList.count > 0 ? false : true
                
                //                let alert = UIAlertView.init(title: "Total", message: "\(self.usersList.count) users", delegate: self, cancelButtonTitle: "OK")
                //                alert.show()
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
                        self.performSegueWithIdentifier("showMatchView", sender: self)
                    }
                }
            }
        }
    }
    //MARK: - prepare view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "showMatchView" {
            let matchView = segue.destinationViewController as? MatchViewController
            matchView!.matchedUserID = self.matchedUserID
            matchView!.matchedUserName = self.matchedUserName
            matchView!.matchedUserImgURL = self.matchedUserImgURL
        }
    }
}
