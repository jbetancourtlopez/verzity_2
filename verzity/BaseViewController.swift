import UIKit
import SystemConfiguration
import SwiftyUserDefaults
import Kingfisher
import SwiftyJSON
import RealmSwift

class BaseViewController: UIViewController, UITextFieldDelegate{
    var alert = UIAlertController()
    var alert_indicator = UIAlertController()
    var activeField: UITextField?
    var scrollView_: UIScrollView?
    var indicator : UIActivityIndicatorView!
    var viewLoading : UIView!
    var view_container : UIView!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backItem // title = "Atras"

    
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func adjustUITextViewHeight(arg : UITextView){
        
        
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
     }

    func set_photo_profile(url:String, image: UIImageView){
        // Formateo la Imagen
        var url_image = url
        url_image = url_image.replacingOccurrences(of: "~", with: "")
        url_image = url_image.replacingOccurrences(of: "\\", with: "")
        
        let desRutaMultimedia = Defaults[.desRutaMultimedia]!
        var desCarpetaMultimedia = Defaults[.desCarpetaMultimediaFTP]!
        
        desCarpetaMultimedia = desCarpetaMultimedia.replacingOccurrences(of: "~", with: "")
        desCarpetaMultimedia = desCarpetaMultimedia.replacingOccurrences(of: "\\", with: "")
        
        let url =  "\(desRutaMultimedia)\(url_image)"
        print("Image Url: \(url)")
        let URL = Foundation.URL(string: url)
       
        
        // Coloco la Imagen
        let image_default = UIImage(named: "ic_user_profile.png")
       image.kf.setImage(with: URL, placeholder: image_default)
    }
    
    func set_photo(url:String, image: UIImageView){
        // Formateo la Imagen
        var url_image = url
        url_image = url_image.replacingOccurrences(of: "~", with: "")
        url_image = url_image.replacingOccurrences(of: "\\", with: "")
        
        let desRutaMultimedia = "http://verzity.dwmedios.com/SITE/"
        
  
        let url =  "\(desRutaMultimedia)\(url_image)"
        print("Image Url: \(url)")
        let URL = Foundation.URL(string: url)
        
        
        // Coloco la Imagen
        let image_default = UIImage(named: "default.png")
        image.kf.setImage(with: URL, placeholder: image_default)
    }
    
    func generate_address(address:JSON)-> String{
        
        var label_address_text = ""
        
        if !(address["desDireccion"].stringValue).isEmpty {
            label_address_text += address["desDireccion"].stringValue
        }
        
        if label_address_text.count > 0 && !(address["nbCiudad"].stringValue).isEmpty {
            label_address_text += ", " + address["nbCiudad"].stringValue
        }
        
        if label_address_text.count > 0 && !(address["nbEstado"].stringValue).isEmpty {
            label_address_text += ", " + address["nbEstado"].stringValue
        }
        
        if label_address_text.count > 0 && !(address["nbPais"].stringValue).isEmpty {
            label_address_text += ", " + address["nbPais"].stringValue
        }
        
        return label_address_text
        
    }
    
    // Abrir el navegador
    func openUrl(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }
    
    func open(scheme: String){
        if let url = URL(string: scheme) {
            print(url)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //Tabla Vacia
    func empty_data_tableview(tableView: UITableView, string: String? = "No se encontraron elementos.", color:String? = "000000"){
        let view: UIView     = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: 21))
        let title: UILabel     = UILabel(frame: CGRect(x: 0, y:(tableView.frame.size.height/2), width: self.view.frame.width, height: 21))
        let noDataLabel: UIImageView     = UIImageView(frame: CGRect(x: (self.view.frame.width/2) - 30, y: (tableView.frame.height/2) - 65, width: 60, height: 60))
        title.text             = string
        title.textColor        = Colors.green_dark
        title.textAlignment    = .center
        noDataLabel.image = UIImage(named: "ic_action_pais")
        view.addSubview(title)
        //view.addSubview(noDataLabel)
        
        view.backgroundColor = hexStringToUIColor(hex: color!)
        tableView.backgroundView = view
        tableView.backgroundView?.isHidden = false
        tableView.separatorStyle = .none
    }
    
