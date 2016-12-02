//
//  WereCloseLikeViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 10/12/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class WereCloseLikeViewController: MainViewController,MGLMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    static let dismissCommandName = "dismissWereCloseLikeView"
    var markerImage = UIImage.init(named: "closeLocation.png")
    @IBOutlet var mapView:MGLMapView!
    let styleURL = NSURL(string: "mapbox://styles/dbyh/cip0hdumy0003dlnq2eqkvo9i")
    
    var selectedUser = [String:AnyObject]()
    var matchedUserID:String = ""
    var matchedUserName:String = ""
    var matchedUserImgURL:String = ""
    
    @IBOutlet weak var mapWrapper: UIView!
    @IBOutlet weak var yesBttn: UIButton!
    @IBOutlet weak var dontLikeBttn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Slučajno..."
        //        self.navigationMenu.initMenuBttn()
        self.navigationMenu.initBackBttn()
        ViewHelper.addBackgroundImg(self)
        self.dontLikeBttn.addTarget(self, action: #selector(WereCloseLikeViewController.dislikeUser(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WereCloseLikeViewController.userMatchFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WereCloseLikeViewController.userMatchSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WereCloseLikeViewController.closePopup), name: WereCloseLikeViewController.dismissCommandName, object: nil)
        
        
        self.userImg.layer.shadowRadius = 10
        self.userImg.layer.masksToBounds = true
        
        if let firstName = self.selectedUser["firstName"] as? String{
            self.userNameLbl.text = firstName
        }
        if let city = self.selectedUser["city"] as? String{
            self.cityLbl.text = city
        }else{
            self.cityLbl.text = ""
        }
        
        let tapGesture = UITapGestureRecognizer.init(target: self.userImg, action: #selector(WereCloseLikeViewController.openGallery(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.userImg.addGestureRecognizer(tapGesture)
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        if let userImg = selectedUser["imageURL"] as? String {
            if userImg.characters.count > 0 {
                APIClient.loadImgFromURL(userImg,imageView:self.userImg)
            }
        }
        
        
        
        //        self.mapView.showsUserLocation = true
        self.mapView = MGLMapView.init(frame:self.mapWrapper.bounds, styleURL:styleURL)
        mapView.delegate = self
        self.mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        var lat:Double = 0
        if let latitude = selectedUser["latitude"]!.doubleValue{
            lat = latitude
        }
        var longi:Double = 0
        if let longitude = selectedUser["longitude"]!.doubleValue{
            longi = longitude
        }
        let location = CLLocationCoordinate2DMake(lat, longi)
        
        self.mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: location.latitude,
            longitude:location.longitude),zoomLevel: 14, animated: true)
        
        self.mapView.showsUserLocation = true
        // set the map's center coordinate
        // Initialize and add the point annotation.
        let pisa = MGLPointAnnotation()
        pisa.coordinate = CLLocationCoordinate2DMake(location.latitude,location.longitude)
        mapView.addAnnotation(pisa)
        
        self.mapWrapper.insertSubview(mapView, atIndex: 0)
        
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: location.latitude,
            longitude:location.longitude),
                                    zoomLevel: 14, animated: false)
        //        self.view.
        //        addSubview(mapView)
        
        
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists.
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("pisa")
        
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
            var image = self.markerImage!
            
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height.
            //
            // To make this padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
            image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, 0, 0))
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "pisa")
        }
        
        return annotationImage
    }
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    func closePopup(){
        self.mapView.removeFromSuperview()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.dismissViewControllerAnimated(false) {
            NSNotificationCenter.defaultCenter().postNotificationName("openMenu", object: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if(segue.identifier == "openUserProfile"){
            if let userProfileView = segue.destinationViewController as? UserProfileController{
                userProfileView.userID = self.selectedUser["userID"]! as! String
                userProfileView.userName = self.selectedUser["firstName"] as! String
              /*  if let bYear = selectedUser["birthYear"]!.integerValue{
                    if bYear > 0{

                        let calendar = NSCalendar.currentCalendar()
                        let components = calendar.components([.Year], fromDate: NSDate())
                        let currentYear = components.year
                        let age = currentYear - bYear
                        if(age > 0){
                            userProfileView.userName = "\(selectedUser["firstName"] as! String), \(age)"
                        }
                    }
                }*/

            }
        }
     }
    //MARK: - Like / Dislike action via buttons
    
    @IBAction func likeUser(sender: AnyObject) {
        
        if let userID = selectedUser["userID"] as? String{
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
        self.dismissViewControllerAnimated(false) {
        }
    }
    @IBAction func dislikeUser(sender: AnyObject) {
        
        if let userID = selectedUser["userID"] as? String{
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
        self.dismissViewControllerAnimated(false) {
        }
        
    }
    //MARK: - API match delegates
    func userMatchFail(n:NSNotification){
        NSNotificationCenter.defaultCenter().postNotificationName("notMatchedUser", object: selectedUser)
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
            NSNotificationCenter.defaultCenter().postNotificationName("matchedUser", object: selectedUser)
        }
    }
    @IBAction func openGallery(sender: AnyObject) {
        self.performSegueWithIdentifier("openUserProfile", sender: self)
    }
    
}
