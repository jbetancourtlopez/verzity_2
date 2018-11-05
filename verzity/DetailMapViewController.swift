//
//  DetailMapViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 19/07/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//



import UIKit
import MapKit
import SwiftyJSON

class customPin: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle: String, pinSubTitle: String, location:CLLocationCoordinate2D){
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
        
    }
}

class DetailMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var info: AnyObject = {} as AnyObject
    @IBOutlet weak var mapView: MKMapView!
    var locationManager:CLLocationManager!
    
    var locManager = CLLocationManager()
    

    var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        info = info as AnyObject
        debugPrint(info)
        locManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        let university_json = JSON(info)
        
        self.title = university_json["nbUniversidad"].stringValue
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        var currentLocation: CLLocation!
        
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            
            currentLocation = locManager.location
            
        }
        var info_json = JSON(info)
        
        let direcciones = JSON(info_json["Direcciones"])
        
        
        let source = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: source, span: MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10))
        mapView.setRegion(region, animated: true)
        
        // 2.
        let sourceLocation = source
        let destinationLocation = CLLocationCoordinate2D(latitude: direcciones["dcLatitud"].doubleValue, longitude: direcciones["dcLongitud"].doubleValue)
        
        // 3.
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // 4.
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        
        
        // 7.
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8.
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
        
        
        //Agrego los Markers
        
        add_makers_universities(lat: direcciones["dcLatitud"].doubleValue, lon: direcciones["dcLongitud"].doubleValue , title: info_json["nbUniversidad"].stringValue )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        determineCurrentLocation()
    }
    
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    


    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{ return nil }
        let anotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customAnotation")
        anotationView.image = UIImage(named: "ic_school_map.png")
        anotationView.canShowCallout = true
        return anotationView
        
    }
    
    func add_makers_universities(lat: Double, lon: Double, title: String){
        let location = CLLocationCoordinate2D(latitude: lat,
                                              longitude: lon)
        let pin = customPin(pinTitle: title, pinSubTitle: "", location: location)
        mapView.addAnnotation(pin)
    }
    
    //MARK:- MapViewDelegate methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        
        if overlay is MKPolyline {
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.lineWidth = 5
            
        }
        return polylineRenderer
    }
    
    
    
    // https://www.youtube.com/watch?v=agXeo1PApq8
    // https://stackoverflow.com/questions/30793315/customize-mkannotation-callout-view
    // http://www.surekhatech.com/blog/custom-callout-view-for-ios-map
    
    
    
    
}
