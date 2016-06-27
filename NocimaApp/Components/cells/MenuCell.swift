//
//  MenuCell.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 5/29/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var iconImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        if selected {
            self.titleLbl.textColor = UIColor.init(red: 46, green: 146, blue: 251, alpha: 1)
        }else{
            self.titleLbl .textColor = UIColor.whiteColor()
        }
    
    }
    required init(coder aDecoder: NSCoder)
    {
        //Just Call Super
        super.init(coder: aDecoder)!
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        //First Call Super
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.titleLbl = UILabel.init(frame:CGRectMake(self.frame.size.width * 0.375, 0, (self.frame.size.width / 3) * 2.2, self.frame.size.height))
        self.titleLbl.font = UIFont.init(name: "SourceSansPro-Light", size: 25)
        self.titleLbl.textColor = UIColor.whiteColor()
        self.titleLbl.textAlignment = NSTextAlignment.Left

        self.addSubview(titleLbl)
        self.backgroundColor = UIColor.clearColor()
        
        self.iconImg = UIImageView.init(frame: CGRectMake(55, 11, 22, 22))
        self.iconImg.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(iconImg)
        
    }
    
}
