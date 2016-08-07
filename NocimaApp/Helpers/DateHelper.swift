//
//  DateHelper.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 7/2/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//
import UIKit

class DateHelper: NSObject  {
    
    static func getCurrentYear() -> Int {
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year], fromDate: date)
        
        return components.year
    }
    static func calculateAge() -> Int {
        let currentYear = self.getCurrentYear()
        var age:Int = 1
        if let userDetails = NSUserDefaults.standardUserDefaults().objectForKey("userDetails"){
            if let birthday = userDetails["birthday"]{
                if let year = birthday?.integerValue {
                    age = currentYear - year
                }
            }
            //when come facebook
            //                let dateFormatter = NSDateFormatter.init()
            //                dateFormatter.dateFormat = "mm/dd/yyyy"
            //                let year = dateFormatter.
            
        }
        return age
    }
}
