//
//  ForgetViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 19/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//
import UIKit
import FloatableTextField
import SwiftyJSON

class ForgetViewController: BaseViewController, FloatableTextFieldDelegate {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var email: FloatableTextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    var webServiceController = WebServiceController()
    
    var delegate: ForgetViewControllerDelegate?
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // email.becomeFirstResponder()
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
        email.floatableDelegate = self
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
    
    @IBAction func onTapCancelButton(_ sender: Any) {
       // email.resignFirstResponder()
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func onTapOkButton(_ sender: Any) {
        //email.resignFirstResponder()
        


        if FormValidate.isEmptyTextField(textField: email){
          
            
            updateAlert(title: "Error", message: StringsLabel.required, automatic: true)

        }else{
            if FormValidate.validateEmail(email.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) == false {
          
                updateAlert(title: "Error", message: StringsLabel.email_invalid, automatic: true)

            }else{
                delegate?.okButtonTapped(textFieldValue: email.text!)
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
   
}
