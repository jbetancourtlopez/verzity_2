//
//  DetailBuyViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 19/07/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults


protocol DetailBuyViewControllerDelegate: class {
    func okButtonTapped(is_summary:Int)
}

class DetailBuyViewController: BaseViewController {
    
    // outlet
    @IBOutlet var alertView: UIView!
    @IBOutlet var date_top: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var vigency: UILabel!
    @IBOutlet var price: UILabel!
    
    // data
    var webServiceController = WebServiceController()
    var info: AnyObject!
    var is_summary = 0
    
    var delegate: DetailBuyViewControllerDelegate?
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateView()
        set_data()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func set_data(){
        debugPrint(info)
        /*
        feVenta
        feVigencia
 */
        
        
        if (is_summary == 1) {
            var data = JSON(info)
            Defaults[.package_idPaquete] = data["idPaquete"].intValue
            
            print(Defaults[.package_feVenta])
            print(Defaults[.package_feVigencia])
            
            date_top.text = get_date_complete(date_complete_string: Defaults[.package_feVenta]!)
            vigency.text = get_date_complete(date_complete_string: Defaults[.package_feVigencia]!)
            
            name.text = data["nbPaquete"].stringValue
            price.text = String(format: "$ %.02f MXN", data["dcCosto"].doubleValue)
          
        } else{
            var json = JSON(info)
            var data = JSON(json["Data"])
            Defaults[.package_idPaquete] = data["idPaquete"].intValue
            date_top.text = get_date_complete(date_complete_string: data["feVenta"].stringValue)
            vigency.text = get_date_complete(date_complete_string: data["feVigencia"].stringValue)
            var paquete = JSON(data["Paquete"])
            name.text = paquete["nbPaquete"].stringValue
            price.text = String(format: "$ %.02f MXN", paquete["dcCosto"].doubleValue)
        }
        
    }
    
    func setupView() {
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

    
    @IBAction func on_click_ok(_ sender: Any) {
        delegate?.okButtonTapped(is_summary: is_summary)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
