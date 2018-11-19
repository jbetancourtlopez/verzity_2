import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults

class DetailUniversity3ViewController: BaseViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    
    // Slider
    @IBOutlet var page_control: UIPageControl!
    @IBOutlet var image_slide: UIImageView!
    @IBOutlet var view_slider: UIView!
    @IBOutlet var view_slider_ct_height: NSLayoutConstraint!
    
    //Cabezera
    @IBOutlet var view_logo_center: UIView!
    @IBOutlet var view_logo_left: UIView!
    
    @IBOutlet var image_logo1: UIImageView!
    @IBOutlet var label_name1: UILabel!
   
    @IBOutlet var image_logo2: UIImageView!
    @IBOutlet var label_logo2: UILabel!
    @IBOutlet var button_favorit2: UIButton!
    
    @IBOutlet var view_logo_left_ct_height: NSLayoutConstraint!
    @IBOutlet var view_logo_center_ct_height: NSLayoutConstraint!
    
    //Mapa
    @IBOutlet var view_location_empty: UIView!
    @IBOutlet var view_location_empty_ct_height: NSLayoutConstraint!
    @IBOutlet var view_location_map: UIView!
    //@IBOutlet var map: MKMapView!
    @IBOutlet var view_location_map_ct_height: NSLayoutConstraint!
    
    // Contacto
    @IBOutlet var view_contacto: UIView!
    @IBOutlet var view_contacto_ct_height: NSLayoutConstraint!
    @IBOutlet var image_address: UIImageView!
    @IBOutlet var label_address: UILabel!
    @IBOutlet var image_phone: UIImageView!
    @IBOutlet var label_phone: UILabel!
    @IBOutlet var image_url: UIImageView!
    @IBOutlet var label_url: UILabel!
    @IBOutlet var image_email: UIImageView!
    @IBOutlet var label_email: UILabel!
    
    // Botones
    @IBOutlet var image_prospectus: UIImageView!
    @IBOutlet var button_prospectus: UIButton!
    @IBOutlet var image_beca: UIImageView!
    @IBOutlet var button_beca: UIButton!
    @IBOutlet var image_finan: UIImageView!
    @IBOutlet var button_finan: UIButton!
    
    @IBOutlet var view_prospectus: UIView!
    @IBOutlet var view_prospectus_ct_heigth: NSLayoutConstraint!
    @IBOutlet var view_beca: UIView!
    @IBOutlet var view_beca_ct_heigth: NSLayoutConstraint!
    @IBOutlet var view_finan: UIView!
    @IBOutlet var view_finan_ct_heigth: NSLayoutConstraint!
    // Redes sociales
    
    @IBOutlet var view_redes: UIView!
    @IBOutlet var view_redes_ct_height: NSLayoutConstraint!
    @IBOutlet var instagram: UIImageView!
    @IBOutlet var twitter: UIImageView!
    @IBOutlet var facebook: UIImageView!
    
    // Descripcion
    @IBOutlet var description_uni: UITextView!
    @IBOutlet var view_description: UIView!
    @IBOutlet var view_description_ct_height: NSLayoutConstraint!
    
    // Variables
    var webServiceController = WebServiceController()
    var actionButton : ActionButton!
    var idUniversidad: Int!
    var data: JSON = []
    
    var swipeGesture  = UISwipeGestureRecognizer()
    var list_images: NSArray = []
    var count_current = 0
    
    var list_licenciaturas: NSArray = []
    var selected_postulate: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.idUniversidad = 3441
        setup_ux()
        load_data()
        set_events()
        setup_slider()
        set_favorito()
    }
    
    func setup_ux(){
        let image_visitar_web  = UIImage(named: "ic_visitar_web")?.withRenderingMode(.alwaysTemplate)
        
        //Header
        let image = UIImage(named: "ic_action_star_border")?.withRenderingMode(.alwaysTemplate)
        button_favorit2.setImage(image, for: .normal)
        button_favorit2.tintColor = hexStringToUIColor(hex: "#F7BF25")
        
        image_logo1.layer.masksToBounds = true
        image_logo1.layer.cornerRadius = 30
        image_logo2.layer.masksToBounds = true
        image_logo2.layer.cornerRadius = 30
        
        // Contacto
        image_address.image = image_address.image?.withRenderingMode(.alwaysTemplate)
        image_address.tintColor = hexStringToUIColor(hex: "#ff0106")
        
        image_phone.image = image_phone.image?.withRenderingMode(.alwaysTemplate)
        image_phone.tintColor = Colors.gray
        
        image_url.image = image_url.image?.withRenderingMode(.alwaysTemplate)
        image_url.tintColor = hexStringToUIColor(hex: "#1d47f1")
        
        image_email.image = image_email.image?.withRenderingMode(.alwaysTemplate)
        image_email.tintColor = hexStringToUIColor(hex: "#1d47f1")
        
        // Botones
        image_prospectus.image = image_prospectus.image?.withRenderingMode(.alwaysTemplate)
        image_prospectus.tintColor = hexStringToUIColor(hex: "#ff0106")
        button_prospectus.setImage(image_visitar_web, for: .normal)
        button_prospectus.tintColor = Colors.gray
        
        image_beca.image = image_beca.image?.withRenderingMode(.alwaysTemplate)
        image_beca.tintColor = hexStringToUIColor(hex: "#32cb00")
        button_beca.setImage(image_visitar_web, for: .normal)
        button_beca.tintColor = Colors.gray
        
        image_finan.image = image_finan.image?.withRenderingMode(.alwaysTemplate)
        image_finan.tintColor = hexStringToUIColor(hex: "#1d47f1")
        button_finan.setImage(image_visitar_web, for: .normal)
        button_finan.tintColor = Colors.gray
        
      
        
    }
    
    func load_data(){
        showGifIndicator(view: self.view)
        let array_parameter = ["idUniversidad":self.idUniversidad]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method: "GetDetallesUniversidad", doneFunction: callback_load_data)
    }
    
    func callback_load_data(status: Int, response: AnyObject){
        var json = JSON(response)
        hiddenGifIndicator(view: self.view)
        if status == 1{
            set_data(data: JSON(json["Data"]))
        }
    }
    
    func set_data(data:JSON){
        self.data = data
        self.title = "Univ"
        
        label_name1.text = data["nbUniversidad"].stringValue
        label_logo2.text = data["nbUniversidad"].stringValue
        
        set_photo(url: data["pathLogo"].stringValue, image: image_logo1)
        set_photo(url: data["pathLogo"].stringValue, image: image_logo2)
        
        label_address.text = generate_address(address: JSON(data["Direcciones"]))
        label_phone.text = data["desTelefono"].stringValue
        label_url.text = data["desSitioWeb"].stringValue
        label_email.text = data["desCorreo"].stringValue
        
        description_uni.text = data["desUniversidad"].stringValue
        
        // Paquete
        setup_package(package: JSON(data["VentasPaquetes"][0]))
        
        // Postulado
        self.list_licenciaturas = data["Licenciaturas"].arrayValue as NSArray
        
        // Slider
        self.list_images = data["FotosUniversidades"].arrayValue as NSArray
        self.page_control.numberOfPages = self.list_images.count
        set_image_slider()
    }
    
    // Paquete
    func setup_package(package: JSON){
        var paquete = JSON(package["Paquete"])
        
        
        
        
        let fgAplicaLogo = paquete["fgAplicaLogo"].boolValue
        let fgAplicaDireccion = paquete["fgAplicaDireccion"].boolValue
        let fgAplicaUbicacion = paquete["fgAplicaUbicacion"].boolValue
        let fgAplicaProspectusVideo = paquete["fgAplicaProspectusVideo"].boolValue
        let fgAplicaProspectusVideos = paquete["fgAplicaProspectusVideos"].boolValue
        
        
        let fgAplicaBecas = paquete["fgAplicaBecas"].boolValue
        if !false{
            print("No Aplica Becas")
            view_beca.isHidden = true
            view_beca_ct_heigth.constant = 0
        }
        
        let fgAplicaFinanciamiento = paquete["fgAplicaFinanciamiento"].boolValue
        if !false{
            print("No Aplica Finan")
            view_finan.isHidden = true
            view_finan_ct_heigth.constant = 0
        }
        
        let fgProspectus = paquete["fgProspectus"].boolValue
        if !false{
            print("No Aplica Prospectus")
            view_prospectus.isHidden = true
            view_prospectus_ct_heigth.constant = 0
        }
        
        let fgAplicaImagenes = paquete["fgAplicaImagenes"].boolValue
        if !false{
            print("No Aplica Imagenes")
            view_slider.isHidden = true
            view_slider_ct_height.constant = 0
        }
        
        let fgAplicaPostulacion = paquete["fgAplicaPostulacion"].boolValue
        if false{
            print("No Aplica Redes")
            
            //Botones Flotantes
            let postularse = ActionButtonItem(title: "Postularse", image: #imageLiteral(resourceName: "ic_notification_green"))
            postularse.action = { item in self.self.on_click_postulate_() }
            
            actionButton = ActionButton(attachedToView: self.view, items: [postularse])
            actionButton.setTitle("+", forState: UIControlState())
            actionButton.backgroundColor = UIColor(red: 57.0/255.0, green: 142.0/255.0, blue: 49.0/255.0, alpha: 1)
            actionButton.action = { button in button.toggleMenu()}
        }
        
        
        let fgAplicaContacto = paquete["fgAplicaContacto"].boolValue
        if !false{
            print("No Aplica Contacto")
            view_contacto.isHidden = true
            view_contacto_ct_height.constant = 0
        }
        
        let fgAplicaFavoritos = paquete["fgAplicaFavoritos"].boolValue
        if !false{
            print("No Aplica Favoritos")
            button_favorit2.isHidden = true
        }
        
        let fgAplicaRedes = paquete["fgAplicaRedes"].boolValue
        if !false{
            print("No Aplica Redes")
            view_redes.isHidden = true
            view_redes_ct_height.constant = 0
        }
        
        let fgAplicaDescripcion = paquete["fgAplicaDescripcion"].boolValue
        if !fgAplicaDescripcion{
            print("No Aplica Descripcion")
            view_description.isHidden = true
            view_description_ct_height.constant = 0
        }

    }
    
    // Slider
    func setup_slider(){
        count_current = 0
        let directions: [UISwipeGestureRecognizerDirection] = [.up, .down, .right, .left]
        
        for direction in directions {
            swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe_slider(_:)))
            image_slide.addGestureRecognizer(swipeGesture)
            swipeGesture.direction = direction
            image_slide.isUserInteractionEnabled = true
            image_slide.isMultipleTouchEnabled = true
        }
    }
    
    @objc func swipe_slider(_ sender : UISwipeGestureRecognizer){
        UIView.animate(withDuration: 1.0) {
            
            if sender.direction == .left {
                if (self.count_current >= (self.list_images.count - 1)){
                    self.count_current = 0;
                }else{
                    self.count_current = self.count_current + 1
                }
            }else if sender.direction == .right{
                if (self.count_current <= 0){
                    self.count_current = self.list_images.count - 1
                }else{
                    self.count_current = self.count_current - 1
                }
            }
            
            self.page_control.currentPage = self.count_current
            self.set_image_slider()
            self.image_slide.layoutIfNeeded()
            self.image_slide.setNeedsDisplay()
        }
    }
    
    func set_image_slider(){
        if self.list_images.count > 0 {
            let image_item = self.list_images[self.count_current]
            var image = JSON(image_item)
            set_photo(url:image["desRutaFoto"].stringValue, image: self.image_slide)
        }
    }
    
    
    // Favorito
    func set_favorito(){
        // Set Favorito
        let array_parameter = [
            "idUniversidad": idUniversidad!,
            "idPersona": Defaults[.academic_idPersona]!
            ]  as [String : Any]
        
        debugPrint(array_parameter)
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.VerificarFavorito(parameters: parameter_json_string!, doneFunction: VerificarFavorito)
    }
    
    func VerificarFavorito(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        var json = JSON(response)
        var data = JSON(json["Data"])
        debugPrint(json)
        if status == 1{
            let image = UIImage(named: "ic_action_star")?.withRenderingMode(.alwaysTemplate)
            button_favorit2.setImage(image, for: .normal)
        }else{
            let image = UIImage(named: "ic_action_star_border")?.withRenderingMode(.alwaysTemplate)
            button_favorit2.setImage(image, for: .normal)
        }
        
    }
    
    @IBAction func on_click_favorit(_ sender: Any) {
        print("Favoritos")
        showGifIndicator(view: self.view)
        let array_parameter = [
            "idUniversidad": idUniversidad,
            "idPersona": Defaults[.academic_idPersona]!
            ] as [String : Any]
        
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.SetFavorito(parameters: parameter_json_string!, doneFunction: SetFavorito)
    }
    
    func SetFavorito(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        var json = JSON(response)
        var data = JSON(json["Data"])
        debugPrint(json)
        if status == 1{
            if  data["idFavoritos"].intValue == 0{
                let image = UIImage(named: "ic_action_star_border")?.withRenderingMode(.alwaysTemplate)
                button_favorit2.setImage(image, for: .normal)
            }else{
                let image = UIImage(named: "ic_action_star")?.withRenderingMode(.alwaysTemplate)
                button_favorit2.setImage(image, for: .normal)
            }
        }else{
            let image = UIImage(named: "ic_action_star_border")?.withRenderingMode(.alwaysTemplate)
            button_favorit2.setImage(image, for: .normal)
        }
        
    }
    
    
    // Postulado
    func on_click_postulate_(){
        print("Postulado")
        let alert = UIAlertController(title: "Seleccione programa académico de interés.", message: nil, preferredStyle: .actionSheet)
        
        if (list_licenciaturas.count > 0){
            for i in 0 ..< list_licenciaturas.count {
                
                let item = JSON(self.list_licenciaturas[i])
                let nbLicenciatura = item["nbLicenciatura"].stringValue
                let idLicenciatura = item["idLicenciatura"].intValue
                
                let action = UIAlertAction(title: nbLicenciatura, style: .default, handler: {(action) in
                    self.selected_postulate(name:nbLicenciatura, idLicenciatura: idLicenciatura )
                })
                alert.addAction(action)
            }
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            showMessage(title: "No se cuenta con programas académicos para postularse", automatic: true)
        }
    }
    
    func selected_postulate(name: String, idLicenciatura: Int){
        print("Postulado Metodo: \(name)")
        
        let idPersona = Defaults[.academic_idPersona]!
        let have_name = Defaults[.academic_name] != ""
        let have_email = Defaults[.academic_email] != ""
        
        //if  (false){
        if  (idPersona > 0 && have_name && have_email){
            showGifIndicator(view: self.view)
            let array_parameter = [
                "idPostuladoUniversidad": 0,
                "idUniversidad": idUniversidad,
                "idPersona": idPersona,
                "idLicenciatura": idLicenciatura
                ] as [String : Any]
            
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.PostularseUniversidad(parameters: parameter_json_string!, doneFunction: PostularseLicenciatura)
        }else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileAcademicViewControllerID") as! ProfileAcademicViewController
            vc.is_postulate = 1
            self.show(vc, sender: nil)
        }
    }
    
    func PostularseLicenciatura(status: Int, response: AnyObject){
        var json = JSON(response)
        if status == 1{
            showMessage(title: json["Mensaje"].stringValue, automatic: true)
        }else{
            showMessage(title: response as! String, automatic: true)
        }
        hiddenGifIndicator(view: self.view)
    }
    
    
    // Eventos
    func set_events(){
        let event_on_click_facebook:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_facebook))
        facebook.isUserInteractionEnabled = true
        facebook.addGestureRecognizer(event_on_click_facebook)
        
        let event_on_click_twitter:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_twitter))
        twitter.isUserInteractionEnabled = true
        twitter.addGestureRecognizer(event_on_click_twitter)
        
        let event_on_click_instagram:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_instagram))
        instagram.isUserInteractionEnabled = true
        instagram.addGestureRecognizer(event_on_click_instagram)
    
    }
    
    @objc func on_click_facebook(){
        print("Facebook: \(self.data["urlFaceBook"].stringValue)")
        open(scheme: self.data["urlFaceBook"].stringValue)
    }
    
    @objc func on_click_twitter(){
        print("twitter")
        open(scheme: self.data["urlTwitter"].stringValue)
    }
    
    @objc func on_click_instagram(){
        print("instagram")
        open(scheme: self.data["urlInstagram"].stringValue)
    }
    
    @IBAction func on_click_prospectus(_ sender: Any) {
        print("Prospectus")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ListViewControllerID") as! ListViewController
        vc.idUniversidad = idUniversidad
        vc.type = "prospectus"
        self.show(vc, sender: nil)
    }
    
    @IBAction func on_click_becas(_ sender: Any) {
        print("Becas")
        let vc = storyboard?.instantiateViewController(withIdentifier: "CardViewControllerID") as! CardViewController
        vc.idUniversidad = idUniversidad
        vc.type = "becas"
        self.show(vc, sender: nil)
    }
    
    @IBAction func on_click_finan(_ sender: Any) {
        print("Finan")
        let vc = storyboard?.instantiateViewController(withIdentifier: "CardViewControllerID") as! CardViewController
        vc.idUniversidad = idUniversidad
        vc.type = "financing"
        self.show(vc, sender: nil)
    }
}
