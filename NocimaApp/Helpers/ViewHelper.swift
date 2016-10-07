//
//  File.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 9/25/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class ViewHelper: NSObject {
    
    static func addBackgroundImg(controller:UIViewController){
        let backImage = UIImageView.init(frame: controller.view.frame)
        backImage.image = UIImage.init(named: "newBackground.jpg")
        backImage.contentMode = UIViewContentMode.Center
        backImage.clipsToBounds = true
        controller.view.insertSubview(backImage, atIndex: 0)
        
        let filterView = UIView.init(frame: controller.view.frame)
        filterView.backgroundColor = UIColor.init(white: 0, alpha: 0.9)
        controller.view.insertSubview(filterView, aboveSubview: backImage)
    }
    static func prepareProgressIndicator(controller:UIViewController)->RPCircularProgress{
        let progressView = RPCircularProgress.init()
        progressView.enableIndeterminate(true)
        
        progressView.center = CGPointMake(controller.view.center.x, controller.view.center.y)
        controller.view.addSubview(progressView)
        return progressView
    }
    
}
