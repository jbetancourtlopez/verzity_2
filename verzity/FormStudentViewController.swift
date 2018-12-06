import UIKit
import FloatableTextField
import SwiftyJSON
import SwiftyUserDefaults

// (file:///Users/jossuebetancourt/Library/Developer/CoreSimulator/Devices/6E39B2FD-5A27-4C9A-B4AC-D9C07A128C2A/data/Containers/Data/Application/AD092B87-9D82-4420-8147-10916767CBA8/Documents/default.realm)


class FormStudentViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, FloatableTextFieldDelegate{
    
    @IBOutlet var scrollView: UIScrollView!

    // Image
    @IBOutlet var img_profile: UIImageView!
    @IBOutlet var import_image: UIButton!

    @IBOutlet var countryPickerView: UIPickerView!
    @IBOutlet var icon_country: UIImageView!
    @IBOutlet var name: FloatableTextField!
    @IBOutlet var phone: FloatableTextField!
    @IBOutlet var cp: FloatableTextField!
    @IBOutlet var city: FloatableTextField!
    @IBOutlet var municipio: FloatableTextField!
    @IBOutlet var state: FloatableTextField!
    @IBOutlet var address: FloatableTextField!
    @IBOutlet var email: FloatableTextField!
    @IBOutlet var password: FloatableTextField!
    @IBOutlet var password_confirm: FloatableTextField!
    
    @IBOutlet var swich_accept: UISwitch!
    @IBOutlet var accept_error: UILabel!
    @IBOutlet var button_save: UIButton!

    //View
    @IBOutlet weak var view_cp: UIView!
    @IBOutlet weak var view_municipio: UIView!
    @IBOutlet weak var view_ciudad: UIView!
    @IBOutlet weak var view_direccion: UIView!
    @IBOutlet weak var view_state: UIView!
    @IBOutlet weak var view_cp_ct_height: NSLayoutConstraint!
    
    @IBOutlet weak var view_password: UIView!
    @IBOutlet weak var view_password_conf: UIView!
    
    // Constrain
    @IBOutlet var cp_constraint_height: NSLayoutConstraint!
    @IBOutlet var municipio_contraint_height: NSLayoutConstraint!
    @IBOutlet var city_constraint_height: NSLayoutConstraint!
    @IBOutlet var state_constraint_height: NSLayoutConstraint!
    
    // Variables
    var webServiceController = WebServiceController()
    var countries: NSArray = []
    var is_mexico = 1;
    var name_country = ""
    var type_view: String = "register"
    
    // Datos obtenidos de facebook
    var facebook_url: String = ""
    var facebook_name: String = ""
    var facebook_email: String = ""
    var facebook_id: String = ""
    var is_facebook:Int = 0

    var name_image = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.type_view = type_view as String
        setup_ux()
        setup_textfield()
        load_countries()
        

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        self.view.addGestureRecognizer(tap)
        
        registerForKeyboardNotifications(scrollView: scrollView)
        setGestureRecognizerHiddenKeyboard()
        
