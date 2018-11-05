//
//  ViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 18/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import SwiftyJSON
import FloatableTextField
import FacebookLogin
import FBSDKLoginKit
import Firebase
import SwiftyUserDefaults


class LoginViewController: BaseViewController, FloatableTextFieldDelegate {

    @IBOutlet weak var email: FloatableTextField!
    @IBOutlet weak var password: FloatableTextField!
    @IBOutlet weak var btnForget: UILabel!
    @IBOutlet weak var btnHere: UILabel!
    @IBOutlet weak var btnRegister: UILabel!
    @IBOutlet var button_facaebook: UIButton!
    
    var webServiceController = WebServiceController()
    var dict : [String : AnyObject]!
    
    
    // Variables para manejar Facebook
    var is_click_facebook = 0
    var facebook_name = ""
    var facebook_email = ""
    var facebook_id = ""
    var facebook_url = ""

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_uicontrols()
        
        
        Defaults[.cvDispositivo] = UIDevice.current.identifierForVendor!.uuidString
        print("Firebase Login: \(Defaults[.cvFirebase]!)")
       
        // End Facebook
        // var image_facebook = UIImage(named: "icon_face_white")
        //button_facaebook.imageEdgeInsets = UIEdgeInsets(top: 5, left: (button_facaebook.bounds.width - 35), bottom: 5, right: 5)
        //button_facaebook.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (image_facebook?.frame.width)!)
        
