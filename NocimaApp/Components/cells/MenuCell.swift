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
        self.titleLbl = UILabel.init(frame:CGRectMake(self.frame.size.width * 0.375, 0, self.frame.size.width/2, self.frame.size.height))
        self.titleLbl.font = UIFont.init(name: "SourceSansPro-Light", size: 25)
        self.titleLbl.textColor = UIColor.whiteColor()
        self.addSubview(titleLbl)
        self.backgroundColor = UIColor.clearColor()
        
        self.iconImg = UIImageView.init(frame: CGRectMake(55, 11, 22, 22))
        self.iconImg.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(iconImg)
        
    }
    
}
