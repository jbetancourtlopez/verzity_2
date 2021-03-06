import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults

class QrCouponViewController: BaseViewController {

    @IBOutlet var coupon_title: UILabel!
    @IBOutlet var coupon_validez: UILabel!
    @IBOutlet var code_coupon: UILabel!
    @IBOutlet var image_qr: UIImageView!
    @IBOutlet var image_caratule: UIImageView!
    @IBOutlet var view_code_qr: UIView!
    @IBOutlet var button_canjear: UIButton!
    @IBOutlet var coupon_description: UITextView!
    
    @IBOutlet var top_cont_coupon_validez: NSLayoutConstraint!
    @IBOutlet var right_cont_view_head: NSLayoutConstraint!
    
    var idCupon: Int = 0
    var webServiceController = WebServiceController()
    var data: AnyObject!
    var qrcodeImage: CIImage!
    var actionButton : ActionButton!
    var usuario = Usuario()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usuario = get_user()
        idCupon = idCupon as Int
       
        load_data(idCupon:idCupon)
        setup_ux()
    }
    
    func load_data(idCupon:Int){
        showGifIndicator(view: self.view)
        let array_parameter = ["idCupon": idCupon]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.GetDetalleCupon(parameters: parameter_json_string!, doneFunction: GetDetalleCupon)
    }
    
    func GetDetalleCupon(status: Int, response: AnyObject){
        var json = JSON(response)
        if status == 1{
            var data = JSON(json["Data"])
            
            // Titulo
            coupon_title.text = data["nbCupon"].stringValue
            
            self.title = data["nbCupon"].stringValue
            // Código
            code_coupon.text = data["cvCupon"].stringValue
            // Fecha
            let validez = "Validez: \(get_date_complete_date(date_complete_string:data["feInicio"].stringValue)) al \(get_date_complete_date(date_complete_string:data["feFin"].stringValue))"
            coupon_validez.text = validez
            
            // Descripcion
            coupon_description.text = data["desCupon"].stringValue
            adjustUITextViewHeight(arg: coupon_description)
            
            top_cont_coupon_validez.constant = coupon_description.frame.height + 30
            right_cont_view_head.constant = coupon_description.frame.height + 50
            
            // Imagen
            var imagenesCupones = data["ImagenesCupones"].arrayValue
            var cuponImagen = JSON(imagenesCupones[0])
            
            var pathImage = cuponImagen["desRutaFoto"].stringValue
            pathImage = pathImage.replacingOccurrences(of: "~", with: "")
            pathImage = pathImage.replacingOccurrences(of: "\\", with: "")
            
            let url =  "\(Defaults[.desRutaMultimedia]!)\(pathImage)"
            print(url)
            let URL = Foundation.URL(string: url)
            let image = UIImage(named: "default.png")
            
            image_caratule.kf.setImage(with: URL, placeholder: image)
            
            
        }else{
            showMessage(title: response as! String, automatic: true)
        }
        hiddenGifIndicator(view: self.view)
    }
    
    func setup_ux(){
        view_code_qr.isHidden = true
        
        
        actionButton = ActionButton(attachedToView: self.view, items: [])
        actionButton.backgroundColor = UIColor(red: 127.0/255.0, green: 3.0/255.0, blue:5.0/255.0, alpha: 1)
        actionButton.action = { item in self.self.on_click_change() }
        actionButton.setImage(UIImage(named:"ic_action_cupon"), forState: UIControlState())
    }
    
    func on_click_change(){
        
       
        
        showGifIndicator(view: self.view)
        let idPersona = self.usuario.Persona?.idPersona
        let array_parameter = [
            "idCupon": idCupon,
            "idPersona": idPersona
            ] as [String : Any]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.CanjearCupon(parameters: parameter_json_string!, doneFunction: CanjearCupon)
        
    }
    
    @IBAction func on_click_canjear_cupon(_ sender: Any) {
        showGifIndicator(view: self.view)
        var idPersona = self.usuario.Persona?.idPersona
        let array_parameter = [
            "idCupon": idCupon,
            "idPersona": idPersona
            ] as [String : Any]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.CanjearCupon(parameters: parameter_json_string!, doneFunction: CanjearCupon)
   
    }
    
    func CanjearCupon(status: Int, response: AnyObject){
        let json = JSON(response)
        debugPrint(json)
        if status == 1{
            //button_canjear.isHidden = true
            actionButton.backgroundColor = UIColor(red: 127.0/255.0, green: 3.0/255.0, blue:5.0/255.0, alpha: 0)
            actionButton.setImage(nil, forState: UIControlState())
            actionButton.action = { item in print("Nada") }

            
            view_code_qr.isHidden = false
            generate_qr(qr: code_coupon.text!)
            
        }else{
            showMessage(title: response as! String, automatic: true)
        }
        hiddenGifIndicator(view: self.view)

    }
    
    func generate_qr(qr: String){
        
        if qrcodeImage == nil {
            let data = qr.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter?.outputImage
            //image_qr.image = UIImage(ciImage: (qrcodeImage!))
            
           displayQRCodeImage()
        }else {
            image_qr.image = nil
            qrcodeImage = nil
        }
    }
    
    func displayQRCodeImage() {
        let scaleX = image_qr.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = image_qr.frame.size.height / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        image_qr.image = UIImage(ciImage: transformedImage)
    }
    
    
   
    

  
}