        // Llamada a Firebase
        
        
        // Forget Event
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.on_click_forget))
        btnForget.isUserInteractionEnabled = true
        btnForget.addGestureRecognizer(tap)
        
        // Here Event
        let tap_here = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.on_click_here))
        btnHere.isUserInteractionEnabled = true
        btnHere.addGestureRecognizer(tap_here)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        email.text = ""
        password.text = ""
        
        
        let loginManager = LoginManager()
        
        loginManager.logOut()
        //loginManager.
    }
    override func viewDidAppear(_ animated: Bool) {
        setup_ux()
    }
    
   
    // On_click_facebook
    @IBAction func on_click_facebook(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                self.getFBUserData()
            }
        }
    }
    
    func setup_uicontrols(){
        email.floatableDelegate = self
        password.floatableDelegate = self
    }

    @IBAction func on_click_login(_ sender: Any) {
        login_universidad(type:"normal")
        is_click_facebook = 0
    }
    
    func login_universidad(type:String){
        
        if validate_form() == 0 {
            showGifIndicator(view: self.view)
           
            var array_parameter_new:[String : Any]
            
            if  type == "normal"{
                array_parameter_new = [
                    "pwdContrasenia": password.text!,
                    "Personas": [
                        "Dispositivos": [
                            [
                                "cvDispositivo": Defaults[.cvDispositivo]!,
                                "cvFirebase":Defaults[.cvFirebase]!,
                                "idDispositivo": 0
                            ]
                        ],
                        "idDireccion": 0,
                        "idPersona": 0
                    ],
                    "nbUsuario": email.text!,
                    "idUsuario": 0
                    ] as [String : Any]
            }else{
                
                array_parameter_new = [
                    "cvFacebook": password.text!,
                    "pwdContrasenia": "",
                    "Personas": [
                        "Dispositivos": [
                            [
                                "cvDispositivo": Defaults[.cvDispositivo]!,
                                "cvFirebase":Defaults[.cvFirebase]!,
                                "idDispositivo": 0
                            ]
                        ],
                        "idDireccion": 0,
                        "idPersona": 0
                    ],
                    "nbUsuario": email.text!,
                    "idUsuario": 0
                    ] as [String : Any]
            }
            
            debugPrint(array_parameter_new)
            
            let parameter_json = JSON(array_parameter_new)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.IngresarAppUniversidad(parameters: parameter_json_string!, doneFunction: IngresarAppUniversidad)
        }
    }

    func IngresarAppUniversidad(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        debugPrint(response)
        if status == 1{
            
            var json = JSON(response)
            let data = JSON(json["Data"])
            print("Ingresar App Universidad")
            
            let personas = JSON(data["Personas"])
            let universidades_list = personas["Universidades"].array
            let universidades = JSON(universidades_list![0])
            let paquete_list = JSON(universidades["VentasPaquetes"])
            let paquete = JSON(paquete_list[0])
            let direccion_uni = JSON(universidades["Direcciones"])
            let direccion_rep = JSON(personas["Direcciones"])
            let dispositivos_array = personas["Dispositivos"].arrayValue

            
            setSettings(key: "profile_menu", value: "profile_university")
            Defaults[.type_user] = 2

            //Dispostivo

            Defaults[.idDispositivo] = 0
            if dispositivos_array.count > 0{
                var dispositivo = JSON(dispositivos_array[0])
                Defaults[.idDispositivo] = dispositivo["idDispositivo"].intValue
            }
            
            //Paquete
            Defaults[.package_idUniveridad] = paquete["idUniversidad"].intValue
            Defaults[.package_idPaquete] = paquete["idPaquete"].intValue

            Defaults[.package_feVenta] = paquete["feVenta"].stringValue
            Defaults[.package_feVigencia] = paquete["feVigencia"].stringValue

            

            
            //Universidad
            Defaults[.university_idUniveridad] = universidades["idUniversidad"].intValue
            Defaults[.university_pathLogo] = universidades["pathLogo"].stringValue
            Defaults[.university_nbUniversidad] = universidades["nbUniversidad"].stringValue
            Defaults[.university_nbReprecentante] = universidades["nbReprecentante"].stringValue
            Defaults[.university_desUniversidad] = universidades["desUniversidad"].stringValue
            Defaults[.university_desSitioWeb] = universidades["desSitioWeb"].stringValue
            Defaults[.university_desTelefono] = universidades["desTelefono"].stringValue
            Defaults[.university_desCorreo] = universidades["desCorreo"].stringValue
            Defaults[.university_idPersona] = universidades["idPersona"].intValue            
            
            // Direccion Universidad
            Defaults[.add_uni_idUniversidad] = direccion_uni["idUniversidad"].intValue
            Defaults[.add_uni_idDireccion] = direccion_uni["idDireccion"].intValue

            
            Defaults[.add_uni_desDireccion] = direccion_uni["desDireccion"].stringValue
            Defaults[.add_uni_numCodigoPostal] = direccion_uni["numCodigoPostal"].stringValue
            Defaults[.add_uni_nbPais] = direccion_uni["nbPais"].stringValue
            Defaults[.add_uni_nbEstado] = direccion_uni["nbEstado"].stringValue
            Defaults[.add_uni_nbMunicipio] = direccion_uni["nbMunicipio"].stringValue
            Defaults[.add_uni_nbCiudad] = direccion_uni["nbCiudad"].stringValue
            Defaults[.add_uni_dcLatitud] = direccion_uni["dcLatitud"].doubleValue
            Defaults[.add_uni_dcLongitud] = direccion_uni["dcLongitud"].doubleValue

            // Representante
            Defaults[.academic_idPersona] = personas["idPersona"].intValue
            Defaults[.academic_idDireccion] = direccion_rep["idDireccion"].intValue

            Defaults[.academic_name] = personas["nbCompleto"].stringValue
            Defaults[.academic_email] = personas["desCorreo"].stringValue
            Defaults[.academic_phone] =  personas["desTelefono"].stringValue
            Defaults[.academic_pathFoto] = personas["pathFoto"].stringValue

            Defaults[.academic_nbPais] = direccion_rep["nbPais"].stringValue
            Defaults[.academic_cp] = direccion_rep["numCodigoPostal"].stringValue
            Defaults[.academic_city] = direccion_rep["nbCiudad"].stringValue
            Defaults[.academic_municipio] = direccion_rep["nbMunicipio"].stringValue
            Defaults[.academic_state] = direccion_rep["nbEstado"].stringValue
            Defaults[.academic_description] =  direccion_rep["desDireccion"].stringValue
            Defaults[.academic_dcLatitud] = direccion_rep["dcLatitud"].stringValue
            Defaults[.academic_dcLongitud] = direccion_rep["dcLongitud"].stringValue

            performSegue(withIdentifier: "showSplash", sender: self)
        }else{
            if  is_click_facebook == 1{
                print("Registro Login Incorrecto")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewControllerID") as! RegisterViewController
                vc.facebook_name = self.facebook_name
                vc.facebook_email = self.facebook_email
                vc.facebook_id = self.facebook_id
                vc.facebook_url = self.facebook_url
                vc.is_facebook = 1
                self.show(vc, sender: nil)
            }
            else{
                //showMessage(title: response as! String, automatic: true)
                updateAlert(title: "", message: response as! String, automatic: true)
            }
            
        }
    }
    // On_click_Here(AQUI)
    @objc func on_click_here(sender:UITapGestureRecognizer) {
        print("on_click_aqui")
        
        let array_parameter = [
            "cvFirebase": Defaults[.cvFirebase]!,
            "cvDispositivo": Defaults[.cvDispositivo]!,
            "idDispositivo": 0
            ] as [String : Any]
        
        debugPrint(array_parameter)
        
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.IngresarUniversitario(parameters: parameter_json_string!, doneFunction: IngresarUniversitario)
    }
    
    // Callback - On_click_Here(AQUI)
    func IngresarUniversitario(status: Int, response: AnyObject){
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
            let data_json = JSON(json["Data"])
            
            //Config
            setSettings(key: "profile_menu", value: "profile_academic")
            
            let persona_json = JSON(data_json["Personas"])
            let direcciones = JSON(persona_json["Direcciones"])
            
            
            var nbCompleto = persona_json["nbCompleto"].stringValue
            var desCorreo = persona_json["desCorreo"].stringValue
            var desTelefono = persona_json["desTelefono"].stringValue
            if nbCompleto == "temp" {
                nbCompleto = ""
                desTelefono = ""
            }
            
            if desCorreo == "temp@email.com" {
                desCorreo = ""
            }
            Defaults[.type_user] = 1
            Defaults[.academic_idPersona] = persona_json["idPersona"].intValue
            Defaults[.academic_idDireccion] = direcciones["idDireccion"].intValue


            Defaults[.academic_name] = nbCompleto
            Defaults[.academic_email] = desCorreo
            Defaults[.academic_phone] = desTelefono
            Defaults[.academic_nbPais] = direcciones["nbPais"].stringValue
            Defaults[.academic_cp] = direcciones["numCodigoPostal"].stringValue
            Defaults[.academic_city] = direcciones["nbCiudad"].stringValue
            Defaults[.academic_municipio] = direcciones["nbMunicipio"].stringValue
            Defaults[.academic_state] = direcciones["nbEstado"].stringValue
            Defaults[.academic_description] =  direcciones["desDireccion"].stringValue
            
            _ = self.navigationController?.popToRootViewController(animated: false)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Navigation_MainViewController") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = vc
        }else{
           updateAlert(title: "Error", message: response as! String, automatic: true)
        }
        
    }
    
    @objc func on_click_forget(sender:UITapGestureRecognizer) {
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "ForgetViewControllerID") as! ForgetViewController
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
     }

    func setup_ux(){
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController!.navigationBar.topItem!.title = ""
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func validate_form()-> Int{
        
        var count_error:Int = 0
        if FormValidate.isEmptyTextField(textField: email){
            //email.setState(.FAILED, with: StringsLabel.required)
            updateAlert(title: "Correo electrónico", message: StringsLabel.required, automatic: true)
            count_error = count_error + 1
            return count_error
        }else{
            if FormValidate.validateEmail(email.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) == false {
                //email.setState(.FAILED, with: StringsLabel.email_invalid)
                updateAlert(title: "Correo electrónico", message: StringsLabel.email_invalid, automatic: true)
                count_error = count_error + 1
                return count_error
            }else{
                email.setState(.DEFAULT, with: "")
            }
        }
        
        if FormValidate.isEmptyTextField(textField: password){
            //email.setState(.FAILED, with: StringsLabel.required)
            updateAlert(title: "Contraseña", message: StringsLabel.required, automatic: true)
            count_error = count_error + 1
            return count_error
        }else{
            email.setState(.DEFAULT, with: "")
        }
        
        return count_error
    }
    
    //function is fetching the user data
    func getFBUserData(){

        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    print(result!)
                    print(self.dict)
                    
                    var picture = self.dict["picture"] as! [String : AnyObject]
                    var data = picture["data"] as! [String : AnyObject]
                    let url = data["url"] as! String
                    self.password.text = (self.dict["id"] as! String)
                    
                    let keyExistsEmail = self.dict["email"] != nil
                    let keyExistsName = self.dict["name"] != nil
                    
                    
                    self.facebook_id = self.dict["id"] as! String
                    self.facebook_url = url
                    self.is_click_facebook = 1
                    
                    var email = ""
                    if (keyExistsEmail){
                        email = (self.dict["email"] as? String)!
                    }
                    
                    var name = ""
                    if (keyExistsName){
                        name = self.dict["name"] as! String
                    }
                    
                    if (keyExistsEmail && keyExistsName){
                        self.email.text = email
                        self.facebook_email = email
                        self.facebook_name = name
                        
              
                    
                        
                        self.login_universidad(type:"facebook")
                    }
                    else{
                        print("Registro Falta de Datos")
                        print("name: \(name)")
                        print("email: \(email)" )
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewControllerID") as! RegisterViewController
                        vc.facebook_name = name
                        vc.facebook_email = email
                        
                        vc.facebook_id = self.facebook_id
                        vc.facebook_url = self.facebook_url
                        vc.is_facebook = 1
                        
                        self.show(vc, sender: nil)
                    }
                }
            })
        }
    }
}

extension LoginViewController: ForgetViewControllerDelegate {
    func okButtonTapped(textFieldValue: String) {
        let array_parameter = ["nbUsuario": textFieldValue]
        if FormValidate.validateEmail(textFieldValue){
            showGifIndicator(view: self.view)
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.RecuperarContrasenia(parameters: parameter_json_string!, doneFunction: RecuperarContrasenia)
        }else{
            showMessage(title: StringsLabel.email_invalid, automatic: true)
        }
    }
    
    func RecuperarContrasenia(status: Int, response: AnyObject){
        let json = JSON(response)
        if status == 1{
            showMessage(title: json["Mensaje"].stringValue, automatic: true)
        }else{
           showMessage(title: response as! String, automatic: true)
        }
        hiddenGifIndicator(view: self.view)
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
    }
}

