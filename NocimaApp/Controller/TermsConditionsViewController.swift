//
//  TermsConditionsViewController.swift
//  NocimaApp
//
//  Created by Pedja Jevtic on 10.8.16..
//  Copyright © 2016. Pedja Jevtic. All rights reserved.
//

import UIKit

class TermsConditionsViewController: MainViewController {

    @IBOutlet weak var webView: UIWebView!
    var menuBttn = UIButton()
    
    var titleString = ""
    var content = ""
    var isPrivacy = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.webView.opaque = false
        self.webView.backgroundColor = UIColor.clearColor()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationMenu = NavigationView(controller: self)
        self.navigationMenu.titleView.text = titleString
        self.navigationMenu.initChatBttn()
        self.setupBackBttn()

        webView.loadHTMLString(content, baseURL: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupBackBttn(){
        self.menuBttn = UIButton(frame:CGRectMake(5, 20, 60, 40))
        self.menuBttn.setImage(UIImage(named: "backIcon"), forState: UIControlState.Normal)
        self.menuBttn.imageEdgeInsets = UIEdgeInsetsMake(13, 20, 12, 20)
        if let messageB:UIButton = self.menuBttn{
            messageB.addTarget(self, action: #selector(ChatViewController.goBack(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
        self.view .addSubview(menuBttn)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func goBack(sender:AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            
        })
    }
}
