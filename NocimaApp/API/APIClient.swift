//
//  APIClient.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 6/7/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//
import Alamofire
import SwiftyJSON

enum APIResponse {
    case APIResponseFail
    case APIResponseSuccess
}
enum APIPath:String {
    case Login                      = "user/login"
    case Logout                     = "user/logout"
    case UpdateUserData             = "storeUserData"
    case UpdateLocation             = "updateLocation"
    case UsersForMatch              = "getMatchCandidates"
    case UpdateSettings             = "updateSettings"
    case MessageList                = "messages"
    case NewMessage                 = "messages/new"
    case UpdateImages               = "updateUserImages"
    
}


public class APIClient {
    
    static func apiRoot(path:String!)->String{
        var IS_DEBUG_MODE = true
        #if DEBUG
            IS_DEBUG_MODE = true
        #else
            IS_DEBUG_MODE = false
        #endif
        
        let server = IS_DEBUG_MODE ? "datingapp.io/api" : "nocima.rs/api"
        
        return "http://\(server)/\(path)"
    }
    static func path(path:APIPath)->String{
        //print(self.apiRoot(path.rawValue))
        return self.apiRoot(path.rawValue)
    }
    static func defaultHeader(isAuthenticated:Bool,method:APIPath, params:Dictionary<String, AnyObject> = ["":""])->Dictionary<String, String>{
        if(isAuthenticated){
            print("token: \(NSUserDefaults.standardUserDefaults().objectForKey("userToken")!)")
            let hParams = [
                "Content-Type":"application/json",
                "X-AUTH":NSUserDefaults.standardUserDefaults().objectForKey("userToken") as! String
            ]
            print("header params \(hParams)")
            return hParams
        }
        return [
            "Content-Type":"application/json"
        ]
    }
    static func sendGET(methodName:APIPath){
        print(self.path(methodName))
        let isAuthenticated:Bool! = NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil
        Alamofire.request(
            .GET,
            self.path(methodName),
            headers:self.defaultHeader(isAuthenticated, method:methodName)
            )
            .responseJSON{ response in
                // response in
                //print(response.request)  // original URL request
                print(response.response) // URL response
                //let responseData = NSString(data:response.data!, encoding:NSUTF8StringEncoding) as! String
                //print(responseData)     // server data
                //print(response.result)   // result of response serialization
                
                let isSuccess = response.response?.statusCode < 202
                let notificationStatus =  isSuccess ? APINotification.Success.rawValue:APINotification.Fail.rawValue;
                
                print("Response JSON: \(response.result.value)")
                
                var responseObject = [String:AnyObject]()
                responseObject["method"] = methodName.rawValue
                if(isSuccess){
                    if let responseValue = response.result.value as? Dictionary<String, AnyObject> {
                        responseObject["response"] = responseValue
                    }else{
                        responseObject["response"] = response.result.value
                    }
                    
                }
                
                return NSNotificationCenter.defaultCenter().postNotificationName(notificationStatus, object: responseObject)
        }
    }
    /**
     Send POST request to API server
     - Parameter APIPath:   methodName (Method address for specific API resource)
     - Parameter dict: params (Request body paramethers)
     - Returns: void (Will be triggered NSNotification with Success / Fail AVWAPINotification type)
     */
    static func sendPOST(methodName:APIPath, params:Dictionary<String, AnyObject>){
        print("method: \(methodName) \n params: \(params)")
        let isAuthenticated:Bool! = NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil
        Alamofire.request(
            .POST,
            self.path(methodName),
            headers:self.defaultHeader(isAuthenticated, method:methodName, params:params),
            parameters:params,
            encoding:.JSON
            )
            .responseJSON {
                response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                let responseData = NSString(data:response.data!, encoding:NSUTF8StringEncoding) as! String
                print(responseData)     // server data
                print(response.result)   // result of response serialization
                
                let isSuccess = response.response?.statusCode < 202
                let notificationStatus =  isSuccess ? APINotification.Success.rawValue:APINotification.Fail.rawValue;
                
                var responseObject:AnyObject = []
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    let error = response.result.value!["errorFields"]!
                    
                    if(error != nil){
                        let errorMessage = error![0]["errorField"]!!["errorMessage"]!
                        responseObject = errorMessage!;
                    }else if(JSON["errorMessage"]! != nil){
                        responseObject = JSON["errorMessage"] as! String
                        print("here \(responseObject)")
                    }else{
                        if let resultValue = response.result.value {
                            responseObject = resultValue
                        }
                    }
                    
                }else{
                    responseObject = responseData
                }
                
                /*
                 Adding method name to response for response identification purpose
                 */
                var responseDict:Dictionary<String, AnyObject> = Dictionary()
                responseDict["method"] = methodName.rawValue
                responseDict["response"] = responseObject
                
                return NSNotificationCenter.defaultCenter().postNotificationName(notificationStatus, object: responseDict)
        }
    }
    /**
     Send PATCH request to API server
     - Parameter APIPath:   methodName (Method address for specific API resource)
     - Parameter dict: params (Request body paramethers)
     - Returns: void (Will be triggered NSNotification with Success / Fail AVWAPINotification type)
     */
    static func sendPATCH(methodName:APIPath, params:Dictionary<String, AnyObject>){
        
        let isAuthenticated:Bool! = NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil
        Alamofire.request(
            .PATCH,
            self.path(methodName),
            headers:self.defaultHeader(isAuthenticated, method:methodName, params:params),
            parameters:params,
            encoding:.JSON
            )
            .responseJSON {
                response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                let responseData = NSString(data:response.data!, encoding:NSUTF8StringEncoding) as! String
                print(responseData)     // server data
                print(response.result)   // result of response serialization
                
                let isSuccess = response.response?.statusCode < 202
                let notificationStatus =  isSuccess ? APINotification.Success.rawValue:APINotification.Fail.rawValue;
                
                var responseObject:AnyObject = []
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    responseObject = response.result.value!
                }
                return NSNotificationCenter.defaultCenter().postNotificationName(notificationStatus, object: isSuccess ? responseObject: responseData)
        }
    }
    /**
     Send POST request to API server
     - Parameter APIPath:   methodName (Method address for specific API resource)
     - Parameter dict: params (Request body paramethers)
     - Returns: void (Will be triggered NSNotification with Success / Fail AVWAPINotification type)
     */
    static func sendDelete(methodName:APIPath, params:Dictionary<String, AnyObject>){
        let isAuthenticated:Bool! = NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil
        Alamofire.request(
            .DELETE,
            self.path(methodName),
            headers:self.defaultHeader(isAuthenticated, method:methodName, params:params),
            parameters:params,
            encoding:.JSON
            )
            .responseJSON {
                response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                let responseData = NSString(data:response.data!, encoding:NSUTF8StringEncoding) as! String
                print(responseData)     // server data
                print(response.result)   // result of response serialization
                
                let isSuccess = response.response?.statusCode < 202
                let notificationStatus =  isSuccess ? APINotification.DeleteSuccess.rawValue:APINotification.DeleteFail.rawValue;
                
                var responseObject:AnyObject = []
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    let error = response.result.value!["errorFields"]!
                    
                    if(error != nil){
                        let errorMessage = error![0]["errorField"]!!["errorMessage"]!
                        responseObject = errorMessage!;
                    }else if(JSON["errorMessage"]! != nil){
                        responseObject = JSON["errorMessage"] as! String
                        print("here \(responseObject)")
                    }else{
                        responseObject = response.result.value!
                    }
                    
                }else{
                    responseObject = responseData
                }
                return NSNotificationCenter.defaultCenter().postNotificationName(notificationStatus, object: responseObject)
        }
    }
    static func load_image(urlString:AnyObject, imageView:UIImageView)
    {
        if let urlStr = urlString as? String{
            if let url = NSURL(string: urlStr) {
                if let data = NSData(contentsOfURL: url) {
                    imageView.image = UIImage(data: data)
                }
            }
        }
        
    }
    
    
}
