import UIKit
import SwiftyJSON
import SwiftyUserDefaults

class SplashViewController: BaseViewController {
    
    var webServiceController = WebServiceController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Llamada a Firebase
        NotificationCenter.default.addObserver(self, selector: #selector(self.displayFCMToken(notification:)),
                                               name: Notification.Name("FCMToken"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("notificationFCM"), object: nil)
        
        load_settings()
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification){
        print("Notificacion recibida Splash")
        var userInfo = notification.userInfo
        var object = notification.object
    }
    
     // Firebase Event
    @objc func displayFCMToken(notification: NSNotification){
        guard let userInfo = notification.userInfo else {return}
        print("Debug-FirebaseToken Splash: \(userInfo["token"]!)")
        if let fcmToken = userInfo["token"] as? String {
            Defaults[.cvFirebase] = fcmToken
            print(Defaults[.cvFirebase]!)
        }
    }
    
    func load_settings() {
        showGifIndicator(view: self.view)
        print("Carga de Settings")
        let array_parameter = ["": ""]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.getSettings(parameters: parameter_json_string!, doneFunction: callback_load_settings)
    }
    
    func callback_load_settings(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        var json = JSON(response)
        if status == 1{
            let data = JSON(json["Data"])
            save_configuration(data: data)
            validate_user()
        }
    }
    
    func validate_user(){
        let usuario = get_user()
        print(usuario)
        //return
        if usuario.idUsuario > 0 {
            let idTipoPersona = usuario.Persona?.idTipoPersona
            
            
            if idTipoPersona == 1 || idTipoPersona == 0{
                _ = self.navigationController?.popToRootViewController(animated: false)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Navigation_StudentViewController") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = vc
            } else if idTipoPersona == 2 {
                print("Valido si la Universidad esta Activa")
                showGifIndicator(view: self.view)
                let array_parameter = ["idUniversidad": usuario.Persona?.Universidades?.idUniversidad]
                let parameter_json = JSON(array_parameter)
                let parameter_json_string = parameter_json.rawString()
                webServiceController.get(parameters: parameter_json_string!, method: Singleton.VerificarEstatusUniversidad,  doneFunction: VerificarEstatusUniversidad)
            }
        }else {
            go_to_login()
        }
    }
    
    func VerificarEstatusUniversidad(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        print("Validando Universidad")
        let json = JSON(response)
        debugPrint(json)
        if status == 1{
            _ = self.navigationController?.popToRootViewController(animated: false)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Navigation_UniversityViewController") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = vc
        }else{
            let yesAction = UIAlertAction(title: "Aceptar", style: .default) { (action) -> Void in
                self.go_to_login()
            }
            showAlert("Atención", message: StringsLabel.account_invalid, okAction: yesAction, cancelAction: nil, automatic: false)            
        }
    }
    
    func go_to_login(){
        delete_session()
        performSegue(withIdentifier: "showLogin", sender: self)
    }
}

