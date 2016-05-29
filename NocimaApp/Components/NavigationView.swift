//
//  NavigationView.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/29/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class NavigationView: UIView {
    
    //    let titleView:UILabel
    @IBOutlet var titleView:UILabel!
    @IBOutlet var menuBttn: UIButton!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        addBehavior()
    }
    
    convenience init (controller: UIViewController) {
        self.init(frame:CGRectMake(0, 0,controller.view.frame.size.width, 60))
        controller.view .addSubview(self)
//        self.backgroundColor = UIColor.redColor()
        let titleWidth = controller.view.frame.size.width * 0.8
        self.titleView = UILabel(frame: CGRectMake((controller.view.frame.size.width-titleWidth)/2, 20, titleWidth, 40))
        self.titleView.textColor = UIColor.whiteColor()
        self.titleView.textAlignment = NSTextAlignment.Center
        self.titleView.font = UIFont.init(name: "Source Sans Pro", size: 20)
        self.addSubview(self.titleView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func addBehavior (){
//        print("Add all the behavior here")
    }
    func initMenuBttn(){
        self.menuBttn = UIButton(frame:CGRectMake(5, 20, 60, 40))
        self.menuBttn.setImage(UIImage(named: "menuIcon"), forState: UIControlState.Normal)
        self.menuBttn.imageEdgeInsets = UIEdgeInsetsMake(13, 20, 12, 20)
        self .addSubview(menuBttn)
    }
}
