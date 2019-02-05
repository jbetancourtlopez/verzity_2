import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults


protocol DetailBuyViewControllerDelegate: class {
    func okButtonTapped(is_summary:Int)
}

class DetailBuyViewController: BaseViewController {
    
    // outlet
    @IBOutlet var alertView: UIView!
    @IBOutlet var date_top: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var vigency: UILabel!
    @IBOutlet var price: UILabel!
    
    // data
    var webServiceController = WebServiceController()
    var info: AnyObject!
    var is_summary = 0
    var is_paquete_asesor = 0
    
    var delegate: DetailBuyViewControllerDelegate?
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateView()
        set_data()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func set_data(){
        debugPrint(info)
        
        if (is_summary == 1) {
            
            let usuario = get_user()
            var data = JSON(info)
            print(data)
            
            if  self.is_paquete_asesor == 1{
                let paquete_asesor = usuario.Persona?.VestasPaquetesAsesores
                print(paquete_asesor)
                date_top.text = get_date_complete(date_complete_string: (paquete_asesor?.feVenta)! )
                vigency.text = get_date_complete(date_complete_string: (paquete_asesor?.feVigencia)!)
                
                name.text = data["desPaquete"].stringValue
                price.text = String(format: "$ %.02f MXN", data["dcCosto"].doubleValue)
                
            }else{
                
                let paquete = usuario.Persona?.Universidades?.VestasPaquetes
                
                date_top.text = get_date_complete(date_complete_string: (paquete!.feVenta) )
                vigency.text = get_date_complete(date_complete_string: (paquete?.feVigencia)!)
                
                name.text = paquete?.Paquete?.nbPaquete  //data["nbPaquete"].stringValue
                price.text = String(format: "$ %.02f MXN", data["dcCosto"].doubleValue)
            }
           
        } else{
            
            if  self.is_paquete_asesor == 1{
                var json = JSON(info)
                var data = JSON(json["Data"])
                var PaquetesAsesores = JSON(data["PaquetesAsesores"])
                
                date_top.text = get_date_complete(date_complete_string: data["feVenta"].stringValue)
                vigency.text = get_date_complete(date_complete_string: data["feVigencia"].stringValue)
                name.text = PaquetesAsesores["nbPaquete"].stringValue
                price.text = String(format: "$ %.02f MXN", PaquetesAsesores["dcCosto"].doubleValue)
                
            }else{
                var json = JSON(info)
                var data = JSON(json["Data"])
                date_top.text = get_date_complete(date_complete_string: data["feVenta"].stringValue)
                vigency.text = get_date_complete(date_complete_string: data["feVigencia"].stringValue)
                var paquete = JSON(data["Paquete"])
                name.text = paquete["nbPaquete"].stringValue
                price.text = String(format: "$ %.02f MXN", paquete["dcCosto"].doubleValue)
            }
        }
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 2
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }

    @IBAction func on_click_ok(_ sender: Any) {
        delegate?.okButtonTapped(is_summary: is_summary)
        self.dismiss(animated: true, completion: nil)
    }
}
