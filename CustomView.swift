//
//  CustomView.swift
//  verzity
//
//  Created by Jossue Betancourt on 26/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import SwiftyJSON

class CustomView: UIView {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var btn_show_more: UIButton!
    
    // data
    var data: AnyObject!
    weak var delegate: CustomViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func seeDetails(_ sender: Any) {
        delegate?.detailsRequestedForCustom(data: data)
    }
    
    func configureWithData(data: AnyObject) { // 5
        
        self.data = data
        var data_object = JSON(data)
        
        image.image = UIImage(named: data_object["image"].stringValue)
        title.text = data_object["title"].stringValue
        

    }
    
}

protocol CustomViewDelegate: class { // 1
    func detailsRequestedForCustom(data: AnyObject)
}