        print("Facebook_id: \(facebook_id)")
        if is_facebook == 1 {
            print("Entro Facebook")
            setdata_facebook()
        }
    }
    
    func setdata_facebook(){

        name.text = self.facebook_name
        email.text = self.facebook_email
        
        // Foto Profile
        let url = self.facebook_url
        let URL = Foundation.URL(string: url)
        let image_default = UIImage(named: "ic_user_profile.png")
        img_profile.kf.setImage(with: URL, placeholder: image_default)
        if is_facebook == 1{
            
            email.isEnabled = false
            email.textColor = hexStringToUIColor(hex: "#939393")
            view_password.isHidden = true
            view_password_conf.isHidden = true
            
            if  (self.facebook_email.isEmpty){
                email.isEnabled = true
            }
    
        }
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(upload_photo), userInfo: nil, repeats: false)
    }

    
    @objc func cpDidChange(_ textField: UITextField) {
        let cp = textField.text
        if (cp?.count)! >= 5{
            showGifIndicator(view: self.view)
            let array_parameter = ["Cp_CodigoPostal": cp]
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.get(parameters: parameter_json_string!, method: Singleton.BuscarCodigoPostal, doneFunction: BuscarCodigoPostal)
        }
    }
    
    @objc func emailDidChange(_ textField: UITextField) {
      
        if !FormValidate.isEmptyTextField(textField: email){
            if !FormValidate.validateEmail(email.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) == false {
                print("Email Valido")
                //showGifIndicator(view: self.view)
                let array_parameter = [
                    "desCorreo": email.text!,
                    "Dispositivos": [
                        [
                        "cvDispositivo": "",
                        "cvFirebase": "",
                        ]
                    ]
                ] as [String : Any]

                let parameter_json = JSON(array_parameter)
                let parameter_json_string = parameter_json.rawString()
                //webServiceController.verificarCuentaUniversitario(parameters: parameter_json_string!, doneFunction: verificarCuentaUniversitario)
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
        customAlert.delegate = self as! RetryAccountViewControllerDelegate
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
                city.text = item_cp["Cp_Ciudad"].stringValue
                municipio.text = item_cp["Cp_Municipio"].stringValue
                state.text = item_cp["Cp_Estado"].stringValue
            }else{
                city.text = ""
                municipio.text =  ""
                state.text = ""
            }
        }else{
            showMessage(title: response as! String, automatic: true)
        }
        hiddenGifIndicator(view: self.view)
    }
    
    func load_countries(){
        let array_parameter = ["": ""]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method:Singleton.GetPaises, doneFunction: callback_load_countries)
    }
    
    func callback_load_countries(status: Int, response: AnyObject){
        var json = JSON(response)
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
    
    @IBAction func on_click_continue(_ sender: Any) {
        print("Continuar")
        if validate_form() == 0 {
            let array_parameter = [
                "pwdContrasenia": password.text!,
                "cvFacebook": self.facebook_id,
                "idUsuario": 0,
                "nbUsuario": email.text!,
                "Personas": [
                    "desCorreo": email.text,
                    "Direcciones": [
                        "nbCiudad": city.text!,
                        "numCodigoPostal":  cp.text!,
                        "desDireccion": address.text!,
                        "nbEstado": state.text!,
                        "nbPais": name_country,
                        "nbMunicipio": municipio.text!,
                        "idDireccion": 0
                    ],
                    "Dispositivos": [
                        [
                            "cvDispositivo": Defaults[.cvDispositivo]!,
                            "cvFirebase": Defaults[.cvFirebase]!,
                            "idDispositivo": 0
                        ]
                    ],
                    "desTelefono": phone.text!,
                    "nbCompleto": name.text!,
                    "pathFoto": self.name_image,
                    "idDireccion": 0,
                    "idPersona": 0
                ]

            ] as [String : Any]
            
            print(array_parameter)
            
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.get(parameters: parameter_json_string!, method:Singleton.CrearCuentaAccesoUniversitario, doneFunction: callback_on_click_continue)
        }
    }
    
    func callback_on_click_continue(status: Int, response: AnyObject){
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
            let data = JSON(json["Data"])
            save_profile(data:data)
            performSegue(withIdentifier: "showSplash", sender: self)
        }else{
            showMessage(title: response as! String, automatic: true)
        }
        hiddenGifIndicator(view: self.view)
    }
    
    @objc func go_home(){
        if self.type_view == "register" {
            _ = self.navigationController?.popToRootViewController(animated: false)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Navigation_StudentViewController") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = vc
        } else if self.type_view == "edit"{
            _ = navigationController?.popViewController(animated: true)
        }
        
    }
    
    func get_data_profile(){
        name.text = Defaults[.academic_name]
        phone.text = Defaults[.academic_phone]
        email.text = Defaults[.academic_email]
        
        // Direcciones
        cp.text = Defaults[.academic_cp]
        city.text = Defaults[.academic_city]
        municipio.text = Defaults[.academic_municipio]
        state.text = Defaults[.academic_state]
        address.text = Defaults[.academic_description]

        
        set_photo_profile(url: Defaults[.academic_pathFoto]!, image: img_profile)
        


    }
    
    func is_mexico_setup(name_country: String){
        
        if  name_country != "México" {
            
            // Hidden View
            view_cp.isHidden = true
            view_municipio.isHidden = true
            view_ciudad.isHidden = true
            view_state.isHidden = true

            is_mexico = 0
            
            cp.text = ""
            state.text = ""
            municipio.text = ""
            city.text = ""
            
        }else{
            view_cp.isHidden = false
            view_municipio.isHidden = false
            view_ciudad.isHidden = false
            view_state.isHidden = false
            
            is_mexico = 1
        }
    }
    
    func setup_ux(){
        
        self.navigationItem.title = "Registro"
        
        self.navigationController?.isNavigationBarHidden = false
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationController?.navigationBar.backItem?.backBarButtonItem = backItem
        
        self.img_profile.layer.masksToBounds = true
        self.img_profile.cornerRadius = 60
        self.import_image.layer.masksToBounds = true
        self.import_image.cornerRadius = 17.5
        
        button_save.setTitle("Guardar cambios", for: .normal)
       self.swich_accept.setOn(false, animated: false)
    }
    
    func setup_textfield(){
        name.floatableDelegate = self
        phone.floatableDelegate = self
        cp.floatableDelegate = self
        address.floatableDelegate = self
        city.floatableDelegate = self
        municipio.floatableDelegate = self
        email.floatableDelegate = self
        state.floatableDelegate = self
        
        
        self.state.isEnabled = false
        self.municipio.isEnabled = false
        self.city.isEnabled = false
        
        self.state.textColor = hexStringToUIColor(hex: "#939393")
        self.municipio.textColor = hexStringToUIColor(hex: "#939393")
        self.city.textColor = hexStringToUIColor(hex: "#939393")
        
        // on_change_code_postal
        cp.addTarget(self, action: #selector(ProfileAcademicViewController.cpDidChange(_:)), for: UIControlEvents.editingChanged)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        self.view.addGestureRecognizer(tap)
        
        email.addTarget(self, action: #selector(ProfileAcademicViewController.emailDidChange(_:)), for: UIControlEvents.editingChanged)

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
    
    // Inicio Foto
    @IBAction func import_image(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true){ }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            img_profile.image = image
        }else{
            showMessage(title: "Error al cargar la imagen", automatic: true)
        }
        self.dismiss(animated: true, completion: upload_photo)
    }
    
     @objc func upload_photo(){
        print("Subiendo Foto")
        let data = UIImageJPEGRepresentation(img_profile.image!, 0.5)
        webServiceController.upload_file(imageData:data, parameters: [:], doneFunction:upload_file)
    }
    
    func upload_file(status: Int, response: AnyObject){
        print("Imagen cargada con exito")
        let json = JSON(response)
        self.name_image = json["data"].stringValue
        
        if status == 1{
            toast(title:StringsLabel.upload_image)
        }else{
            toast(title: response as! String)
        }
    }
    
    
    //Validar Formulario
    func validate_form()-> Int{
        
        var count_error:Int = 0
        
        //Nombre
        if FormValidate.isEmptyTextField(textField: name){
            name.setState(.FAILED, with: StringsLabel.required)
            count_error = count_error + 1
        }else{
            name.setState(.DEFAULT, with: "")
        }
        
        //Telefono
        if FormValidate.isEmptyTextField(textField: phone){
            phone.setState(.FAILED, with: StringsLabel.phone_invalid)
            count_error = count_error + 1
        }else{
            if FormValidate.validatePhone(textField: phone){
                phone.setState(.FAILED, with: StringsLabel.phone_invalid)
                count_error = count_error + 1
            }else{
                phone.setState(.DEFAULT, with: "")
            }
        }
 
        // Email
        if FormValidate.isEmptyTextField(textField: email){
            email.setState(.FAILED, with: StringsLabel.required)
            count_error = count_error + 1
        }else{
            if FormValidate.validateEmail(email.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) == false {
                email.setState(.FAILED, with: StringsLabel.email_invalid)
                count_error = count_error + 1
            }else{
                email.setState(.DEFAULT, with: "")
            }
        }
        
        // CP
        if  is_mexico == 1{
            if FormValidate.isEmptyTextField(textField: cp){
                cp.setState(.FAILED, with: StringsLabel.required)
                count_error = count_error + 1
            }else{
                cp.setState(.DEFAULT, with: "")
            }
        }
        
        if is_facebook == 0 {
            if FormValidate.isEmptyTextField(textField: password){
                password.setState(.FAILED, with: StringsLabel.required)
                count_error = count_error + 1
            }else{
                
                if FormValidate.validate_min_length(password, maxLength: 8){
                    if password.text != password_confirm.text{
                        password_confirm.setState(.FAILED, with: StringsLabel.password_coinciden_invalid)
                        count_error = count_error + 1
                    }else{
                        password_confirm.setState(.DEFAULT, with: "")
                        password.setState(.DEFAULT, with: "")
                    }
                }else{
                    password.setState(.FAILED, with: StringsLabel.password_invalid)
                    count_error = count_error + 1
                }
                
            }
        }
        
        
        if  !swich_accept.isOn {
            count_error = count_error + 1
            accept_error.isHidden = false
            accept_error.text = StringsLabel.acept_invalid
        }else{
            accept_error.isHidden = true
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
            case phone:
                return newString.length <= 10
        case cp:
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

extension FormStudentViewController: RetryAccountViewControllerDelegate {
    func okButtonTapped() {
        print("OK BUtton")
        showGifIndicator(view: self.view)
        let array_parameter = [
            "desCorreo": email.text!,
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
    
    func cancelButtonTapped() { }
}
