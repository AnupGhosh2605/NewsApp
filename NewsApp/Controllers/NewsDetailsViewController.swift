//
//  NewsDetailsViewController.swift
//  NewsApp
//
//  Created by Anup Ghosh on 24/01/25.
//

import UIKit
import WebKit

class NewsDetailsViewController: UIViewController,WKNavigationDelegate,WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!

    var urlString : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self

        setActivityIndicator()
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    // Activity indicator to show the loading status
    private func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.isHidden = true

        view.addSubview(activityIndicator)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

        
    }
    
}
