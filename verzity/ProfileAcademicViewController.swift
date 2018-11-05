//
//  ProfileAcademicViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 30/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import FloatableTextField
import SwiftyJSON
import SwiftyUserDefaults


class ProfileAcademicViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, FloatableTextFieldDelegate{
    
    @IBOutlet var countryConstraintHeight: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var topContraintDescription: NSLayoutConstraint!
    @IBOutlet var img_profile: UIImageView!
    @IBOutlet var import_image: UIButton!
    @IBOutlet var countryPickerView: UIPickerView!
    @IBOutlet var icon_country: UIImageView!
    @IBOutlet var name_profile: FloatableTextField!
    @IBOutlet var phone_profile: FloatableTextField!
    @IBOutlet var cp_profile: FloatableTextField!
    @IBOutlet var description_profile: FloatableTextField!
    @IBOutlet var city_profile: FloatableTextField!
    @IBOutlet var municipio_profile: FloatableTextField!
    @IBOutlet var email_profile: FloatableTextField!
    @IBOutlet var state_profile: FloatableTextField!
    
    @IBOutlet var button_save: UIButton!
    var webServiceController = WebServiceController()
    var countries: NSArray = []
    var is_mexico = 1;
    var name_country = ""
    var type = ""
    var is_postulate = 0

    var name_image = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.type = type as String
        setup_ux()
        setup_textfield()
        get_data_profile()
        load_countries()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        self.view.addGestureRecognizer(tap)
        
