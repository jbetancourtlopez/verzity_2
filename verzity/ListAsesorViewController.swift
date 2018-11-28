
import UIKit
import SwiftyJSON
import Kingfisher

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

    override func viewDidLoad() {
        super.viewDidLoad()
        //set_view()
        setup_ux()
        load_data()
    }
    
    func set_view(){
        
        var view_container : UIView!
        view_container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        view_container.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        
        var view_green : UIView!
        view_green = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height/2))
        view_green.backgroundColor = hexStringToUIColor(hex: "#3E8426")
        view_container.addSubview(view_green)
        
        self.view.addSubview(view_container)
        
    }
    
    func load_data(){
        
        var usuario = get_user()
        print(usuario)
        // Cargamos los datos
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
        openUrl(scheme: "tel://9809088798")
    }
    
    
    @IBAction func on_click_email(_ sender: Any) {
        print("Email")
        open(scheme: "mailto:name@email.com")
    }
    
    @IBAction func on_click_skype(_ sender: Any) {
        print("Skype")
        open(scheme: "skype:asesor2@live.com")
    }
    
    func setup_ux(){
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
        icon_email.tintColor = hexStringToUIColor(hex: "#1d47f1")
        
        icon_skype.image = icon_skype.image?.withRenderingMode(.alwaysTemplate)
        icon_skype.tintColor = hexStringToUIColor(hex: "#12A5F4")
        
    }
    
    func on_click_asesor(){
        print("Paquetes Asesor")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ListAsesorPaqueteViewControllerID") as! ListAsesorPaqueteViewController
        self.show(vc, sender: nil)
    }
    
    
    
}
