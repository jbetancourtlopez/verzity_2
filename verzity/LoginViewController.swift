import UIKit
import SwiftyJSON
import RealmSwift
import FloatableTextField
import FacebookLogin
import FBSDKLoginKit
import Firebase
import SwiftyUserDefaults


class LoginViewController: BaseViewController, FloatableTextFieldDelegate {
    
    // Inputs
    @IBOutlet weak var email: FloatableTextField!
    @IBOutlet weak var password: FloatableTextField!
    @IBOutlet weak var btnForget: UILabel!
    @IBOutlet var view_facebook: UIView!
    
    // Variables
    var webServiceController = WebServiceController()
    var dict : [String : AnyObject]!
    var is_click_facebook = 0
    var facebook_name = ""
    var facebook_email = ""
    var facebook_id = ""
    var facebook_url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        Defaults[.cvDispositivo] = UIDevice.current.identifierForVendor!.uuidString

        // Forget Event
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.on_click_forget))
        btnForget.isUserInteractionEnabled = true
        btnForget.addGestureRecognizer(tap)
        
        //Facebook
        /*
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        //loginButton.center = view_facebook.center
        let click_facebook = UITapGestureRecognizer(target: self, action: #selector(self.loginButtonClicked_))
        loginButton.isUserInteractionEnabled = true
        loginButton.addGestureRecognizer(click_facebook) //addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        view_facebook.addSubview(loginButton)
        //if the user is already logged in
        if let accessToken = FBSDKAccessToken.current(){
            self.getFBUserData()
        }*/
      

    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup_ux()
        
        let loginManager = LoginManager()
        loginManager.logOut()
    }

    
    // Facebook
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
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    
                    var picture = self.dict["picture"] as! [String : AnyObject]
                    var data = picture["data"] as! [String : AnyObject]
                    let url = data["url"] as! String
                    
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
                        self.facebook_email = email
                        self.facebook_name = name
                        self.login_facebook()
                    }
                    else{
                        var vc = self.storyboard?.instantiateViewController(withIdentifier: "FormStudentViewControllerID") as! FormStudentViewController
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
    
    func login_facebook(){
            showGifIndicator(view: self.view)
               var parameters = [
                    "cvFacebook": self.facebook_id,
                    "Personas": [
                        "Dispositivos": [
                            [
                                "cvDispositivo": Defaults[.cvDispositivo]!,
                                "cvFirebase":Defaults[.cvFirebase]!,
                                "idDispositivo": 0
                            ]
                        ],
                        "idDireccion": 0,
                        "idPersona": 0,
                        "nbCompleto": self.facebook_name
                    ],
                    "nbUsuario": self.facebook_email,
                    "idUsuario": 0
                    ] as [String : Any]
        
            let parameter_json = JSON(parameters)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.get(parameters: parameter_json_string!, method: "IngresarAppFacebook", doneFunction: callback_on_click_login)
    }
    
    // Registros
    @IBAction func on_click_register_student(_ sender: UIButton) {
        print("Register Student")
         let vc = self.storyboard?.instantiateViewController(withIdentifier: "FormStudentViewControllerID") as! FormStudentViewController
        self.show(vc, sender: nil)
    }
    
    @IBAction func on_click_register_university(_ sender: UIButton) {
        print("Register University")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewControllerID") as! RegisterViewController
        self.show(vc, sender: nil)
    }
    
    // Login
    @IBAction func on_click_login(_ sender: Any) {
        
        if validate_form() == 0 {
            showGifIndicator(view: self.view)

            var parameters = [
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


            let parameter_json = JSON(parameters)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.get(parameters: parameter_json_string!, method: Singleton.IngresarApp, doneFunction: callback_on_click_login)
       
        
        }
    }
    
    func callback_on_click_login(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        
        if status == 1{
            var json = JSON(response)
            let data = JSON(json["Data"])
            
            print(data)
            save_profile(data:data)
            performSegue(withIdentifier: "showSplash", sender: self)
        }else{
            if  is_click_facebook == 1{
                print("Registro Login Incorrecto")

                var vc = self.storyboard?.instantiateViewController(withIdentifier: "FormStudentViewControllerID") as! FormStudentViewController
                vc.facebook_name = self.facebook_name
                vc.facebook_email = self.facebook_email
                vc.facebook_id = self.facebook_id
                vc.facebook_url = self.facebook_url
                vc.is_facebook = 1
                self.show(vc, sender: nil)
            }
            else{
                updateAlert(title: "", message: response as! String, automatic: true)
            }
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
        email.floatableDelegate = self
        password.floatableDelegate = self
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

