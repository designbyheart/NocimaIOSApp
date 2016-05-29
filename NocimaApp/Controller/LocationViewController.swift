//
//  LocationController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/26/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: MainViewController {
    
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "HeatMap"
        self.navigationMenu.initMenuBttn()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSUserDefaults.standardUserDefaults().setObject("LocationView", forKey: "ActiveView")
        
    }
    
    override func openLikeView(n:AnyObject) {
        super.openLikeView(n)
        self.performSegueWithIdentifier("openLikeView", sender: self)
    }
    override func openSettingsView(n:AnyObject) {
        super.openSettingsView(n)
        self.performSegueWithIdentifier("openSettingsView", sender: self)
    }
    override func openMyProfileView(n:AnyObject) {
        super.openMyProfileView(n)
        self.performSegueWithIdentifier("openMyProfileView", sender: self)
    }
}
