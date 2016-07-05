//
//  DataHelper.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 7/5/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class DataHelper: NSObject {

    static func convertDeviceTokenToString(deviceToken:NSData) -> String {
//        [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
        if deviceToken.description.characters.count > 0 {
        
        var deviceTokenStr = deviceToken.description.stringByReplacingOccurrencesOfString(">", withString: "")
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString("<", withString: "")
        return deviceTokenStr.uppercaseString
        }
        return ""
    }
}
