//
//  LocationController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/26/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import Foundation
import Mapbox
import CoreLocation

class LocationViewController: MainViewController, MGLMapViewDelegate, CLLocationManagerDelegate, UIWebViewDelegate {
    
    @IBOutlet var mapView:MGLMapView!
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    let styleURL = NSURL(string: "mapbox://styles/dbyh/cip0hdumy0003dlnq2eqkvo9i")
    var clubs = [AnyObject]()
    var webView = UIWebView()
    var progressView = RPCircularProgress()
    var instHeader = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Put this in your -viewDidLoad method
        //        var template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        //        var overlay = MKTileOverlay()
        //[[MKTileOverlay alloc] initWithURLTemplate:template];
        
        //This is the important bit, it tells your map to replace ALL the content, not just overlay the tiles.
        //        overlay.canReplaceMapContent = YES;
        //        [self.mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
        
        
    }
    func locationManager(manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]){
        if let loc = manager.location {
            if let locValue:CLLocationCoordinate2D = loc.coordinate{
                currentLocation = locValue
                //                if let map = self.mapView!{
                self.mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: locValue.latitude,
                    longitude:locValue.longitude),zoomLevel: 14, animated: true)
                //                }
                
                manager.stopUpdatingLocation()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Gde izaći?"
        self.navigationMenu.initMenuBttn()
        self.navigationMenu.initChatBttn()
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingLocation()
        }
        
        
        
        //        self.mapView.showsUserLocation = true
        self.mapView = MGLMapView.init(frame:view.bounds, styleURL:styleURL)
        self.mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.mapView.showsUserLocation = true
        // set the map's center coordinate
        self.view.insertSubview(mapView, atIndex: 0)
        //        self.view.
        //        addSubview(mapView)
        
        mapView.delegate = self
        
        if currentLocation.latitude != 0 || currentLocation.longitude != 0{
            self.mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude), zoomLevel: 14, animated: false)
        }
        
        APIClient.sendGET(APIPath.ClubsList)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationViewController.loadClubsFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationViewController.loadClubsSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        
        //
        // For use in foreground
        //        if (self.locationManager.respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        //            [self.locationManager requestWhenInUseAuthorization];
        //        }
        
        //
        //        if !CLLocationManager.locationServicesEnabled {
        //            self.locationManager.requestWhenInUseAuthorization()
        //        }
        
        if let clubsList = NSUserDefaults.standardUserDefaults().objectForKey("clubsList") as? [AnyObject]{
            self.clubs = clubsList
            self.displayClubs()
        }
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    //MARK: - User action on tapping one of the clubs
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        if let clubName = annotation.title {
            let club = self.filterClubsByName(clubName!)
            if let instagramURL = club["instagramURL"] as? String{
                if(instagramURL.characters.count > 0){
                    self.openInstagramProfile(instagramURL)
                    return false
                }
            }
        }
        return true
    }
    func openInstagramProfile(url: String){
        webView = UIWebView.init(frame: self.view.frame)
        webView.delegate = self
        webView.backgroundColor = UIColor.blackColor()
        webView.opaque = false
        //init(patternImage: UIImage.init(named:"viewBackground")!)
        self.view.addSubview(webView)
        let request = NSURLRequest.init(URL: NSURL.init(string: url)!)
        webView.loadRequest(request)
        
        self.progressView = ViewHelper.prepareProgressIndicator(self)
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        self.progressView.removeFromSuperview()
        self.addInstagramHeader()
    }
    func addInstagramHeader(){
        self.instHeader.removeFromSuperview()
        
        let hWidth = self.view.frame.size.width/2
        self.instHeader = UIView.init(frame: CGRectMake(hWidth, 0, hWidth, 40))
        self.instHeader.backgroundColor = UIColor.whiteColor()
        self.webView.addSubview(instHeader)
        
        let closeBttn = UIButton.init(frame: CGRectMake(hWidth/2, 0, hWidth/2, 40))
        closeBttn.setTitle("Zatvori", forState: UIControlState.Normal)
        closeBttn.setTitleColor(UIColor(red:0.24,green:0.60,blue:0.93,alpha:1.00), forState: UIControlState.Normal)
        closeBttn.addTarget(self, action: #selector(LocationViewController.closeInstagram), forControlEvents: UIControlEvents.TouchUpInside)
        instHeader.addSubview(closeBttn)
    }
    func closeInstagram(){
        self.webView.removeFromSuperview()
        self.instHeader.removeFromSuperview()
    }
    //MARK: - Methods for displayong one details from Instagram
    func filterClubsByName(name:String)->[String: AnyObject]{
        var club = [String:AnyObject]()
        
        if(self.clubs.count > 0){
            for c in self.clubs {
                if let clubItem = c as? [String:AnyObject]{
                    if let clubName = clubItem["name"] as? String{
                        if(clubName == name){
                            club = clubItem
                            break
                        }
                    }
                }
            }
        }
        return club
    }
    //MARK: - Clubs
    func displayClubs(){
        if(self.clubs.count > 0){
            for c in self.clubs {
                var latitude = 0.0
                var longitude = 0.0
                
                if let lat = c["latitude"] {
                    latitude = (lat?.doubleValue)!
                }
                if let long = c["longitude"] {
                    longitude = (long?.doubleValue)!
                }
                
                let point = MGLPointAnnotation()
                point.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                if let pointName = c["name"] as? String {
                    point.title = pointName
                }
                if let address = c["address"] as? String {
                    point.subtitle = "\(address)"
                    if let city = c["city"] as? String {
                        point.subtitle = "\(address), \(city)"
                    }
                }
                mapView.addAnnotation(point)
            }
        }
    }
    func loadClubsFail(n:NSNotification){
        
    }
    func loadClubsSuccess(n:NSNotification){
        if let data = n.object as? Dictionary<String, AnyObject>{
            if let method = data["method"] as? String{
                if method != APIPath.ClubsList.rawValue {
                    return
                }
            }
            if let clubList = data["response"] as? [AnyObject]{
                NSUserDefaults.standardUserDefaults().setObject(clubList, forKey: "clubsList")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.clubs = clubList
                self.displayClubs()
            }
        }
    }
}
