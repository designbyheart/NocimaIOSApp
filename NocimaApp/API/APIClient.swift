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
    case Register                   = "user/register"
    case ResetPass                  = "user/resetPass"
    case UpdateUserData             = "storeUserData"
    case UpdateLocation             = "updateLocation"
    case UsersForMatch              = "getMatchCandidates"
    case UpdateSettings             = "updateSettings"
    case MessageList                = "messages"
    case NewMessage                 = "messages/new"
    case ChatHistory                = "chatHistory"
    case UpdateImages               = "updateUserImages"
    case MatchUser                  = "matchUser"
    case ClubsList                  = "clubs/list"
    case CheckUserStatus            = "user/status"
    case WelcomeData                = "uploadWelcomeData"
    case UploadImage                = "uploadImage"
    case UserGallery                = "listGallery"
    case ListUserMessages           = "listUserMessages"
    case UploadPushToken            = "storeDeviceNotificationToken"
    case LoadImagesForUser          = "loadImagesForUser"
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
        return self.apiRoot(path.rawValue)
    }
    static func defaultHeader(isAuthenticated:Bool,method:APIPath, params:Dictionary<String, AnyObject> = ["":""])->Dictionary<String, String>{
        if(isAuthenticated){
//            print("token: \(NSUserDefaults.standardUserDefaults().objectForKey("userToken")!)")
            let token = NSUserDefaults.standardUserDefaults().objectForKey("userToken") as! String
            var hParams = [
                "Content-Type":"application/json",
                ]
            if(token.characters.count > 0){
                hParams["X-AUTH"] = token
            }
            print("header params \(hParams)")
            return hParams
        }
        return [
            "Content-Type":"application/json"
        ]
    }
    static func sendGET(methodName:APIPath){
//        print(self.path(methodName))
        let isAuthenticated:Bool! = NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil
        Alamofire.request(
            .GET,
            self.path(methodName),
            headers:self.defaultHeader(isAuthenticated, method:methodName)
            )
            .responseJSON{ response in
                // response in
                //print(response.request)  // original URL request
//                print(response.response) // URL response
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
//        print("method: \(methodName) \n params: \(params)")
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
//                print(response.request)  // original URL request
//                print(response.response) // URL response
                let responseData = NSString(data:response.data!, encoding:NSUTF8StringEncoding) as! String
//                print(responseData)     // server data
//                print(response.result)   // result of response serialization
                
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
//                print(response.request)  // original URL request
//                print(response.response) // URL response
                let responseData = NSString(data:response.data!, encoding:NSUTF8StringEncoding) as! String
//                print(responseData)     // server data
//                print(response.result)   // result of response serialization
                
                let isSuccess = response.response?.statusCode < 202
                let notificationStatus =  isSuccess ? APINotification.Success.rawValue:APINotification.Fail.rawValue;
                
                var responseObject:AnyObject = []
                
                if response.result.value != nil {
//                    print("JSON: \(JSON)")
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
//                print(response.request)  // original URL request
//                print(response.response) // URL response
                let responseData = NSString(data:response.data!, encoding:NSUTF8StringEncoding) as! String
//                print(responseData)     // server data
//                print(response.result)   // result of response serialization
                
                let isSuccess = response.response?.statusCode < 202
                let notificationStatus =  isSuccess ? APINotification.DeleteSuccess.rawValue:APINotification.DeleteFail.rawValue;
                
                var responseObject:AnyObject = []
                
                if let JSON = response.result.value {
//                    print("JSON: \(JSON)")
                    let error = response.result.value!["errorFields"]!
                    
                    if(error != nil){
                        let errorMessage = error![0]["errorField"]!!["errorMessage"]!
                        responseObject = errorMessage!;
                    }else if(JSON["errorMessage"]! != nil){
                        responseObject = JSON["errorMessage"] as! String
//                        print("here \(responseObject)")
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
    
    static func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    static func uploadImage(image:UIImage, URL:String){
        Alamofire.upload(.POST, URL, multipartFormData: {
            multipartFormData in
            if  let imageData = UIImageJPEGRepresentation(image, 0.6) {
                multipartFormData.appendBodyPart(data: imageData, name: "image", fileName: "file.jpg", mimeType: "image/jpg")
            }
            var parameters = [String:AnyObject]()
            parameters = ["userToken":NSUserDefaults.standardUserDefaults().objectForKey("userToken")!]
            
            
            for (key, value) in parameters {
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
            }, encodingCompletion: {
                encodingResult in
                
                switch encodingResult {
                case .Success(let upload, _, _):
//                    print("s")
                    upload.responseJSON { response in
//                        print(response.request)  // original URL request
//                        print(response.response) // URL response
//                        print(response.data)     // server data
//                        print(response.result)   // result of response serialization
                        
                        if response.result.value != nil {
//                            print("JSON: \(JSON)")
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    static func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, AnyObject>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        if let userToken = NSUserDefaults.standardUserDefaults().objectForKey("userToken") as? String{
            mutableURLRequest.setValue(userToken, forHTTPHeaderField:"X-AUTH")
        }
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    static func uploadImage(image:UIImage, position:Int){
        let resizedImg = self.ResizeImage(image, targetSize: CGSizeMake(image.size.width * 0.5, image.size.height*0.5))
        let params = ["position":position]
//        let isAuthenticated:Bool! = NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil
//        let headers = self.defaultHeader(isAuthenticated, method:APIPath.UploadImage)
//        print(headers)
        
        let imageData = UIImageJPEGRepresentation(resizedImg, 70)
        let urlRequest = APIClient.urlRequestWithComponents("\(APIClient.apiRoot(APIPath.UploadImage.rawValue))", parameters: params, imageData: imageData!)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                let progress = Double((totalBytesWritten * 100) / totalBytesExpectedToWrite).roundToPlaces(3)
                print("\(progress)")
            }
            .responseJSON { (response) in
                
                print(response)
                if let value = response.result.value{
                    if let imageURL = value["imageURL"] as? String{
                        print(imageURL)
                    }
                }
                
        }
    }
    static func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}
