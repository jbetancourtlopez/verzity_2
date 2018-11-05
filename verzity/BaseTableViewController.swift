//
//  BaseTableViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 21/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    var viewLoading : UIView!
    var alert : UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showGifIndicator(view: UIView){
        viewLoading = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        viewLoading.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "loading_lite2", withExtension: "gif")!)
        let advTimeGif = UIImage(named: "loading") // gifImageWithName("loading")  //.gifImageWithData(imageData!)
        let imageLoading = UIImageView(image: advTimeGif)
        imageLoading.frame = CGRect(x: (viewLoading.frame.size.width/2) - 100, y: (viewLoading.frame.height/2)-100, width: 200, height: 200)
        imageLoading.backgroundColor = Colors.color_primary  //Colors.color_primary
        imageLoading.layer.cornerRadius = 8.0
        imageLoading.contentMode = .scaleAspectFit
        viewLoading.addSubview(imageLoading)
        view.addSubview(viewLoading)
    }
    
    func hiddenGifIndicator(view: UIView){
        if viewLoading != nil{
            viewLoading.removeFromSuperview()
            viewLoading = nil
        }
    }
    
    func showAlert(_ title: String, message: String, okAction: UIAlertAction?, cancelAction: UIAlertAction?, automatic: Bool){
        /*
        alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        if  okAction != nil{
            alert.addAction(okAction!)
        }
        if cancelAction != nil{
            alert.addAction(cancelAction!)
        }
        self.present(alert, animated: true, completion: nil)
        if automatic == true{
            Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(BaseViewController.dismissAlert), userInfo: nil, repeats: false)
        }
            */
    }
    
    func dismissAlert(){
        alert.dismiss(animated: true, completion: nil)
    }
}
