
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
    
    // Variables
    var actionButton : ActionButton!
    var webServiceController = WebServiceController()


    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ux()
        load_data()
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
        
        print(data)
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
    }
    
    func on_click_asesor(){
        print("Paquetes Asesor")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ListAsesorPaqueteViewControllerID") as! ListAsesorPaqueteViewController
        self.show(vc, sender: nil)
    }
    
    
    
}
