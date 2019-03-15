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
        let json = JSON(response)
        let data = JSON(json["Data"])
        
        print(data)
        
        let personas_json = JSON(data["Personas"])
        let direccion_universidad_json = JSON(data["Direcciones"])
        let ventasPaquetes_array = JSON(data["VentasPaquetes"]).arrayValue
        
        if status == 1{
            
            // Guardo la info.
            if let usuario_db = realm.objects(Usuario.self).first{
                try! realm.write {
                    
                    // Direccion
                    let direccion_universidad = Direcciones()
                    if data["Direcciones"] != JSON.null{
                        direccion_universidad.idDireccion = direccion_universidad_json["idDireccion"].intValue
                        direccion_universidad.desDireccion = direccion_universidad_json["desDireccion"].stringValue
                        direccion_universidad.numCodigoPostal = direccion_universidad_json["numCodigoPostal"].stringValue
                        direccion_universidad.nbPais = direccion_universidad_json["nbPais"].stringValue
                        direccion_universidad.nbEstado = direccion_universidad_json["nbEstado"].stringValue
                        direccion_universidad.nbMunicipio = direccion_universidad_json["nbMunicipio"].stringValue
                        direccion_universidad.nbCiudad = direccion_universidad_json["nbCiudad"].stringValue
                        direccion_universidad.dcLatitud = direccion_universidad_json["dcLatitud"].stringValue
                        direccion_universidad.dcLongitud = direccion_universidad_json["dcLongitud"].stringValue
                    }
                    
                    // Ventas Paquete
                    let ventasPaquetes = VestasPaquetes()
                    let paquete = Paquete()
                    
                    if ventasPaquetes_array.count > 0{
                        let ventasPaquetes_json = JSON(ventasPaquetes_array[0])
                        
                        // Valido si tiene un paquete
                        if ventasPaquetes_json["Paquete"] != JSON.null{
                            
                            let paquete_json = JSON(ventasPaquetes_json["Paquete"])
                            paquete.idPaquete = paquete_json["idPaquete"].intValue
                            paquete.idEstatus = paquete_json["idEstatus"].intValue
                            paquete.cvPaquete = paquete_json["cvPaquete"].stringValue
                            paquete.nbPaquete = paquete_json["nbPaquete"].stringValue
                            paquete.desPaquete = paquete_json["desPaquete"].stringValue
                            paquete.dcDiasVigencia = paquete_json["dcDiasVigencia"].stringValue
                            paquete.fgAplicaBecas = paquete_json["fgAplicaBecas"].stringValue
                            paquete.fgAplicaFinanciamiento = paquete_json["fgAplicaFinanciamiento"].stringValue
                            paquete.fgAplicaPostulacion = paquete_json["fgAplicaPostulacion"].stringValue
                            paquete.fgAplicaProspectus = paquete_json["fgProspectus"].stringValue
                            paquete.fgAplicaLogo = paquete_json["fgAplicaLogo"].stringValue
                            paquete.fgAplicaDireccion = paquete_json["fgAplicaDireccion"].stringValue
                            paquete.fgAplicaFavoritos = paquete_json["fgAplicaFavoritos"].stringValue
                            paquete.fgAplicaUbicacion = paquete_json["fgAplicaUbicacion"].stringValue
                            paquete.fgAplicaRedes = paquete_json["fgAplicaRedes"].stringValue
                            paquete.fgAplicaProspectusVideo = paquete_json["fgAplicaProspectusVideo"].stringValue
                            paquete.fgAplicaProspectusVideos = paquete_json["fgAplicaProspectusVideos"].stringValue
                            paquete.fgAplicaAplicaImagenes = paquete_json["fgAplicaImagenes"].stringValue
                            paquete.fgAplicaContacto = paquete_json["fgAplicaContacto"].stringValue
                            paquete.fgAplicaDescripcion = paquete_json["fgAplicaDescripcion"].stringValue
                        }
                        
                        ventasPaquetes.idVentasPaquetes = ventasPaquetes_json["fgPaqueteActual"].intValue
                        ventasPaquetes.idUniversidad = ventasPaquetes_json["idUniversidad"].intValue
                        ventasPaquetes.idPaquete = ventasPaquetes_json["idPaquete"].intValue
                        ventasPaquetes.feVenta = ventasPaquetes_json["feVenta"].stringValue
                        ventasPaquetes.feVigencia = ventasPaquetes_json["feVigencia"].stringValue
                        ventasPaquetes.fgPaqueteActual = ventasPaquetes_json["fgPaqueteActual"].stringValue
                        ventasPaquetes.fgRecurrente = ventasPaquetes_json["fgRecurrente"].stringValue
                        ventasPaquetes.numReferenciaPaypal = ventasPaquetes_json["numReferenciaPayPal"].stringValue
                    }
                    ventasPaquetes.Paquete = paquete
                    
                    // Universidad
                    let universidades = Universidades()
                    universidades.idUniversidad = data["idUniversidad"].intValue
                    universidades.idEstatus = data["idUniversidad"].intValue
                    universidades.idDireccion = data["idDireccion"].intValue
                    universidades.pathLogo = data["pathLogo"].stringValue
                    universidades.nbUniversidad = data["nbUniversidad"].stringValue
                    universidades.nbReprecentante = data["nbReprecentante"].stringValue
                    universidades.desUniversidad = data["desUniversidad"].stringValue
                    universidades.desSitioWeb = data["desSitioWeb"].stringValue
                    universidades.desTelefono = data["desTelefono"].stringValue
                    universidades.desCorreo = data["desCorreo"].stringValue
                    universidades.feRegistro = data["feRegistro"].stringValue
                    universidades.urlFolletosDigitales = data["urlFolletosDigitales"].stringValue
                    universidades.urlFaceBook = data["urlFaceBook"].stringValue
                    universidades.urlTwitter = data["urlTwitter"].stringValue
                    universidades.urlInstagram = data["urlInstagram"].stringValue
                    
                    universidades.Direcciones = direccion_universidad
                    universidades.VestasPaquetes = ventasPaquetes
                    
                    //Persona
                    usuario_db.Persona?.nbCompleto = personas_json["nbCompleto"].stringValue
                    usuario_db.Persona?.desTelefono = personas_json["desTelefono"].stringValue
                    usuario_db.Persona?.desCorreo = personas_json["desCorreo"].stringValue
                    usuario_db.Persona?.pathFoto = personas_json["pathFoto"].stringValue
                    usuario_db.Persona?.desSkype = personas_json["desSkype"].stringValue
                    usuario_db.Persona?.desPersona = personas_json["desPersona"].stringValue
                    usuario_db.Persona?.Universidades = universidades
                }
            }
            
    
            
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