    //Mensaje
    func showMessage(title:String, automatic: Bool)->Void{
        alert.title = title
        self.present(alert, animated: true, completion: nil)
        
        if automatic{
            Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(BaseViewController.dismissAlert), userInfo: nil, repeats: false)
        }
    }

    func toast(title:String)->Void{
        let alert = UIAlertController(title: "", message: title, preferredStyle: .actionSheet)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
        
    }
    
    // Alerts
    func showAlert(_ title: String, message: String, okAction: UIAlertAction?, cancelAction: UIAlertAction?, automatic: Bool){
        alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        if  okAction != nil{
            alert.addAction(okAction!)
        }
        if cancelAction != nil{
            alert.addAction(cancelAction!)
        }
        self.present(alert, animated: true, completion: nil)
        if automatic == true{
            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(BaseViewController.dismissAlert), userInfo: nil, repeats: false)
        }
    }
    
    func updateAlert(title: String, message: String, automatic: Bool){
        alert.title = "" // title
        alert.message = message
        self.present(alert, animated: true, completion: nil)
        
        if automatic{
            Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(BaseViewController.dismissAlert), userInfo: nil, repeats: false)
        }
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    @objc func dismissAlert(){
        alert.dismiss(animated: true, completion: nil)
    }
    
    func showAlert_Indicator(_ title : String, message: String){
        alert_indicator = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: alert_indicator.view.bounds)
        indicator.center = CGPoint(x: 130.5, y: 65.5)
        indicator.color = Colors.green_dark
        alert_indicator.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        self.present(alert_indicator, animated: true, completion: nil)
    }
    
    func showIndicator(view: UIView){
        let navigationHeigth = (self.navigationController?.navigationBar.frame.size.height)! + 20
        indicator = UIActivityIndicatorView(frame: CGRect(x: (self.view.frame.width/2) - 25, y: (self.view.frame.height/2) - navigationHeigth, width: 50.0, height: 50.0))
        indicator.color = Colors.green_dark
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        view.addSubview(indicator)
        view.isUserInteractionEnabled = false
    }
    
    func hiddenIndicator(view: UIView){
        indicator.removeFromSuperview()
        view.isUserInteractionEnabled = true
    }
    
    // guardar datos de persistentes -----------------------
    let defaults:UserDefaults = UserDefaults.standard
    
    func setSettings(key:String, value:String){
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    func getSettings(key:String) -> String{
        if  let value = defaults.string(forKey: key) as? String {
            return value
        }
        return ""
    }
    
    //Gif Loading
    func showGifIndicator(view: UIView){
        viewLoading = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        viewLoading.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "loading_data", withExtension: "gif")!)
        let advTimeGif = UIImage.gifImageWithData(imageData!)
        let imageLoading = UIImageView(image: advTimeGif)
    
        
        
        imageLoading.frame = CGRect(x: (viewLoading.frame.size.width/2) - 50, y: (viewLoading.frame.height/2)-50, width: 100, height: 100)
        imageLoading.backgroundColor = Colors.green_dark
        imageLoading.layer.cornerRadius = 8.0
        imageLoading.contentMode = .scaleAspectFill
        viewLoading.addSubview(imageLoading)
        view.addSubview(viewLoading)
    }
    
    func showGifIndicator_ext(view: UIView){
        viewLoading = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        viewLoading.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        
        view_container = UIView(frame: CGRect(x: (self.view.frame.size.width/2) - 125, y: (self.view.frame.size.height/2) - 100, width: 250, height: 200))
        view_container.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        
        
        let image: UIImageView!
        image = UIImageView(frame: CGRect(x: (view_container.frame.size.width/2) - 50, y: (view_container.frame.height/2)-80, width: 100, height: 100))
        image.layer.cornerRadius = 50
        image.layer.masksToBounds=true
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: "sucess_ask")
  
        let label = UILabel(frame: CGRect(x: 0, y: 125, width: self.view_container.frame.width, height: 40))
        label.text = "Guardado correctamente"
        label.font=UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        
        view_container.addSubview(image)
        view_container.addSubview(label)
        
        viewLoading.addSubview(view_container)
        view.addSubview(viewLoading)
    }
    
    func hiddenGifIndicator(view: UIView){
        if viewLoading != nil{
            viewLoading.removeFromSuperview()
            viewLoading = nil
        }
    }
    
    //Teclado
    @objc func dismissKey() {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    func registerForKeyboardNotifications(scrollView: UIScrollView){
        self.scrollView_ = scrollView
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(_ notification: Notification)
    {
        self.scrollView_?.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView_?.contentInset = contentInsets
        self.scrollView_?.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if activeField != nil {
            if (!aRect.contains(activeField!.frame.origin))
            {
                self.scrollView_?.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(_ notification: Notification)
    {
        let contentInsets = UIEdgeInsets.zero
        scrollView_?.contentInset = contentInsets
        scrollView_?.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setGestureRecognizerHiddenKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BaseViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        self.scrollView_?.isScrollEnabled = true
    }
    
    
    //    Colores
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // Generador de Cadena Aleatoria
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    
    // Base de Datos
    func save_profile(data: JSON){
        
        let personas_json = JSON(data["Personas"])
        let dispositivos_json = JSON(personas_json["Dispositivos"])
        let catTiposPersonas_json = JSON(personas_json["CatTiposPersonas"])
        let direccion_json = JSON(personas_json["Direcciones"])
        let vestasPaquetesAsesores_json = JSON(personas_json["VentasPaquetesAsesores"])
        let universidades_json = JSON(personas_json["Universidades"]).arrayValue
     
        let direccion = Direcciones()
        direccion.idDireccion = direccion_json["idDireccion"].intValue
        
        direccion.desDireccion = direccion_json["desDireccion"].stringValue
        direccion.numCodigoPostal = direccion_json["numCodigoPostal"].stringValue
        direccion.nbPais = direccion_json["nbPais"].stringValue
        direccion.nbEstado = direccion_json["nbEstado"].stringValue
        direccion.nbMunicipio = direccion_json["nbMunicipio"].stringValue
        direccion.nbCiudad = direccion_json["nbCiudad"].stringValue
        direccion.dcLatitud = direccion_json["dcLatitud"].stringValue
        direccion.dcLongitud = direccion_json["dcLongitud"].stringValue

        let dispositivo = Dispositivos()
        dispositivo.idDispositivo = dispositivos_json[0]["idDispositivo"].intValue
        dispositivo.idPersona = dispositivos_json[0]["idPersona"].intValue
        dispositivo.cvDispositivo = Defaults[.cvDispositivo]!
        dispositivo.cvFirebase = Defaults[.cvFirebase]!

        
        let vestasPaquetesAsesores = VestasPaquetesAsesores()
        if  vestasPaquetesAsesores_json != JSON.null{
            
            vestasPaquetesAsesores.idVentaPaqueteAsesor = vestasPaquetesAsesores_json[0]["idVentaPaqueteAsesor"].intValue
            vestasPaquetesAsesores.idPaqueteAsesor = vestasPaquetesAsesores_json[0]["idPaqueteAsesor"].intValue
            vestasPaquetesAsesores.idPersona = vestasPaquetesAsesores_json[0]["idPersona"].intValue
            vestasPaquetesAsesores.idPersonaAsesor = vestasPaquetesAsesores_json[0]["idPersonaAsesor"].intValue
            vestasPaquetesAsesores.feVenta = vestasPaquetesAsesores_json[0]["feVenta"].stringValue
            vestasPaquetesAsesores.feVigencia = vestasPaquetesAsesores_json[0]["feVigencia"].stringValue
            vestasPaquetesAsesores.fgPaqueteActual = vestasPaquetesAsesores_json[0]["fgPaqueteActual"].stringValue
            vestasPaquetesAsesores.numReferenciaPaypal = vestasPaquetesAsesores_json[0]["numReferenciaPayPal"].stringValue
            vestasPaquetesAsesores.numLiberados = vestasPaquetesAsesores_json[0]["numLiberados"].stringValue
            vestasPaquetesAsesores.numUsados = vestasPaquetesAsesores_json[0]["numUsados"].stringValue
            
        }
    
        
        let universidades = Universidades()
        if  personas_json["idTipoPersona"].intValue == 2 {
            
            let direccion_universidad_json = JSON(universidades_json[0]["Direcciones"])
            
            let direccion_universidad = Direcciones()
            direccion_universidad.idDireccion = direccion_universidad_json["idDireccion"].intValue
            direccion_universidad.desDireccion = direccion_universidad_json["desDireccion"].stringValue
            direccion_universidad.numCodigoPostal = direccion_universidad_json["numCodigoPostal"].stringValue
            direccion_universidad.nbPais = direccion_universidad_json["nbPais"].stringValue
            direccion_universidad.nbEstado = direccion_universidad_json["nbEstado"].stringValue
            direccion_universidad.nbMunicipio = direccion_universidad_json["nbMunicipio"].stringValue
            direccion_universidad.nbCiudad = direccion_universidad_json["nbCiudad"].stringValue
            direccion_universidad.dcLatitud = direccion_universidad_json["dcLatitud"].stringValue
            direccion_universidad.dcLongitud = direccion_universidad_json["dcLongitud"].stringValue
            
            let ventasPaquetes_array = JSON(universidades_json[0]["VentasPaquetes"]).arrayValue
            let ventasPaquetes = VestasPaquetes()
            let paquete = Paquete()
            
            // Valido si tiene un paquete vendido
            if ventasPaquetes_array.count > 0{
                print("ventasPaquetes_array")
                let ventasPaquetes_json = JSON(ventasPaquetes_array[0])
               
                // Valido si tiene un paquete
                if ventasPaquetes_json["Paquete"] != JSON.null{
                    
                    print("ventasPaquetes_json")
                    
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
            print("test")
            print(paquete)
            ventasPaquetes.Paquete = paquete
            
            universidades.idUniversidad = universidades_json[0]["idUniversidad"].intValue
            universidades.idEstatus = universidades_json[0]["idUniversidad"].intValue
            universidades.idDireccion = universidades_json[0]["idDireccion"].intValue
            universidades.idPersona = universidades_json[0]["idPersona"].intValue
            universidades.pathLogo = universidades_json[0]["pathLogo"].stringValue
            universidades.nbUniversidad = universidades_json[0]["nbUniversidad"].stringValue
            universidades.nbReprecentante = universidades_json[0]["nbReprecentante"].stringValue
            universidades.desUniversidad = universidades_json[0]["desUniversidad"].stringValue
            universidades.desSitioWeb = universidades_json[0]["desSitioWeb"].stringValue
            universidades.desTelefono = universidades_json[0]["desTelefono"].stringValue
            universidades.desCorreo = universidades_json[0]["desCorreo"].stringValue
            universidades.feRegistro = universidades_json[0]["feRegistro"].stringValue
            universidades.urlFolletosDigitales = universidades_json[0]["urlFolletosDigitales"].stringValue
            universidades.urlFaceBook = universidades_json[0]["urlFaceBook"].stringValue
            universidades.urlTwitter = universidades_json[0]["urlTwitter"].stringValue
            universidades.urlInstagram = universidades_json[0]["urlInstagram"].stringValue

            universidades.Direcciones = direccion_universidad
            universidades.VestasPaquetes = ventasPaquetes
        }
        
        let persona = Persona()
        
        // Valido de donde viene el Tipo de Persona
        var idTipoPersona = 0;
        if catTiposPersonas_json != JSON.null{
            
            let nbTipoPersona = catTiposPersonas_json["nbTipoPersona"].stringValue
            if (nbTipoPersona == "UNIVERSIDAD"){
                idTipoPersona = 2
            }else{
                idTipoPersona = 1
            }
            
        }else{
            idTipoPersona = personas_json["idTipoPersona"].intValue
        }
        
        
        persona.idPersona = personas_json["idPersona"].intValue
        persona.idDireccion = personas_json["idDireccion"].intValue
        persona.idTipoPersona = idTipoPersona
        persona.nbCompleto = personas_json["nbCompleto"].stringValue
        persona.desTelefono = personas_json["desTelefono"].stringValue
        persona.desCorreo = personas_json["desCorreo"].stringValue
        persona.pathFoto = personas_json["pathFoto"].stringValue
        persona.desSkype = personas_json["desSkype"].stringValue
        persona.desPersona = personas_json["desPersona"].stringValue

        print(vestasPaquetesAsesores)

        persona.VestasPaquetesAsesores = vestasPaquetesAsesores
        persona.Direcciones = direccion
        persona.Dispositivos = dispositivo
        persona.Universidades = universidades

        let usuario = Usuario()
        usuario.idUsuario = data["idUsuario"].intValue
        usuario.idPersona = data["idPersona"].intValue
        usuario.idPerfil = data["idPerfil"].intValue

        usuario.nbUsuario = data["nbUsuario"].stringValue
        usuario.pwdContrasenia = data["pwdContrasenia"].stringValue
        usuario.idEstatus = data["idEstatus"].stringValue
        usuario.cvFacebook = data["cvFacebook"].stringValue
        usuario.Persona = persona

        try! realm.write {
            realm.add(usuario)
        }

        let usuario_db = realm.objects(Usuario.self).first
        print(usuario_db?.Persona?.desTelefono)
        
    }
    
    func get_user()-> Usuario{
        let usuario_db = realm.objects(Usuario.self).first
        return usuario_db ?? Usuario()
    }
    
    func get_type_user() -> Int{
        let usuario_db = realm.objects(Usuario.self).first
        let usuario = usuario_db!
        return (usuario.Persona?.idTipoPersona)!
    }

    func get_paquete(usuario:Usuario) -> Paquete{
        
        var paquete = usuario.Persona?.Universidades?.VestasPaquetes?.Paquete

        return paquete ?? Paquete()
    }
    
    func delete_session(){
        print("Delete")
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func save_configuration(data: JSON){
        
        Defaults[.id_Configuraciones] = data["id_Configuraciones"].intValue
        Defaults[.desRutaWebServices] = data["desRutaWebServices"].stringValue
        Defaults[.desRutaMultimedia] = data["desRutaMultimedia"].stringValue
        Defaults[.cvPaypal] = data["cvPaypal"].stringValue
        Defaults[.desRutaFTP] = data["desRutaFTP"].stringValue
        Defaults[.nbUsuarioFTP] = data["nbUsuarioFTP"].stringValue
        Defaults[.pdwContraseniaFTP] = data["pdwContraseniaFTP"].stringValue
        Defaults[.desCarpetaMultimediaFTP] = data["desCarpetaMultimediaFTP"].stringValue
        Defaults[.desRutaTerminos] = data["desRutaTerminos"].stringValue
    }
    
}

extension DefaultsKeys {
    static let username = DefaultsKey<String?>("username")
    static let launchCount = DefaultsKey<Int>("launchCount")
    
    // Generales
    static let type_user = DefaultsKey<Int?>("type_user") // 1:Academic - 2:Universidad
    
    // Settings
    static let id_Configuraciones = DefaultsKey<Int?>("id_Configuraciones")
    static let desRutaWebServices = DefaultsKey<String?>("desRutaWebServices")
    static let desRutaMultimedia = DefaultsKey<String?>("desRutaMultimedia")
    static let cvPaypal = DefaultsKey<String?>("cvPaypal")
    static let desRutaFTP = DefaultsKey<String?>("desRutaFTP")
    static let nbUsuarioFTP = DefaultsKey<String?>("nbUsuarioFTP")
    static let pdwContraseniaFTP = DefaultsKey<String?>("pdwContraseniaFTP")
    static let desCarpetaMultimediaFTP = DefaultsKey<String?>("desCarpetaMultimediaFTP")
    static let desRutaTerminos = DefaultsKey<String?>("desRutaTerminos")

    
    
    // Dispositivo
    static let cvDispositivo = DefaultsKey<String?>("cvDispositivo")
    static let cvFirebase = DefaultsKey<String?>("cvFirebase")
    static let idDispositivo = DefaultsKey<Int?>("idDispositivo")
    
    // Academico
    static let academic_idPersona = DefaultsKey<Int?>("academic_idPersona")
    static let academic_idDireccion = DefaultsKey<Int?>("academic_idDireccion")

    static let academic_name = DefaultsKey<String?>("academic_name")
    static let academic_email = DefaultsKey<String?>("academic_email")
    static let academic_phone = DefaultsKey<String?>("academic_phone")
    static let academic_pathFoto = DefaultsKey<String?>("academic_pathFoto")

    static let academic_nbPais = DefaultsKey<String?>("academic_nbPais")
    static let academic_cp = DefaultsKey<String?>("academic_cp")
    static let academic_city = DefaultsKey<String?>("academic_city")
    static let academic_municipio = DefaultsKey<String?>("academic_municipio")
    static let academic_state = DefaultsKey<String?>("academic_state")
    static let academic_description = DefaultsKey<String?>("academic_description")
    static let academic_dcLatitud = DefaultsKey<String?>("academic_dcLatitud")
    static let academic_dcLongitud = DefaultsKey<String?>("academic_dcLongitud")
    

    //Paquete
    static let package_idUniveridad = DefaultsKey<Int?>("package_idUniveridad")
    static let package_idPaquete = DefaultsKey<Int?>("package_idPaquete")

    static let package_feVenta = DefaultsKey<String?>("package_feVenta")
    static let package_feVigencia = DefaultsKey<String?>("package_feVigencia")

    

    
    //Universidad
    static let university_idPersona = DefaultsKey<Int?>("university_idPersona")
    static let university_idUniveridad = DefaultsKey<Int?>("university_idUniveridad")
    static let university_pathLogo = DefaultsKey<String?>("university_pathLogo")
    static let university_nbUniversidad = DefaultsKey<String?>("university_nbUniversidad")
    static let university_nbReprecentante = DefaultsKey<String?>("university_nbReprecentante")
    static let university_desUniversidad = DefaultsKey<String?>("university_desUniversidad")
    static let university_desSitioWeb = DefaultsKey<String?>("university_desSitioWeb")
    static let university_desTelefono = DefaultsKey<String?>("university_desTelefono")
    static let university_desCorreo = DefaultsKey<String?>("university_desCorreo")
    
    //Persona Universidad
    static let representative_nbCompleto = DefaultsKey<String?>("representative_nbCompleto")
    static let representative_desTelefono = DefaultsKey<String?>("representative_desTelefono")
    static let representative_desCorreo = DefaultsKey<String?>("representative_desCorreo")
    static let representative_pathFoto = DefaultsKey<String?>("representative_pathFoto")
    
    // Direccion Representante
    static let add_rep_desDireccion = DefaultsKey<String?>("add_rep_desDireccion")
    static let add_rep_numCodigoPostal = DefaultsKey<String?>("add_rep_numCodigoPostal")
    static let add_rep_nbPais = DefaultsKey<String?>("add_rep_nbPais")
    static let add_rep_nbEstado = DefaultsKey<String?>("add_rep_nbEstado")
    static let add_rep_nbMunicipio = DefaultsKey<String?>("add_rep_nbMunicipio")
    static let add_rep_nbCiudad = DefaultsKey<String?>("add_rep_nbCiudad")
    static let add_rep_dcLatitud = DefaultsKey<String?>("add_rep_dcLatitud")
    static let add_rep_dcLongitud = DefaultsKey<String?>("add_rep_dcLongitud")
    
    // Direccion Universidad
    static let add_uni_idDireccion = DefaultsKey<Int?>("add_uni_idDireccion")
    static let add_uni_idUniversidad = DefaultsKey<Int?>("add_uni_idUniversidad")
    static let add_uni_desDireccion = DefaultsKey<String?>("add_uni_desDireccion")
    static let add_uni_numCodigoPostal = DefaultsKey<String?>("add_uni_numCodigoPostal")
    static let add_uni_nbPais = DefaultsKey<String?>("add_uni_nbPais")
    static let add_uni_nbEstado = DefaultsKey<String?>("add_uni_nbEstado")
    static let add_uni_nbMunicipio = DefaultsKey<String?>("add_uni_nbMunicipio")
    static let add_uni_nbCiudad = DefaultsKey<String?>("add_uni_nbCiudad")
    static let add_uni_dcLatitud = DefaultsKey<Double?>("add_uni_dcLatitud")
    static let add_uni_dcLongitud = DefaultsKey<Double?>("add_uni_dcLongitud")


}
