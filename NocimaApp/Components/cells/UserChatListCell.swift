//
//  UserChatListCell.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 7/2/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class UserChatListCell: UITableViewCell {
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var blockBttn: UIButton!
    @IBOutlet weak var notificationIcon: UIView!
    
    
    override func awakeFromNib() {
        
        self.notificationIcon.layer.cornerRadius = 10
        self.notificationIcon.layer.masksToBounds = true
        self.notificationIcon.layer.borderColor = UIColor.init(white: 0, alpha: 0.9).CGColor
        self.notificationIcon.layer.borderWidth = 4
        
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
        }else{
            self.userNameLbl .textColor = UIColor.whiteColor()
        }
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.userImg.layer.cornerRadius = self.userImg.frame.size.width / 2
        self.userImg.clipsToBounds = true
        
        
    }

    
}
