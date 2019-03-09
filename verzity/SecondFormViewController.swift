import UIKit
import FloatableTextField
import SwiftyJSON
import SwiftyUserDefaults
import MapKit

class SecondFormViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate, FloatableTextFieldDelegate {

    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var topConstraintDescription: NSLayoutConstraint!
    
    //Pais
    @IBOutlet var countryPickerView: UIPickerView!
    @IBOutlet var icon_country: UIImageView!
    
    @IBOutlet var second_cp: FloatableTextField!
    @IBOutlet var second_state: FloatableTextField!
    @IBOutlet var second_municipio: FloatableTextField!
    @IBOutlet var second_city: FloatableTextField!
    @IBOutlet var second_description: FloatableTextField!
    @IBOutlet var second_location: FloatableTextField!
    @IBOutlet var button_location: UIButton!
    
    var webServiceController = WebServiceController()
    var countries:NSArray = []
    var is_mexico = 1;
    var name_country = ""
    var latitud: Double = 0.0
    var longitud: Double = 0.0
    
    let geocoder = CLGeocoder()
    var usuario = Usuario()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.usuario = get_user()
        setup_ux()
        setup_textfield()
        load_countries()
        set_data()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        self.view.addGestureRecognizer(tap)
        
        registerForKeyboardNotifications(scrollView: scrollView)
        setGestureRecognizerHiddenKeyboard()
    }
    
    @IBAction func on_click_map(_ sender: Any) {
        let selectLocationViewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectLocationViewControllerID") as! SelectLocationViewController
        
        selectLocationViewController.providesPresentationContextTransitionStyle = true
        selectLocationViewController.definesPresentationContext = true
        selectLocationViewController.selectLocationViewControllerDelegate = self
        self.present(selectLocationViewController, animated: true, completion: nil)
    }
    
    
    func setup_ux(){
        
        icon_country.image = icon_country.image?.withRenderingMode(.alwaysTemplate)
        icon_country.tintColor = Colors.gray
        
        let image_visitar_web  = UIImage(named: "ic_visitar_web")?.withRenderingMode(.alwaysTemplate)
        button_location.setImage(image_visitar_web, for: .normal)
        button_location.tintColor = Colors.gray
        
        /*
        icon_location.image = icon_location.image?.withRenderingMode(.alwaysTemplate)
        icon_location.tintColor = Colors.gray
         */
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        self.view.addGestureRecognizer(tap)
    }
    
    func setup_textfield(){
        
        second_cp.floatableDelegate = self
        second_state.floatableDelegate = self
        second_municipio.floatableDelegate = self
        second_city.floatableDelegate = self
        second_description.floatableDelegate = self
        second_location.floatableDelegate = self
        
        // on_change_code_postal
        second_cp.addTarget(self, action: #selector(SecondFormViewController.cpDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    func load_countries(){
        print("Carga de paises")
        let array_parameter = ["": ""]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.GetPaises(parameters: parameter_json_string!, doneFunction: GetPaises)
    }
    
    
    func GetPaises(status: Int, response: AnyObject){
        var json = JSON(response)
        let selected_name_country = self.usuario.Persona?.Universidades?.Direcciones?.nbPais
        if status == 1{
            var countries_aux = json["Data"].arrayObject
            print(countries)
            let default_c = [
                "cvPais" : "SP",
                "nbPais" : "-Seleccionar país.-",
                "idPais" : 0
                ] as [String : Any]
            
            countries_aux?.insert(default_c, at: 0)
            countries = countries_aux! as NSArray
        }else{
            countries = []
            showMessage(title: response as! String, automatic: true)
        }
        countryPickerView.reloadAllComponents()
        
        // Establesco el Pais Seleccionado
        for i in 0 ..< countries.count{
            var item_country_json = JSON(countries[i])
            let name_country = item_country_json["nbPais"].stringValue
            
            let isEqual = (selected_name_country == name_country)
            if isEqual {
                self.name_country = name_country
                countryPickerView.selectRow(i, inComponent:0, animated:true)
            }
        }
        
        is_mexico_setup(name_country: selected_name_country!)
        hiddenGifIndicator(view: self.view)
    }
    
    @objc func cpDidChange(_ textField: UITextField) {
        print("Change CP")
        let cp = textField.text
        if (cp?.count)! >= 5{
            showGifIndicator(view: self.view)
            let array_parameter = ["Cp_CodigoPostal": second_cp.text!]
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.BuscarCodigoPostal(parameters: parameter_json_string!, doneFunction: BuscarCodigoPostal)
        }
    }
    
    func BuscarCodigoPostal(status: Int, response: AnyObject){
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
            let list_cp = json["Data"].arrayValue as NSArray
            if  list_cp.count > 0 {
                let item_cp = JSON(list_cp[0])
                second_city.text = item_cp["Cp_Ciudad"].stringValue
                second_municipio.text = item_cp["Cp_Municipio"].stringValue
                second_state.text = item_cp["Cp_Estado"].stringValue
            }else{
                second_city.text = ""
                second_municipio.text =  ""
                second_state.text = ""
            }
        }else{
            showMessage(title: response as! String, automatic: true)
        }
        hiddenGifIndicator(view: self.view)
    }
    
    func validate_form()-> Int{
        var count_error:Int = 0
        
        // CP
        if  is_mexico == 1{
            if FormValidate.isEmptyTextField(textField: second_cp){
                second_cp.setState(.FAILED, with: StringsLabel.required)
                count_error = count_error + 1
            }else{
                second_cp.setState(.DEFAULT, with: "")
            }
        }
        
        // Ubicación
        if FormValidate.isEmptyTextField(textField: second_location){
            second_location.setState(.FAILED, with: StringsLabel.required)
            count_error = count_error + 1
        }else{
            second_location.setState(.DEFAULT, with: "")
        }
       
        return count_error
    }
    
    
    // Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var item_country_json = JSON(countries[row])
        return  item_country_json["nbPais"].stringValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var item_country_json = JSON(countries[row])
        self.name_country = item_country_json["nbPais"].stringValue
        is_mexico_setup(name_country: self.name_country)
    }
    
    func is_mexico_setup(name_country: String){
        if  name_country != "México" {
            second_cp.isHidden = true
            second_state.isHidden = true
            second_municipio.isHidden = true
            second_city.isHidden = true
            topConstraintDescription.constant = -260
            is_mexico = 0

            second_cp.text = ""
            second_state.text = ""
            second_municipio.text = ""
            second_city.text = ""

        }else{
            second_cp.isHidden = false
            second_state.isHidden = false
            second_municipio.isHidden = false
            second_city.isHidden = false
            topConstraintDescription.constant = 0
            is_mexico = 1
        }
    }
    
    
    func set_data(){
        
        print(self.usuario)
        
        var univ = Universidades()
        univ = (self.usuario.Persona?.Universidades)!
        
        second_cp.text = univ.Direcciones?.numCodigoPostal
        second_state.text = univ.Direcciones?.nbEstado
        second_municipio.text = univ.Direcciones?.nbMunicipio
        second_city.text = univ.Direcciones?.nbCiudad
        second_description.text = univ.Direcciones?.desDireccion
        
        var lat = univ.Direcciones!.dcLatitud
        var lon = univ.Direcciones!.dcLongitud
        
        if lat == "" {
            lat = "0.0"
        }
        
        if lon == "" {
            lon = "0.0"
        }
        
        self.latitud = Double(lat)!
        self.longitud = Double(lon)!
        
        // Genero la location_text
        geocoderLocation(newLocation: CLLocation(latitude: self.latitud, longitude: self.longitud))
    }
    
    @objc(textField:shouldChangeCharactersIn:replacementString:) func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 {
            return true
        }
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        
        switch textField {
        case second_cp:
            return newString.length <= 5
        default:
            return true
        }
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
            self.second_location.text = dir
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
    
}

extension SecondFormViewController: SelectLocationViewControllerDelegate {
    func ok_save_location(latitud: Double, longitud: Double, address: String){
        second_location.text = address
        self.latitud = latitud
        self.longitud = longitud
        
    }
}
