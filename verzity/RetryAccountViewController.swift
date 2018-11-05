//
//  RetryAccountViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 08/08/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import FloatableTextField
import SwiftyJSON


protocol RetryAccountViewControllerDelegate: class {
    func okButtonTapped()
    func cancelButtonTapped()
}

class RetryAccountViewController: BaseViewController {
    
    @IBOutlet var alertView: UIView!
    @IBOutlet var image_profile: UIImageView!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var name_profile: UILabel!
    @IBOutlet var cancelButton: UIButton!
    
    var webServiceController = WebServiceController()
    var info: AnyObject!
    
    var delegate: RetryAccountViewControllerDelegate?
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set_data()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func setupView() {
        self.image_profile.layer.masksToBounds = true
        self.image_profile.cornerRadius = 40
        
        alertView.layer.cornerRadius = 2
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    func set_data(){
        debugPrint(info)
        var data = JSON(info)
        name_profile.text = data["nbCompleto"].stringValue
        
        set_photo_profile(url: data["pathFoto"].stringValue, image: image_profile)
    }
    
    @IBAction func onTapCancelButton(_ sender: Any) {
        // email.resignFirstResponder()
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onTapOkButton(_ sender: Any) {
        //email.resignFirstResponder()
        delegate?.okButtonTapped()
        self.dismiss(animated: true, completion: nil)
        
    }

}
