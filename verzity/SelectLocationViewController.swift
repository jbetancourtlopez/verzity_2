//
//  SelectLocationViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 16/07/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import MapKit
import SwiftyUserDefaults

protocol SelectLocationViewControllerDelegate: class {
    func ok_save_location(latitud: Double, longitud: Double, address: String)
}

class SelectLocationViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {

    @IBOutlet var location_label: UILabel!
    @IBOutlet var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    var selectLocationViewControllerDelegate: SelectLocationViewControllerDelegate?
    
    var latitud_selected:Double = 0.0
    var longitud_selected:Double = 0.0
    
    var searchBarController : UISearchController!
    let geocoder = CLGeocoder()
    var adress = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Buscar", style: .plain, target: self, action: #selector(addTapped))

        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(action(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGesture)
        
        set_pin(newLocation: CLLocation(latitude: Defaults[.add_uni_dcLatitud]!, longitude: Defaults[.add_uni_dcLongitud]!))
 
    }
    
    @IBAction func on_click_save(_ sender: Any) {
        selectLocationViewControllerDelegate?.ok_save_location(latitud: self.latitud_selected, longitud: self.longitud_selected, address: self.adress)
        self.dismiss(animated: true, completion: nil)
        print("Guardar")
    }
    
    @objc func addTapped(){
        showSearchBar()
    }

     func showSearchBar() {
        searchBarController = UISearchController(searchResultsController: nil)
        searchBarController.hidesNavigationBarDuringPresentation = false
        self.searchBarController.searchBar.delegate = self
        present(searchBarController, animated: true, completion: nil)
    }
   

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error de localización")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
    
    @objc func action(gestureRecognizer: UIGestureRecognizer) {
        
        self.mapView.removeAnnotations(mapView.annotations)
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoords = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        geocoderLocation(newLocation: CLLocation(latitude: newCoords.latitude, longitude: newCoords.longitude))
        
        
        self.latitud_selected =  newCoords.latitude
        self.longitud_selected = newCoords.longitude
        
        let latitud = String(format: "%.6f", newCoords.latitude)
        let longitud = String(format: "%.6f", newCoords.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoords
        annotation.title = adress
        annotation.subtitle = "Latitud: \(latitud) Longitud: \(longitud)"
        mapView.addAnnotation(annotation)
    }
    
    func set_pin(newLocation: CLLocation) {
        
        self.mapView.removeAnnotations(mapView.annotations)
        
        
        geocoderLocation(newLocation: newLocation)
        
        newLocation.coordinate.latitude
        
        self.latitud_selected =  newLocation.coordinate.latitude
        self.longitud_selected = newLocation.coordinate.longitude
        
        let latitud = String(format: "%.6f", newLocation.coordinate.latitude)
        let longitud = String(format: "%.6f", newLocation.coordinate.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = newLocation.coordinate
        annotation.title = adress
        annotation.subtitle = "Latitud: \(latitud) Longitud: \(longitud)"
        mapView.addAnnotation(annotation)
    }
    
    func geocoderLocation(newLocation: CLLocation) {
        var dir  = ""
        geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
            if error == nil {
                dir = "No se ha podido determinar la dirección"
            }
            if let placemark = placemarks?.first {
                dir = self.stringFromPlacemark(placemark: placemark)
            }
            self.adress = dir
            self.location_label.text = dir
        }
        
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var line = ""
        
        if let p = placemark.thoroughfare {
            line += p + ", "
        }
        if let p = placemark.subThoroughfare {
            line += p + ", "
        }
        
        if let p = placemark.subLocality {
            line += p + ", "
        }
        
        
        if let p = placemark.postalCode {
            line += p + " "
        }
        
        if let p = placemark.locality {
            line += p + ", "
        }
        if let p = placemark.administrativeArea {
            line += p + ", "
        }
        if let p = placemark.country {
            line += p + " "
        }
 
        return line
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        if mapView.annotations.count >= 1 {
            self.mapView.removeAnnotations(mapView.annotations)
        }
        
        geocoder.geocodeAddressString(searchBar.text!) { (placemarks:[CLPlacemark]?, error:Error?) in
            
            if error == nil {
                
                let placemark = placemarks?.first
                let annotation = MKPointAnnotation()
                annotation.coordinate = (placemark?.location?.coordinate)!
                annotation.title = searchBar.text!
                
                var cLocation = CLLocation(latitude: (placemark!.location?.coordinate.latitude)!, longitude: (placemark!.location?.coordinate.longitude)!)
                self.geocoderLocation(newLocation: cLocation)
                
                
                let spam = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: annotation.coordinate, span: spam)
                
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(annotation)
                self.mapView.selectAnnotation(annotation, animated: true)
            } else {
                print("Error")
            }
        }
    }
}

extension SelectLocationViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationID = "AnnotationID"
        
        var annotationView : MKAnnotationView?
        
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
        }
        
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "img_pin")
        }
        return annotationView
    }
}
