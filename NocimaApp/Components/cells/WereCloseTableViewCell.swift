//
//  WereCloseTableViewCell.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 10/7/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class WereCloseTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var distanceLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layoutIfNeeded()
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        let blueColor = UIColor(red:0.144,  green:0.562,  blue:1, alpha:1)
        
        if selected {
            self.userNameLbl.textColor = blueColor
            self.distanceLbl.textColor = blueColor
        }else{
            self.userNameLbl .textColor = UIColor.whiteColor()
            self.distanceLbl.textColor = UIColor.whiteColor()
        }
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.userImg.layer.cornerRadius = self.userImg.frame.size.width / 2
        self.userImg.clipsToBounds = true
        
        
    }

}
