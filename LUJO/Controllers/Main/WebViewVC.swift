//
//  WebViewVC.swift
//  LUJO
//
//  Created by iMac on 21/03/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//

import UIKit
import WebKit
import JGProgressHUD

class WebViewVC: UIViewController , WKNavigationDelegate {
//    @IBOutlet weak var webView: WKWebView!
    private let naHUD = JGProgressHUD(style: .dark)
    var url = URL(string: "https://www.golujo.com")
    
    class var identifier: String { return "WebViewVC" }
    /// Init method that will init and return view controller.
    class func instantiate(_ url: URL) -> WebViewVC {
        let viewController = UIStoryboard.main.instantiate(identifier) as! WebViewVC
        viewController.url = url
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "LUJO"
        
        if let url = self.url{
            let webView = WKWebView(frame: self.view.frame)
            webView.navigationDelegate = self
            self.view.addSubview(webView)
            webView.load(URLRequest(url: url))
            self.showNetworkActivity()
        }
    }
    
    func webViewDidStartLoad(_ : WKWebView) {
        self.hideNetworkActivity()
    }

    func webViewDidFinishLoad(_ : WKWebView) {
        self.hideNetworkActivity()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- custom Methods
    @objc func backTap(_ btn: UIBarButtonItem){
        self.navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
//        print("Finish Loading")
        self.hideNetworkActivity()
    }

    func showNetworkActivity() {
        naHUD.show(in: view)
        
    }
    
    func hideNetworkActivity() {
        // Safe guard that will call dismiss only if HUD is shown on screen.
        if naHUD.isVisible {
            naHUD.dismiss()
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
}
