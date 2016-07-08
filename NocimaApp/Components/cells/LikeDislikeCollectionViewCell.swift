//
//  LikeDislikeCollectionViewCell.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 6/5/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class LikeDislikeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    var userID:String!
    
    
    override internal func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        let center = layoutAttributes.center
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.toValue = center.y
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.8, 2.0, 1.0, 1.0)
        layer.addAnimation(animation, forKey: "position.y")

        self.backgroundColor = UIColor.clearColor()
        self.userImg.layer.cornerRadius = 20
        self.userImg.backgroundColor = UIColor.blackColor()
        self.userImg.layer.masksToBounds = true

        super.applyLayoutAttributes(layoutAttributes)
    }

}
