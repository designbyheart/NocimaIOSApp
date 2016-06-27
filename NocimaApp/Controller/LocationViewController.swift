//
//  LocationController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/26/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import Mapbox

class LocationViewController: MainViewController,MGLMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView:MGLMapView!
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var clubs = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Put this in your -viewDidLoad method
        //        var template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        //        var overlay = MKTileOverlay()
        //[[MKTileOverlay alloc] initWithURLTemplate:template];
        
        //This is the important bit, it tells your map to replace ALL the content, not just overlay the tiles.
        //        overlay.canReplaceMapContent = YES;
        //        [self.mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
        
        let styleURL = NSURL(string: "mapbox://styles/dbyh/cip0hdumy0003dlnq2eqkvo9i")
        mapView = MGLMapView(frame: view.bounds,
                             styleURL: styleURL)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // set the map's center coordinate
        self.view.addSubview(mapView)
        
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        APIClient.sendGET(APIPath.ClubsList)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationViewController.loadClubsFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationViewController.loadClubsSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        
        if let clubsList = NSUserDefaults.standardUserDefaults().objectForKey("clubsList") as? [AnyObject]{
            self.clubs = clubsList
            self.displayClubs()
        }
        
        
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = manager.location {
            if let locValue:CLLocationCoordinate2D = loc.coordinate{
                currentLocation = locValue
                mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: locValue.latitude,
                    longitude:locValue.longitude),zoomLevel: 14, animated: false)
                
                manager.stopUpdatingLocation()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Gde izaći?"
        self.navigationMenu.initMenuBttn()
        
        //        self.mapView.setCenterCoordinate(currentLocation,zoomLevel: 12, animated: false)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
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
        if let clubList = n.object!["response"] as? [AnyObject]{
            //        if let response = n.object as? [AnyObject]{
            NSUserDefaults.standardUserDefaults().setObject(clubList, forKey: "clubsList")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.clubs = clubList
            self.displayClubs()
        }
    }
}
