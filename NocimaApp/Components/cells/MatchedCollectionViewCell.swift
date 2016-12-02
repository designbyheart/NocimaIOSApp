//
//  MatchedCollectionViewCell.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 10/15/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class MatchedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    
    override internal func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        self.userImage.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.backgroundColor = UIColor.clearColor()
        self.userImage.layer.cornerRadius = 35
        self.userImage.backgroundColor = UIColor.clearColor()
        self.userImage.layer.masksToBounds = true
        
        super.applyLayoutAttributes(layoutAttributes)
    }
}
