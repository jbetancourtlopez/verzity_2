//
//  DetailUniversityViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 26/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults


class DetailUniversity2ViewController: BaseViewController {

    @IBOutlet var scrollView: UIScrollView!
    
    // Slider
    @IBOutlet var page_control: UIPageControl!
    @IBOutlet var image_slider: UIImageView!
    
    //Nombre
    @IBOutlet var name_universitity: UILabel!
    
    // Favorito
    @IBOutlet var button_favorit: UIButton!
    
    // Direccion
    @IBOutlet var image_address: UIImageView!
    @IBOutlet var label_address: UILabel!
    @IBOutlet var button_address: UIButton!
    
    // Telefono
    @IBOutlet var image_phone: UIImageView!
    @IBOutlet var label_phone: UILabel!
    
    // Web
    @IBOutlet var image_web: UIImageView!
    @IBOutlet var label_web: UILabel!
    
    // Email
    @IBOutlet var image_email: UIImageView!
    @IBOutlet var label_email: UILabel!
    
    // Prospetus
    @IBOutlet var image_prospectus: UIImageView!
    @IBOutlet var label_prospectus: UILabel!
    @IBOutlet var button_prospectus: UIButton!
    
    // Beca
    @IBOutlet var image_beca: UIImageView!
    @IBOutlet var label_beca: UILabel!
    @IBOutlet var button_beca: UIButton!
    
    // Financiamiento
    @IBOutlet var image_financing: UIImageView!
    @IBOutlet var label_financing: UILabel!
    @IBOutlet var button_financing: UIButton!
    
    @IBOutlet var image_financing_top_contrain: NSLayoutConstraint!
    @IBOutlet var button_financing_top_contrains: NSLayoutConstraint!
    @IBOutlet var label_financing_top_constrains: NSLayoutConstraint!
    
    // Descripcion
    @IBOutlet var description_university: UITextView!
    
    
    // Variables
    var swipeGesture = UISwipeGestureRecognizer()
    var webServiceController = WebServiceController()
    var list_images: NSArray = []
    var list_licenciaturas: NSArray = []
    var count_current = 0
    var idUniversidad: Int!
    var detail_data: AnyObject!
    var selected_postulate: String = ""
    var actionButton : ActionButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // idUniversidad = idUniversidad as Int
        setup_ux()
        load_data()
        set_favorito()
        
        // //Gestos
        // count_current = 0
        // let directions: [UISwipeGestureRecognizerDirection] = [.up, .down, .right, .left]
        
