
import UIKit
import SwiftyJSON
import Kingfisher

import SystemConfiguration
import SwiftyUserDefaults

class ListAsesorViewController: BaseViewController {
    
    // Inputs
    @IBOutlet var phone: UILabel!
    @IBOutlet var photo: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var description_asesor: UITextView!
    @IBOutlet var email: UILabel!
    @IBOutlet var skype: UILabel!
    
    @IBOutlet weak var icon_skype: UIImageView!
    @IBOutlet weak var icon_email: UIImageView!
    @IBOutlet weak var icon_phone: UIImageView!
    
    // Variables
    var actionButton : ActionButton!
    var webServiceController = WebServiceController()
    var usuario = Usuario()
    var have_asesor = true
    var idVentaPaqueteAsesor = 0
    var view_container_ = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usuario = get_user()
        print("holaaaa0")
        
        self.idVentaPaqueteAsesor = (self.usuario.Persona?.VestasPaquetesAsesores!.idVentaPaqueteAsesor)!
        
        if self.idVentaPaqueteAsesor == 0{
            set_view()
            have_asesor = false
            
        }
        setup_ux()
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load_data()
        
        self.idVentaPaqueteAsesor = (self.usuario.Persona?.VestasPaquetesAsesores!.idVentaPaqueteAsesor)!
        
        if self.idVentaPaqueteAsesor != 0 && !self.have_asesor{
            print("Nuevo Asesor")
            print("Start remove sibview")
            if let viewWithTag = self.view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
            }else{
                print("No!")
            }

        }
    }
    
    func set_view(){
        
        view_container_ = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        view_container_.backgroundColor = hexStringToUIColor(hex: "#FFFFFF")
        view_container_.tag = 100
        
        var view_green : UIView!
        view_green = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height/2))
        view_green.backgroundColor = hexStringToUIColor(hex: "#3E8426")
        view_container_.addSubview(view_green)
        
        var view_center : UIView!
        view_center = UIView(frame: CGRect(x: 10, y: (self.view.frame.size.height/2) - 50, width: self.view.frame.size.width - 20, height: 100))
        view_center.backgroundColor = hexStringToUIColor(hex: "#FFFFFF") //UIColor.white.withAlphaComponent(1.0)
        view_center.layer.cornerRadius = 10
        
        view_center.layer.borderWidth = 2
        view_center.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        view_container_.addSubview(view_center)
        
        // Image gif
        let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "emoji_sad", withExtension: "gif")!)
        let advTimeGif = UIImage.gifImageWithData(imageData!)
        
        let imageLoading = UIImageView(image: advTimeGif)
        imageLoading.frame =  CGRect(x: (view_center.frame.width/2) - 25, y: view_center.frame.height - 100, width: 50, height: 50)
        
        view_center.addSubview(imageLoading)
        
        let ups = UILabel(frame: CGRect(x: 0 , y: view_center.frame.height - 45, width: view_center.frame.width, height: 20))
        ups.text = "Upss."
        ups.textAlignment = .center
        ups.font = UIFont.boldSystemFont(ofSize: 17.0)
        ups.textColor = hexStringToUIColor(hex: "#388E3C")
        view_center.addSubview(ups)
        
        let text_ley = UILabel(frame: CGRect(x: 00 , y: view_center.frame.height - 25, width: view_center.frame.width, height: 20))
        text_ley.text = "Al parecer no cuenta con un asesor contratado."
        text_ley.textAlignment = .center
        text_ley.font=UIFont.systemFont(ofSize: 13)
        text_ley.textColor = hexStringToUIColor(hex: "#388E3C")
        view_center.addSubview(text_ley)
        
        self.view.addSubview(view_container_)
        
        
    }
    
    func load_data(){
        showGifIndicator(view: self.view)
       
         let array_parameter = [
            "desCorreo": usuario.Persona?.desCorreo,
            "Direcciones": [
                "nbCiudad": usuario.Persona?.Direcciones?.nbCiudad,
                "numCodigoPostal": usuario.Persona?.Direcciones?.numCodigoPostal,
                "desDireccion": usuario.Persona?.Direcciones?.desDireccion,
                "nbEstado": usuario.Persona?.Direcciones?.nbEstado,
                "idDireccion": usuario.Persona?.Direcciones?.idDireccion,
                "nbMunicipio": usuario.Persona?.Direcciones?.nbMunicipio,
                "nbPais": usuario.Persona?.Direcciones?.nbPais
            ],
            "Dispositivos": [
                [
                    "cvDispositivo": usuario.Persona?.Dispositivos?.cvDispositivo,
                    "cvFirebase": usuario.Persona?.Dispositivos?.cvFirebase,
                    "idDispositivo": usuario.Persona?.Dispositivos?.idDispositivo
                ]
            ],
            "idPersona": usuario.Persona?.idPersona,
            "idDireccion": usuario.Persona?.idDireccion,
            "nbCompleto": usuario.Persona?.nbCompleto,
            "desTelefono": usuario.Persona?.desTelefono
            ] as [String : Any]
        
        print(array_parameter)
        
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method: "GetMisAsesores", doneFunction: callback_load_data)
    }
    
    func callback_load_data(status: Int, response: AnyObject){
        var json = JSON(response)
        var data = JSON(json["Data"][0])
        hiddenGifIndicator(view: self.view)
        
        if status == 1{
            skype.text = data["desSkype"].stringValue
            phone.text = data["desTelefono"].stringValue
            email.text = data["desCorreo"].stringValue
            name.text = data["nbCompleto"].stringValue
            description_asesor.text = data["desPersona"].stringValue
            set_photo_profile(url: data["pathFoto"].stringValue, image: photo)
            photo.layer.masksToBounds = true
            photo.layer.cornerRadius = 60
        }
    }
    
    @IBAction func on_click_phone(_ sender: Any) {
        print("Phone")
        openUrl(scheme: "tel://\(phone.text)")
    }
    
    @IBAction func on_click_email(_ sender: Any) {
        print("Email")
        open(scheme: "mailto:\(email.text)")
    }
    
    @IBAction func on_click_skype(_ sender: Any) {
        print("Skype")
        open(scheme: "skype:\(skype.text)")
    }
    
    func setup_ux(){
        
        self.title = "Mi Asesor"
        
        let postularse = ActionButtonItem(title: "Consultar paquetes", image: #imageLiteral(resourceName: "ic_notification_green"))
        postularse.action = { item in self.self.on_click_asesor() }
        
        actionButton = ActionButton(attachedToView: self.view, items: [postularse])
        actionButton.setTitle("+", forState: UIControlState())
        actionButton.backgroundColor = UIColor(red: 57.0/255.0, green: 142.0/255.0, blue: 49.0/255.0, alpha: 1)
        actionButton.action = { button in button.toggleMenu()}
        
        // Colores de los iconos
        icon_phone.image = icon_phone.image?.withRenderingMode(.alwaysTemplate)
        icon_phone.tintColor = hexStringToUIColor(hex: "#000000")
        
        icon_email.image = icon_email.image?.withRenderingMode(.alwaysTemplate)
        icon_email.tintColor = hexStringToUIColor(hex: "#ff7b25")
        
        icon_skype.image = icon_skype.image?.withRenderingMode(.alwaysTemplate)
        icon_skype.tintColor = hexStringToUIColor(hex: "#12A5F4")
        
    }
    
    func on_click_asesor(){
        print("Paquetes Asesor")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ListAsesorPaqueteViewControllerID") as! ListAsesorPaqueteViewController
        self.show(vc, sender: nil)
        
    }
    
    
    
}
