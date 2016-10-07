//
//  WereCloseViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 10/6/16.
//  Copyright © 2016 Pedja Jevtic. All rights reserved.
//

import UIKit

class WereCloseViewController: MainViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var progressView = RPCircularProgress()
    
    var usersList = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.infoLbl.text = "Vaša lokacija neće biti javno dostupna i koristiće se samo lokacije na kojima ste bili u poslednjih sat vremena"
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = "Slučajno..."
        //        self.navigationMenu.initMenuBttn()
        self.navigationMenu.initMenuBttn()
        ViewHelper.addBackgroundImg(self)
        self.tableView.tableFooterView = UIView.init()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WereCloseViewController.loadedUsersFail(_:)), name: APINotification.Fail.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WereCloseViewController.loadedUsersSuccess(_:)), name: APINotification.Success.rawValue, object: nil)
        
    }
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // do some task
            APIClient.sendPOST(APIPath.WereClose, params: [:])
            
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                self.progressView = RPCircularProgress.init()
                self.progressView.enableIndeterminate(true)
                self.progressView.center = self.view.center
                self.view.addSubview(self.progressView)

            }
        }
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - loading from api
    func loadedUsersSuccess(n: NSNotification){
        if let response = n.object{
            if let method = response["method"] as? String{
                if (method != APIPath.WereClose.rawValue){
                    return
                }
            }
            if let r = response["response"] as? [String:AnyObject]{
                self.progressView.removeFromSuperview()
                if let users = r["users"] as? [AnyObject]{
                    self.usersList =  users
                    self.tableView.reloadData()
                }
            }
        }
    }
    func loadedUsersFail(n: NSNotification){
        
    }
    //MARK: - table view delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("wereCloseCell", forIndexPath: indexPath) as? WereCloseTableViewCell {

        let user = self.usersList[indexPath.row]
            if let imageURL = user["imageURL"] as? String {
                APIClient.loadImgFromURL(imageURL, imageView: cell.userImg!)
            }
        cell.userNameLbl.text = user["firstName"] as? String
            if let distance = user["distance"]!!.floatValue {
                cell.distanceLbl.text = "\(distance) km daleko"
            }
            return cell
        }else{
            return UITableViewCell.init()
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    
    }
}