        // for direction in directions {
        //     swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.on_gesture_photos(_:)))
        //     image_slider.addGestureRecognizer(swipeGesture)
        //     swipeGesture.direction = direction
        //     image_slider.isUserInteractionEnabled = true
        //     image_slider.isMultipleTouchEnabled = true
        // }
    }
    
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

    func load_data(){
        showGifIndicator(view: self.view)
        let array_parameter = ["idUniversidad": idUniversidad]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.GetDetallesUniversidad(parameters: parameter_json_string!, doneFunction: callback_load_data)
    }
   
    func callback_load_data(status: Int, response: AnyObject){
        var json = JSON(response)
        hiddenGifIndicator(view: self.view)
        if status == 1{
            self.detail_data = JSON(json["Data"]) as AnyObject
            let data = JSON(json["Data"])
            self.list_images = data["FotosUniversidades"].arrayValue as NSArray
            self.list_licenciaturas = data["Licenciaturas"].arrayValue as NSArray
            //self.page_control.numberOfPages = self.list_images.count
            set_image_slider()
            set_data()
        }
    }
    
    @objc func on_gesture_photos(_ sender : UISwipeGestureRecognizer){
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
            
            //self.page_control.currentPage = self.count_current
            self.set_image_slider()
            self.image_slider.layoutIfNeeded()
            self.image_slider.setNeedsDisplay()
        }
    }
    
    func set_image_slider(){
        if self.list_images.count > 0 {
            let image_item = self.list_images[self.count_current]
            var image = JSON(image_item)
            var pathImage = image["desRutaFoto"].stringValue
            pathImage = pathImage.replacingOccurrences(of: "~", with: "")
            pathImage = pathImage.replacingOccurrences(of: "\\", with: "")
            
            let desRutaMultimedia = Defaults[.desRutaMultimedia]!
            let url =  "\(desRutaMultimedia)\(pathImage)"
            let URL = Foundation.URL(string: url)
            let image_default = UIImage(named: "default.png")
            self.image_slider.kf.setImage(with: URL, placeholder: image_default)
        }
    }
    
    @IBAction func on_click_financing(_ sender: Any) {
        print("Financing")
        let vc = storyboard?.instantiateViewController(withIdentifier: "CardViewControllerID") as! CardViewController
        vc.idUniversidad = idUniversidad
        vc.type = "financing"
        self.show(vc, sender: nil)
    }
    
    @IBAction func on_click_prospectus(_ sender: Any) {
        print("Prospectus")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ListViewControllerID") as! ListViewController
        vc.idUniversidad = idUniversidad
        vc.type = "prospectus"
        self.show(vc, sender: nil)
    }
    
    
    @IBAction func on_click_beca(_ sender: Any) {
        print("beca")
        let vc = storyboard?.instantiateViewController(withIdentifier: "CardViewControllerID") as! CardViewController
        vc.idUniversidad = idUniversidad
        vc.type = "becas"
        self.show(vc, sender: nil)
    }
    
    
    
    @IBAction func on_click_map(_ sender: Any) {
        print("mapa")
        let university_json = JSON(self.detail_data)
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailMapViewControllerID") as! DetailMapViewController
        vc.info = university_json as AnyObject
        self.show(vc, sender: nil)
    }
    
    @IBAction func on_click_postulate(_ sender: Any) {
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

    @IBAction func on_click_favorit(_ sender: Any) {
        print("Favorit")
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
        
        var json = JSON(response)
        var data = JSON(json["Data"])
        debugPrint(json)
        if status == 1{
            if  data["idFavoritos"].intValue == 0{
                let image = UIImage(named: "ic_action_star_border")?.withRenderingMode(.alwaysTemplate)
                button_favorit.setImage(image, for: .normal)
            }else{
                let image = UIImage(named: "ic_action_star")?.withRenderingMode(.alwaysTemplate)
                button_favorit.setImage(image, for: .normal)
            }
        }else{
            let image = UIImage(named: "ic_action_star_border")?.withRenderingMode(.alwaysTemplate)
            button_favorit.setImage(image, for: .normal)
        }
        hiddenGifIndicator(view: self.view)
    }
    
    func VerificarFavorito(status: Int, response: AnyObject){
        
        var json = JSON(response)
        var data = JSON(json["Data"])
        debugPrint(json)
        if status == 1{
            let image = UIImage(named: "ic_action_star")?.withRenderingMode(.alwaysTemplate)
            button_favorit.setImage(image, for: .normal)
        }else{
            let image = UIImage(named: "ic_action_star_border")?.withRenderingMode(.alwaysTemplate)
            button_favorit.setImage(image, for: .normal)
        }
        hiddenGifIndicator(view: self.view)
    }
    
    func setup_ux(){
        
        let image_visitar_web  = UIImage(named: "ic_visitar_web")?.withRenderingMode(.alwaysTemplate)
        
        // Favorito
        let image = UIImage(named: "ic_action_star_border")?.withRenderingMode(.alwaysTemplate)
        button_favorit.setImage(image, for: .normal)
        button_favorit.tintColor = hexStringToUIColor(hex: "#F7BF25")
        
        // Direccion
        image_address.image = image_address.image?.withRenderingMode(.alwaysTemplate)
        image_address.tintColor = hexStringToUIColor(hex: "#ff0106")
        
        // Phone
        image_phone.image = image_phone.image?.withRenderingMode(.alwaysTemplate)
        image_phone.tintColor = Colors.gray
        
        // Web
        image_web.image = image_web.image?.withRenderingMode(.alwaysTemplate)
        image_web.tintColor = hexStringToUIColor(hex: "#1d47f1")
        
        // Beca
        image_beca.image = image_beca.image?.withRenderingMode(.alwaysTemplate)
        image_beca.tintColor = hexStringToUIColor(hex: "#32cb00")
        button_beca.setImage(image_visitar_web, for: .normal)
        button_beca.tintColor = Colors.gray
        
        // Email
        image_email.image = image_email.image?.withRenderingMode(.alwaysTemplate)
        image_email.tintColor = hexStringToUIColor(hex: "#1d47f1")
        
        //Prospectus
        image_prospectus.image = image_prospectus.image?.withRenderingMode(.alwaysTemplate)
        image_prospectus.tintColor = hexStringToUIColor(hex: "#ff0106")
        button_prospectus.setImage(image_visitar_web, for: .normal)
        button_prospectus.tintColor = Colors.gray
        
        // Financimaineto
        image_financing.image = image_financing.image?.withRenderingMode(.alwaysTemplate)
        image_financing.tintColor = hexStringToUIColor(hex: "#ff7b25")
        button_financing.setImage(image_visitar_web, for: .normal)
        button_financing.tintColor = Colors.gray
        
        //Botones Flotantes
        let postularse = ActionButtonItem(title: "Postularse", image: #imageLiteral(resourceName: "ic_notification_green"))
        postularse.action = { item in self.self.on_click_postulate_() }
        
        actionButton = ActionButton(attachedToView: self.view, items: [postularse])
        actionButton.setTitle("+", forState: UIControlState())
        actionButton.backgroundColor = UIColor(red: 57.0/255.0, green: 142.0/255.0, blue: 49.0/255.0, alpha: 1)
        actionButton.action = { button in button.toggleMenu()}
    }
    
    func on_click_postulate_(){
        print("Postulacion")
    }
    
    func set_data(){
        self.title = "Univ"
      
        var university_json = JSON(self.detail_data)
        var address = JSON(university_json["Direcciones"])
        
        // Paquetes
        var paquete_array = university_json["VentasPaquetes"].arrayValue
        var fgAplicaBecas = false
        var fgAplicaFinanciamiento = false
        var fgAplicaPostulacion = false
        
        if  paquete_array.count > 0 {
            var paquete_json = JSON(paquete_array[0])
            
            var paquete = JSON(paquete_json["Paquete"])
            debugPrint(paquete)
            
            fgAplicaBecas = paquete["fgAplicaBecas"].boolValue
            fgAplicaFinanciamiento = paquete["fgAplicaFinanciamiento"].boolValue
            fgAplicaPostulacion = paquete["fgAplicaPostulacion"].boolValue
        }
       
        // Nombre Universidad
        var name_uniersity_text = university_json["nbUniversidad"].stringValue
        if  name_uniersity_text.isEmpty{
            name_uniersity_text = StringsLabel.no_university_name
        }
        name_universitity.text = name_uniersity_text
        
        // Direccion
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
        
        label_address.text = label_address_text
        
        // Sitio Web
        var label_web_text = university_json["desSitioWeb"].stringValue
        if  label_web_text.isEmpty{
            label_web_text = StringsLabel.no_website
        }
        label_web.text = label_web_text
        
        // Correo
        var label_email_text =  university_json["desCorreo"].stringValue
        if  label_email_text.isEmpty{
            label_email_text = StringsLabel.no_email
        }
        label_email.text = label_email_text
        
        // Telefono
        var label_phone_text = university_json["desTelefono"].stringValue
        if  label_phone_text.isEmpty{
            label_phone_text = StringsLabel.no_phone
        }
        label_phone.text = label_phone_text
        
        
        
        
        description_university.text = university_json["desUniversidad"].stringValue
//        description_university.translatesAutoresizingMaskIntoConstraints = true
//        description_university.sizeToFit()
//        let height = description_university.frame.height
//
//        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 700 + height)
//
//        let h = scrollView.frame.height
//        
//        contentBottomView.sizeToFit()
//        contentBottomView.autoresizesSubviews = true
//        contentBottomView.layoutIfNeeded()
//        contentBottomView.frame = CGRect(x:0, y:232, width:self.view.frame.width, height:5000)
        
     
        
        // Establecemos permisos
        if !fgAplicaBecas{
            image_beca.isHidden = true
            label_beca.isHidden = true
            button_beca.isHidden = true
        }
        
        if !fgAplicaFinanciamiento{
            image_financing.isHidden = true
            label_financing.isHidden = true
            button_financing.isHidden = true
        }
        
        if !fgAplicaPostulacion{
            //button_postulate.isHidden = true
        }
        
        if !fgAplicaBecas && fgAplicaFinanciamiento{
            /*
            image_beca.frame = CGRect(x: 0, y: 0, width: 50, height: 0)
            button_beca.frame = CGRect(x: 0, y: 0, width: 50, height: 0)
            label_beca.frame = CGRect(x: 0, y: 0, width: 50, height: 0)
             */
            
            // image_financing_top_contrain.constant = -35
            // button_financing_top_contrains.constant = -35
            // label_financing_top_constrains.constant = -35
        }
        
        
    }



}