        registerForKeyboardNotifications(scrollView: scrollView)
        setGestureRecognizerHiddenKeyboard()
    }
    
    @objc func cpDidChange(_ textField: UITextField) {
        print("Change CP")
        let cp = textField.text
        if (cp?.count)! >= 5{
            showGifIndicator(view: self.view)
            let array_parameter = ["Cp_CodigoPostal": cp_profile.text!]
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.BuscarCodigoPostal(parameters: parameter_json_string!, doneFunction: BuscarCodigoPostal)
        }
    }
    
    @objc func emailDidChange(_ textField: UITextField) {
        print("Email Change")
        
        if  is_postulate == 0 {
            return
        }
        
        // Email
        if !FormValidate.isEmptyTextField(textField: email_profile){
            if !FormValidate.validateEmail(email_profile.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) == false {
                print("Email Valido")
                showGifIndicator(view: self.view)
                let array_parameter = [
                    "desCorreo": email_profile.text!,
                    "Dispositivos": [
                        [
                        "cvDispositivo": "",//Defaults[.cvDispositivo]!,
                        "cvFirebase": "", //Defaults[.cvFirebase]!
                        ]
                    ]
                ] as [String : Any]
                
                let parameter_json = JSON(array_parameter)
                let parameter_json_string = parameter_json.rawString()
                webServiceController.verificarCuentaUniversitario(parameters: parameter_json_string!, doneFunction: verificarCuentaUniversitario)
            }
        }
    }
    
    func verificarCuentaUniversitario(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        var json = JSON(response)
        print("Respuesta")
        debugPrint(json)
        if status == 1{
            print("Abro modal")
            open_modal(info: json["Data"])
        }
    }
    
    func open_modal(info:JSON){
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "RetryAccountViewControllerID") as! RetryAccountViewController
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.delegate = self
        customAlert.info = info as AnyObject
        self.present(customAlert, animated: true, completion: nil)
    }
    
    func BuscarCodigoPostal(status: Int, response: AnyObject){
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
            let list_cp = json["Data"].arrayValue as NSArray
            if  list_cp.count > 0 {
                let item_cp = JSON(list_cp[0])
                city_profile.text = item_cp["Cp_Ciudad"].stringValue
                municipio_profile.text = item_cp["Cp_Municipio"].stringValue
                state_profile.text = item_cp["Cp_Estado"].stringValue
            }else{
                city_profile.text = ""
                municipio_profile.text =  ""
                state_profile.text = ""
            }
        }else{
            showMessage(title: response as! String, automatic: true)
        }
        hiddenGifIndicator(view: self.view)
    }
    
    func load_countries(){
        print("Carga de Paises")
        let array_parameter = ["": ""]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.GetPaises(parameters: parameter_json_string!, doneFunction: GetPaises)
    }
    
    func GetPaises(status: Int, response: AnyObject){
        var json = JSON(response)
        //debugPrint(json)
        let selected_name_country = Defaults[.academic_nbPais]!
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
            countryPickerView.selectRow((countries.count), inComponent:0, animated:true)
            

        }else{
            countries = []
            showMessage(title: response as! String, automatic: true)
        }
        countryPickerView.reloadAllComponents()
        // Establesco el Pais Seleccionado
         //"México"
        for i in 0 ..< countries.count{
            var item_country_json = JSON(countries[i])
            let name_country = item_country_json["nbPais"].stringValue
            self.name_country = name_country
            let isEqual = (selected_name_country == name_country)
            if isEqual {
                countryPickerView.selectRow(i, inComponent:0, animated:true)
            }
        }
        is_mexico_setup(name_country: selected_name_country)
        hiddenGifIndicator(view: self.view)
    }
    
    // Cargar Imagen
    @IBAction func import_image(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true){
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            img_profile.image = image
        }else{
            showMessage(title: "Error al cargar la imagen", automatic: true)
        }
        self.dismiss(animated: true, completion: upload_photo)


    }

    func upload_photo(){
        print("Subiendo Foto")
        let data = UIImageJPEGRepresentation(img_profile.image!, 0.5)
        webServiceController.upload_file(imageData:data, parameters: [:], doneFunction:upload_file)
    }
    
    func upload_file(status: Int, response: AnyObject){
         print("Imagen cargada con exito")
         print(response)
         let json = JSON(response)
         self.name_image = json["data"].stringValue
        
        if status == 1{
            toast(title:StringsLabel.upload_image)
        }else{
            toast(title: response as! String)
        }
    }
    
   
    
    @IBAction func on_click_continue(_ sender: Any) {
        print("Continuar")
        
        if validate_form() == 0 {
            let array_parameter = [
                "desCorreo": email_profile.text!,
                "Direcciones": [
                    "nbCiudad": city_profile.text!,
                    "numCodigoPostal":  cp_profile.text!,
                    "desDireccion": description_profile.text!,
                    "nbEstado": state_profile.text!,
                    "nbPais": name_country,
                    "nbMunicipio": municipio_profile.text!,
                    "idDireccion": Defaults[.academic_idDireccion]!
                ],
                "desTelefono": phone_profile.text!,
                "nbCompleto": name_profile.text!,
                "pathFoto": self.name_image,
                "idDireccion": Defaults[.academic_idDireccion]!,
                "idPersona": Defaults[.academic_idPersona]!
            ] as [String : Any]
        

            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.EditarPerfil(parameters: parameter_json_string!, doneFunction: EditarPerfil)
        }
    }
    
    func EditarPerfil(status: Int, response: AnyObject){
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
            showMessage(title: json["Mensaje"].stringValue, automatic: true)
            var data = JSON(json["Data"])
            let direcciones = JSON(data["Direcciones"])
            
            Defaults[.academic_name] = data["nbCompleto"].stringValue
            Defaults[.academic_email] = data["desCorreo"].stringValue
            Defaults[.academic_phone] = data["desTelefono"].stringValue
            Defaults[.academic_nbPais] = direcciones["nbPais"].stringValue
            Defaults[.academic_cp] = direcciones["numCodigoPostal"].stringValue
            Defaults[.academic_city] = direcciones["nbCiudad"].stringValue
            Defaults[.academic_municipio] = direcciones["nbMunicipio"].stringValue
            Defaults[.academic_state] = direcciones["nbEstado"].stringValue
            Defaults[.academic_description] = direcciones["desDireccion"].stringValue
            
            
            Defaults[.academic_pathFoto] = self.name_image
            if (self.type == "profile_representative"){
               //Defaults[.representative_pathFoto] = self.name_image
            }else{
              // Defaults[.academic_pathFoto] = self.name_image
            }
            
            print("Perfil Universitario")
            Timer.scheduledTimer(timeInterval: 5.4, target: self, selector: #selector(go_home), userInfo: nil, repeats: false)
            
        }else{
            showMessage(title: response as! String, automatic: true)
        }
        hiddenGifIndicator(view: self.view)
    }
    
    @objc func go_home(){
        if self.is_postulate == 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Main") as! MainViewController
            self.show(vc, sender: nil)
        }
        else{
            print("Back")
            _ = navigationController?.popViewController(animated: true)
        }
        
    }
    
    func get_data_profile(){
        name_profile.text = Defaults[.academic_name]
        phone_profile.text = Defaults[.academic_phone]
        email_profile.text = Defaults[.academic_email]
        
        // Direcciones
        cp_profile.text = Defaults[.academic_cp]
        city_profile.text = Defaults[.academic_city]
        municipio_profile.text = Defaults[.academic_municipio]
        state_profile.text = Defaults[.academic_state]
        description_profile.text = Defaults[.academic_description]

        
        set_photo_profile(url: Defaults[.academic_pathFoto]!, image: img_profile)
        
        if (self.type == "profile_representative"){
        //if (true){
            cp_profile.isHidden = true
            state_profile.isHidden = true
            municipio_profile.isHidden = true
            city_profile.isHidden = true
            
            countryConstraintHeight.constant = 0; topContraintDescription.constant = -260
            icon_country.isHidden = true
            
            countryPickerView.isHidden = true
            description_profile.isHidden = true
            
        }
    }
    
    func setup_ux(){
        self.img_profile.layer.masksToBounds = true
        self.img_profile.cornerRadius = 60
        self.import_image.layer.masksToBounds = true
        self.import_image.cornerRadius = 17.5
        
        if is_postulate == 0 {
            button_save.setTitle("Guardar cambios", for: .normal)
        }else{
            button_save.setTitle("Continuar", for: .normal)
            
        }
    }
    
    func setup_textfield(){
        name_profile.floatableDelegate = self
        phone_profile.floatableDelegate = self
        cp_profile.floatableDelegate = self
        description_profile.floatableDelegate = self
        city_profile.floatableDelegate = self
        municipio_profile.floatableDelegate = self
        email_profile.floatableDelegate = self
        state_profile.floatableDelegate = self
        
        // on_change_code_postal
        cp_profile.addTarget(self, action: #selector(ProfileAcademicViewController.cpDidChange(_:)), for: UIControlEvents.editingChanged)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        self.view.addGestureRecognizer(tap)
        
        email_profile.addTarget(self, action: #selector(ProfileAcademicViewController.emailDidChange(_:)), for: UIControlEvents.editingChanged)

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
            cp_profile.isHidden = true
            state_profile.isHidden = true
            municipio_profile.isHidden = true
            city_profile.isHidden = true
            topContraintDescription.constant = -260
            is_mexico = 0
            
            cp_profile.text = ""
            state_profile.text = ""
            municipio_profile.text = ""
            city_profile.text = ""
            
        }else{
            cp_profile.isHidden = false
            state_profile.isHidden = false
            municipio_profile.isHidden = false
            city_profile.isHidden = false
            
         
            
            topContraintDescription.constant = 0
            is_mexico = 1
        }
    }
    
    //Validar Formulario
    func validate_form()-> Int{
        
        var count_error:Int = 0
        
        //Nombre
        if FormValidate.isEmptyTextField(textField: name_profile){
            name_profile.setState(.FAILED, with: StringsLabel.required)
            count_error = count_error + 1
        }else{
            name_profile.setState(.DEFAULT, with: "")
        }
        
        //Telefono
        if FormValidate.isEmptyTextField(textField: phone_profile){
            phone_profile.setState(.FAILED, with: StringsLabel.phone_invalid)
            count_error = count_error + 1
        }else{
            if FormValidate.validatePhone(textField: phone_profile){
                phone_profile.setState(.FAILED, with: StringsLabel.phone_invalid)
                count_error = count_error + 1
            }else{
                phone_profile.setState(.DEFAULT, with: "")
            }
        }
 
        // Email
        if FormValidate.isEmptyTextField(textField: email_profile){
            email_profile.setState(.FAILED, with: StringsLabel.required)
            count_error = count_error + 1
        }else{
            if FormValidate.validateEmail(email_profile.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) == false {
                email_profile.setState(.FAILED, with: StringsLabel.email_invalid)
                count_error = count_error + 1
            }else{
                email_profile.setState(.DEFAULT, with: "")
            }
        }
        
        // CP
        if  is_mexico == 1{
            if FormValidate.isEmptyTextField(textField: cp_profile){
                cp_profile.setState(.FAILED, with: StringsLabel.required)
                count_error = count_error + 1
            }else{
                cp_profile.setState(.DEFAULT, with: "")
            }
        }
        
        return count_error
    }
    
    @objc(textField:shouldChangeCharactersIn:replacementString:) func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 {
            return true
        }
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        
        switch textField {
            case phone_profile:
                return newString.length <= 10
        case cp_profile:
            return newString.length <= 5
            default:
                return true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

}

extension ProfileAcademicViewController: RetryAccountViewControllerDelegate {
    func okButtonTapped() {
        print("OK BUtton")
        showGifIndicator(view: self.view)
        let array_parameter = [
            "desCorreo": email_profile.text!,
            "Dispositivos": [
                [
                    "cvDispositivo": Defaults[.cvDispositivo]!,
                    "cvFirebase": Defaults[.cvFirebase]!
                ]
            ]
            ] as [String : Any]
        
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.ActualizarCuentaUniversitario(parameters: parameter_json_string!, doneFunction: actualizarCuentaUniversitario)
    }
    
    func actualizarCuentaUniversitario(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        print("Guardo Datos")
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
            
            var data = JSON(json["Data"])
            let direcciones = JSON(data["Direcciones"])
            let list_dispositivos = data["Dispositivos"].arrayValue
            let dispositivo = JSON(list_dispositivos[0])
            
            Defaults[.academic_name] = data["nbCompleto"].stringValue
            Defaults[.academic_email] = data["desCorreo"].stringValue
            Defaults[.academic_phone] = data["desTelefono"].stringValue
            Defaults[.academic_nbPais] = direcciones["nbPais"].stringValue
            Defaults[.academic_cp] = direcciones["numCodigoPostal"].stringValue
            Defaults[.academic_city] = direcciones["nbCiudad"].stringValue
            Defaults[.academic_municipio] = direcciones["nbMunicipio"].stringValue
            Defaults[.academic_state] = direcciones["nbEstado"].stringValue
            Defaults[.academic_description] = direcciones["desDireccion"].stringValue
            
            Defaults[.academic_idPersona] = data["idPersona"].intValue
            Defaults[.academic_idDireccion] = direcciones["idDireccion"].intValue
            Defaults[.academic_idDireccion] = dispositivo["idDispositivo"].intValue
            
            print("Back")
            _ = navigationController?.popViewController(animated: true)
        }else{
            showMessage(title: response as! String, automatic: true)
        }
        
    }

    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
    }
}
