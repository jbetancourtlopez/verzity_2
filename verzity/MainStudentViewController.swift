import UIKit
import SwiftyJSON
import SwiftyUserDefaults

class MainStudentViewController: BaseViewController{
    
    // Inputs
    @IBOutlet var view_university: UIView!
    @IBOutlet var view_examen: UIView!
    @IBOutlet var view_becas: UIView!
    @IBOutlet var view_extranjero: UIView!
    @IBOutlet var view_cupones: UIView!
    @IBOutlet var view_financiamientos: UIView!
    // Variables
    var sidebarView: SidebarView!
    var blackScreen: UIView!
    var webServiceController = WebServiceController()
    var menu_main = Menus.menu_main_academic
    weak var delegate:SidebarViewDelegate?
    var have_paquete = 1
    var profile_menu:String = ""
    var usuario: Usuario = Usuario()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ux()
        menu_main = Menus.menu_main_academic  as [AnyObject] as! [[String : String]]

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("notificationFCM"), object: nil)
        usuario = get_user()
        
        //Eventos
        let event_on_click_university:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_university))
        view_university.addGestureRecognizer(event_on_click_university)
        
        let event_on_click_becas:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_becas))
        view_becas.addGestureRecognizer(event_on_click_becas)
        
        let event_on_click_examen:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_examen))
        view_examen.addGestureRecognizer(event_on_click_examen)
        
        let event_on_click_extranjero:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_extranjero))
        view_extranjero.addGestureRecognizer(event_on_click_extranjero)
        
        let event_on_click_cupones:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_cupones))
        view_cupones.addGestureRecognizer(event_on_click_cupones)
        
        let event_on_click_financiamiento:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_financiamientos))
        view_financiamientos.addGestureRecognizer(event_on_click_financiamiento)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = Colors.Color_universidades
        UINavigationBar.appearance().backgroundColor = Colors.Color_universidades
    }
    
    
    @objc func on_click_university(){
        print("University")
        let vc = storyboard?.instantiateViewController(withIdentifier: "FindUniversityViewControllerID") as! FindUniversityViewController
        vc.type_menu = "find_university_local"
        self.show(vc, sender: nil)
    }
    
    @objc func on_click_becas(){
        print("Becas")
        let vc = storyboard?.instantiateViewController(withIdentifier: "CardViewControllerID") as! CardViewController
        vc.type = "becas"
        self.show(vc, sender: nil)
    }
    
    @objc func on_click_examen(){
        print("Examen")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "QuestionViewControllerID") as! QuestionViewController
        self.show(vc, sender: nil)
    }
    
    @objc func on_click_extranjero(){
        print("University")
        let vc = storyboard?.instantiateViewController(withIdentifier: "FindUniversityViewControllerID") as! FindUniversityViewController
        vc.type_menu = "find_university_extra"
        self.show(vc, sender: nil)
    }
    
    @objc func on_click_cupones(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "CardViewControllerID") as! CardViewController
        vc.type = "coupons"
        self.show(vc, sender: nil)
    }
    
    @objc func on_click_financiamientos(){
        print("Financiamientos")
        let vc = storyboard?.instantiateViewController(withIdentifier: "CardViewControllerID") as! CardViewController
        vc.type = "financing"
        self.show(vc, sender: nil)
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification){

        var userInfo = notification.userInfo
        
        let datas = userInfo!["data"] as? NSDictionary
        
        let msg = datas!["msg"] as! String
        
        let dataToConvert = msg.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        var encodedString : NSData = (msg as NSString).data(using: String.Encoding.utf8.rawValue)! as NSData

        let json = JSON(encodedString)
        
        var not = JSON(msg)
     
        var idNotificacion = json["idNotificacion"].intValue
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewControllerID") as! DetailViewController
        vc.idNotificacion = idNotificacion
        vc.type = "notificacion"
        self.show(vc, sender: nil)
    }
    
    @objc func blackScreenTapAction(sender: UITapGestureRecognizer) {
        blackScreen.isHidden=true
        blackScreen.frame=self.view.bounds
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 0, height: self.sidebarView.frame.height)
        }
    }
    
    //On_click_Side_Menu
    @IBAction func on_click_slide_menu(_ sender: Any) {
        blackScreen.isHidden=false
        UIView.animate(withDuration: 0.3, animations: {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 250, height: self.sidebarView.frame.height)
        }) { (complete) in
            self.blackScreen.frame=CGRect(x: self.sidebarView.frame.width, y: 0, width: self.view.frame.width-self.sidebarView.frame.width, height: self.view.bounds.height+100)
            self.sidebarView.myTableView.reloadData()
        }
    }
    
    func setup_ux(){
        
        self.title = "Inicio"
        
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.barTintColor = Colors.Color_universidades

        //SideBar
        sidebarView=SidebarView(frame: CGRect(x: 0, y: 0, width: 0, height: self.view.frame.height))
        sidebarView.delegate=self
        sidebarView.layer.zPosition=100
        self.view.isUserInteractionEnabled=true
        self.navigationController?.view.addSubview(sidebarView)
        
        blackScreen=UIView(frame: self.view.bounds)
        blackScreen.backgroundColor=UIColor(white: 0, alpha: 0.5)
        blackScreen.isHidden=true
        self.navigationController?.view.addSubview(blackScreen)
        blackScreen.layer.zPosition=99
        let tapGestRecognizer = UITapGestureRecognizer(target: self, action: #selector(blackScreenTapAction(sender:)))
        blackScreen.addGestureRecognizer(tapGestRecognizer)
    }
    
    func sigout(){
        self.delete_session()
        _ = self.navigationController?.popToRootViewController(animated: false)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginNavigationControllerID") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
}

extension MainStudentViewController: SidebarViewDelegate {
  
    func sidebarDidSelectRow(item: AnyObject) {
        // Oculto el Menu Side
        blackScreen.isHidden=true
        blackScreen.frame=self.view.bounds
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 0, height: self.sidebarView.frame.height)
        }
        let menu_side_selected = JSON(item)
        switch String(menu_side_selected["type"].stringValue) {
            case "student_profile":
                print("student_profile")
                let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileAcademicViewControllerID") as! ProfileAcademicViewController
                vc.type = "student_profile"
                self.show(vc, sender: nil)
                break

            case "student_asesor":
                print("student_asesor")
                
                let vc = storyboard?.instantiateViewController(withIdentifier: "ListAsesorViewControllerID") as! ListAsesorViewController
                self.show(vc, sender: nil)
                
                break
            case "student_notify":
                print("student_notify")
                let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationsViewControllerID") as! NotificationsViewController
                vc.type = "student_notify"
                self.show(vc, sender: nil)
                break
            case "notifications":
                print("notifications")
                let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationsViewControllerID") as! NotificationsViewController
                self.show(vc, sender: nil)
                break
            
            case "sigout":
                print("Salir")
                CerrarSesion()
                break
   
            default:
                break
        }
    }
    
    func CerrarSesion(){
        showGifIndicator(view: self.view)
        let array_parameter = [
            "cvDispositivo": Defaults[.cvDispositivo]!,
            "cvFirebase": Defaults[.cvFirebase]!,
            "idDispositivo": self.usuario.Persona?.Dispositivos?.idDispositivo,
            ] as [String : Any]

        print(array_parameter)
                
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.CerrarSesion(parameters: parameter_json_string!, doneFunction: callback_CerrarSesion)
    }
    
    func callback_CerrarSesion(status: Int, response: AnyObject){
        print("response: \(response)")
        hiddenGifIndicator(view: self.view)
        if status == 1{
           sigout()
        }
    }
    
}

