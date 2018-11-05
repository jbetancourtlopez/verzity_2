//
//  CustomAnnotation.swift
//  ExampleMap
//
//  Created by Jossue Betancourt on 11/07/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var avatar: String
    var idUniversidad: Int
    
    init(title: String, idUniversidad: Int, location:CLLocationCoordinate2D, avatar: String ){
        self.title = title
        self.idUniversidad = idUniversidad
        self.coordinate = location
        self.avatar = avatar
    }
}
