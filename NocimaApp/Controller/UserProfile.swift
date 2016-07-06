//
//  UserProfile.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 7/6/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class UserProfile: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userLbl: UILabel!
    var userID = String()
    var userName = String()
    
    override func viewDidLoad() {
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userLbl.text = self.userName
//        APIClient.sendPOST(APIPath.LoadImagesForUser, params: ["userID":self.userID])
    }
    
}
