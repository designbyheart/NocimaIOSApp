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
        
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let loc = manager. location {
//            let locValue:CLLocationCoordinate2D = loc.coordinate
//            mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: locValue.latitude,
//                longitude:locValue.longitude),zoomLevel: 14, animated: false)
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "HeatMap"
        self.navigationMenu.initMenuBttn()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}
