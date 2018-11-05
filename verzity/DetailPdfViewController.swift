//
//  DetailPdfViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 26/07/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit

class DetailPdfViewController: BaseViewController, UIWebViewDelegate {

    var url_string = ""
    @IBOutlet var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        load_pdf()
        set_button_right()
        
    }
    
    func load_pdf(){
        url_string = url_string as String
        let url = URL(string: url_string)
        let urlRequest = URLRequest(url: url!)
        webView.loadRequest(urlRequest as URLRequest)
    }
    
    func set_button_right(){
        let image = UIImage(named: "ic_file_download")?.withRenderingMode(.alwaysOriginal)
        let button_find = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(on_click_find))
        
        self.navigationItem.rightBarButtonItem = button_find
    }
    
    @objc func on_click_find(sender: AnyObject) {
        print("Download")
        if let URL = NSURL(string: url_string) {
            
            
            // Ibook
            
            
            openUrl(scheme: self.url_string)

        }
        
    }
    
    func download(){
        print("Exito descraga")
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
       showGifIndicator(view: self.view)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hiddenGifIndicator(view: self.view)

    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        hiddenGifIndicator(view: self.view)

    }
    


}
