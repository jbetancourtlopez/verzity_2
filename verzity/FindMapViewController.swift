//
//  FindMapViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 26/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults

private let kPersonWishListAnnotationName = "kPersonWishListAnnotationName"

class FindMapViewController: BaseViewController, MKMapViewDelegate, DetailMapViewDelegate, CLLocationManagerDelegate {
    
    // outlet
    @IBOutlet weak var mapView: MKMapView!
    
    // data
    var type: String = ""
    var extanjero = false
    var idUniversidad: Int = 0
    var webServiceController = WebServiceController()
    var items:NSArray = []
    var locationManager:CLLocationManager!
    var annotations = [MKAnnotation]()
    var usuario = Usuario()
 
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.usuario = get_user()
        set_map()
        load_data()
        mapView.showsUserLocation = true
        set_ux()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        determineCurrentLocation()
    }
    
    func set_ux(){
        
        if !self.extanjero{
            navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "388E3C")
            self.title = "Universidades cercanas"
        }else {
            navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "F7BF25")
            self.title = "Universidades en el extranjero"
        }
    }
    
    func determineCurrentLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        //manager.stopUpdatingLocation()
        
        /*
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
         */
        
        // Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Yo"
        //mapView.addAnnotation(myAnnotation)
        /*
        self.annotations.append(myAnnotation)
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
         */
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        print("Error \(error)")
    }
    
    func load_data(name_university: String = ""){
        hiddenGifIndicator(view: self.view)
        
        // "nbUniversidad" : "Dw Medios Laboratorio",
        
        let array_parameter = [
            "nbPais": self.usuario.Persona?.Direcciones?.nbPais,
            "extranjero": self.extanjero,
            ] as [String : Any]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        print(parameter_json_string!)
        webServiceController.BusquedaUniversidades(parameters: parameter_json_string!, doneFunction: BusquedaUniversidades)
    }
    
    func BusquedaUniversidades(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
            items = json["Data"].arrayValue as NSArray
        }else{
            items = []
        }
        set_map()
    }
    
    func set_map() {
        
        for i in 0..<self.items.count {
            
            var item = JSON(items[i])
            var direcciones = JSON(item["Direcciones"])
            let title_item =  item["nbUniversidad"].stringValue
            let descrip_item =  item["desUniversidad"].stringValue
            
            let idUniversidad = item["idUniversidad"].intValue
            
            // Image
            var pathImage = item["pathLogo"].stringValue
            pathImage = pathImage.replacingOccurrences(of: "~", with: "")
            pathImage = pathImage.replacingOccurrences(of: "\\", with: "")
            let url =  "\(Defaults[.desRutaMultimedia]!)\(pathImage)"
            let avatar = url
            
            
            let latitud = direcciones["dcLatitud"].doubleValue
            let longitude = direcciones["dcLongitud"].doubleValue
            
            let coordinate = CLLocationCoordinate2D(latitude: latitud, longitude: longitude)
            
            let annotation = CustomAnnotation.init(title: title_item, idUniversidad: idUniversidad, location: coordinate, avatar: avatar, descrip: descrip_item)
            self.annotations.append(annotation)
        }
    
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(self.annotations)
    }
    
 
    // MARK: - MKMapViewDelegate methods
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let visibleRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 10000, 10000)
        //self.mapView.setRegion(self.mapView.regionThatFits(visibleRegion), animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kPersonWishListAnnotationName)
        
        if annotationView == nil {
            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: kPersonWishListAnnotationName)
            (annotationView as! CustomAnnotationView).detailDelegate  = self
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Ir al Detalle Universidad")
         if let pdvc = segue.destination as? DetailUniversityViewController {
            pdvc.idUniversidad = self.idUniversidad
         }
    }
    
    func detailsRequestedForPerson(idUniversidad: Int) {
        print("Hola:\(idUniversidad)")
        self.idUniversidad = idUniversidad
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailUniversity3ViewControllerID") as! DetailUniversity3ViewController
        vc.idUniversidad = idUniversidad
        self.show(vc, sender: nil)
    }
    
    
    // ----------------------
    // https://www.youtube.com/watch?v=agXeo1PApq8
    // https://stackoverflow.com/questions/30793315/customize-mkannotation-callout-view
    // http://www.surekhatech.com/blog/custom-callout-view-for-ios-map
    
    // https://stackoverflow.com/questions/38274115/ios-swift-mapkit-custom-annotation
    
    /*Dibujar Mapa
     https://www.raywenderlich.com/166182/mapkit-tutorial-overlay-views
     https://www.ioscreator.com/tutorials/draw-route-mapkit-tutorial
     http://rshankar.com/how-to-add-mapview-annotation-and-draw-polyline-in-swift/
     https://makeapppie.com/2018/02/20/use-markers-instead-of-pins-for-map-annotations/
     */
    
    
    

}
