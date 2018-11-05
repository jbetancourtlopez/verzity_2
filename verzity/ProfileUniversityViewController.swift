//
//  ProfileUniversityViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 09/07/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftyUserDefaults

class ProfileUniversityViewController: BaseViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet var import_image: UIButton!
    @IBOutlet var img_profile: UIImageView!
    @IBOutlet var button_back: UIButton!
    @IBOutlet var button_next: UIButton!
    
    var state_form = "first"
    var container : ContainerViewController!
    var name_image = ""
    
    var data_form = NSMutableDictionary()
    var webServiceController = WebServiceController()
    var present_count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update_button()
        setup_ux()
        set_data()
        setup_back_button()
        print("viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        update_button()
        
    }

    func setup_back_button(){
        let image = UIImage(named: "back")?.withRenderingMode(.alwaysOriginal)
        
        
        let button_back = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(on_click_back))
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "back"), for: .normal)
        button.setTitle("Inicio", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(on_click_back), for: .touchUpInside)

        
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = button_back
    }

    @objc func on_click_back(sender: AnyObject) {
            _ = self.navigationController?.popToRootViewController(animated: false)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Navigation_MainViewController") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = vc
    }

    func set_data(){
        set_photo_profile(url: Defaults[.university_pathLogo]!, image: img_profile)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        //update_button()
        //self.present_count += self.present_count + 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         print("viewWillDisappear")
        self.present_count += self.present_count + 1
        update_button()
        
       // let secondVC = self.container.currentViewController as? SecondFormViewController
       // container.segueIdentifierReceivedFromParent("second")
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
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            img_profile.image = image
        }else{
            showMessage(title: "Error al cargar la imagen", automatic: true)
        }
        self.dismiss(animated: true, completion: upload_photo)
    }


    func upload_photo(){
        print("Subiendo Foto")
        let data = UIImageJPEGRepresentation(img_profile.image!, 1.0)
        webServiceController.upload_file(imageData:data, parameters: [:], doneFunction:upload_file)
    }
    
    func upload_file(status: Int, response: AnyObject){
         print("Imagen cargada con exito")

        print(response)
        let json = JSON(response)
        print(json["data"].stringValue)
        self.name_image = json["data"].stringValue

        if status == 1{
            toast(title:StringsLabel.upload_image)
        }else{
            toast(title: response as! String)
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "container"{
            self.container = segue.destination as! ContainerViewController
        }
    }
    
    @IBAction func on_click_next_save(_ sender: Any) {
        print("next")
        next()
        update_button()
    }
    
    func next(){
        let firstVC = self.container.currentViewController as? FirstFormViewController
        let secondVC = self.container.currentViewController as? SecondFormViewController
        
        if self.state_form == "first"{
            let validate_form_first = firstVC?.validate_form()
            if  validate_form_first == 0{
                
                data_form["first_name_university"] = firstVC?.first_name_university.text
                data_form["first_description"] = firstVC?.first_description.text
                data_form["first_web"]  = firstVC?.first_web.text
                data_form["first_phone"] = firstVC?.first_phone.text
                data_form["first_email"] = firstVC?.first_email.text
                
                container.segueIdentifierReceivedFromParent("second")
                state_form = "second"
            }
            
        }else if self.state_form == "second" {
            
            let validate_form_second = secondVC?.validate_form()
            if  validate_form_second == 0{
                
                data_form["second_cp"] = secondVC?.second_cp.text
                data_form["second_state"] = secondVC?.second_state.text
                data_form["second_municipio"] = secondVC?.second_municipio.text
                data_form["second_city"] = secondVC?.second_city.text
                data_form["second_description"] = secondVC?.second_description.text
                data_form["second_location"] = secondVC?.second_location.text
                data_form["second_pais"] = secondVC?.name_country
                data_form["latitud"] = secondVC?.latitud
                data_form["longitud"] = secondVC?.longitud
                
                save_data()
            }
        }
    }
    
    func save_data(){
        print(self.name_image)
        debugPrint(data_form)
        print("Guardar Datos")
        showGifIndicator(view: self.view)
        
        let array_parameter = [
            "desCorreo": data_form["first_email"]!,
            "desUniversidad": data_form["first_description"]!,
            "idUniversidad": Defaults[.university_idUniveridad]!,
            "idDireccion": Defaults[.add_uni_idDireccion]!,
            "pathLogo": self.name_image,
            "Direcciones": [
                "nbCiudad": data_form["second_city"],
                "numCodigoPostal": data_form["second_cp"],
                "desDireccion": data_form["second_description"],
                "nbEstado": data_form["second_state"],
                "idDireccion": Defaults[.add_uni_idDireccion]!,
                "nbMunicipio": data_form["second_municipio"],
                "nbPais": data_form["second_pais"],
                "dcLatitud": data_form["latitud"] ,
                "dcLongitud": data_form["longitud"],
            ],
            "nbUniversidad": data_form["first_name_university"]!,
            "desSitioWeb": data_form["first_web"]!,
            "desTelefono": data_form["first_phone"]!
            ] as [String : Any]
        
        debugPrint(array_parameter)
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.RegistrarUniversidad(parameters: parameter_json_string!, doneFunction: RegistrarUniversidad)
        
    }
    
    func RegistrarUniversidad(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        let json = JSON(response)
        print("Respuestas")
        print(json)
        if status == 1{
             showMessage(title: json["Mensaje"].stringValue, automatic: true)
            // Guardo en Session los datos que devuelve
            
            var data = JSON(json["Data"])
            var direccion = JSON(data["Direcciones"])
           
            Defaults[.university_pathLogo] = self.name_image
            
            //Universidad
            Defaults[.university_idUniveridad] = data["idUniversidad"].intValue
            Defaults[.university_pathLogo] =  data["pathLogo"].stringValue
            Defaults[.university_nbUniversidad] =  data["nbUniversidad"].stringValue
            Defaults[.university_nbReprecentante] =  data["nbReprecentante"].stringValue
            Defaults[.university_desUniversidad] =  data["desUniversidad"].stringValue
            Defaults[.university_desSitioWeb] = data["desSitioWeb"].stringValue
            Defaults[.university_desTelefono] =  data["desTelefono"].stringValue
            Defaults[.university_desCorreo] =  data["desCorreo"].stringValue
            Defaults[.university_idPersona] = data["idPersona"].intValue
            
            
            // Direccion Universidad
            Defaults[.add_uni_idUniversidad] = direccion["idDireccion"].intValue
            Defaults[.add_uni_desDireccion] = direccion["desDireccion"].stringValue
            Defaults[.add_uni_numCodigoPostal] = direccion["numCodigoPostal"].stringValue
            Defaults[.add_uni_nbPais] = direccion["nbPais"].stringValue
            Defaults[.add_uni_nbEstado] = direccion["nbEstado"].stringValue
            Defaults[.add_uni_nbMunicipio] = direccion["nbMunicipio"].stringValue
            Defaults[.add_uni_nbCiudad] = direccion["nbCiudad"].stringValue
            Defaults[.add_uni_dcLatitud] = direccion["dcLatitud"].doubleValue
            Defaults[.add_uni_dcLongitud] = direccion["dcLongitud"].doubleValue
            
            Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(go_home), userInfo: nil, repeats: false)

            
        }else {
            showMessage(title: response as! String, automatic: true)
        }
        
    }
    
    
    @objc func go_home(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "Main") as! MainViewController
        self.show(vc, sender: nil)
    }
    
    
    @IBAction func on_click_back(_ sender: Any) {
        container.segueIdentifierReceivedFromParent("first")
        var controller = container.currentViewController as! FirstFormViewController
        state_form = "first"
        update_button()
    }
   
    func update_button(){
        
        print("update button \(present_count)")
        
        if  present_count > 0{
            self.state_form = "first"
        }
       
        
        if  self.state_form == "first" {
            self.present_count = 0
            button_back.isHidden = true
            button_next.setTitle("SIGUIENTE", for: .normal)
        }else if self.state_form == "second" {
            
            button_back.isHidden = false
            button_next.setTitle("GUARDAR CAMBIOS", for: .normal)
        }
    }
    
    func setup_ux(){
        self.img_profile.layer.masksToBounds = true
        self.img_profile.cornerRadius = 60
        self.import_image.layer.masksToBounds = true
        self.import_image.cornerRadius = 17.5
    }
}


