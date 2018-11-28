import UIKit
import SwiftyJSON
import SwiftyUserDefaults

class MainViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    // Sidebar
    var sidebarView: SidebarView!
    weak var delegate:SidebarViewDelegate?
    var blackScreen: UIView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    var webServiceController = WebServiceController()
    var profile_menu:String = ""
    var menu_main = Menus.menu_main_university
    var have_paquete = 1
    var usuario = Usuario()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usuario = get_user()
        setup_ux()
        
        have_paquete = have_paquete as Int
        validate_package()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("notificationFCM"), object: nil)
        
        print(usuario)
    
    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        print("Notificacion recibida ")

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
    
    func validate_package(){
        
        var idPaquete = self.usuario.Persona?.Universidades?.VestasPaquetes?.idPaquete
        if  idPaquete == 0{
            let vc = storyboard?.instantiateViewController(withIdentifier: "PackagesViewControllerID") as! PackagesViewController
            self.show(vc, sender: nil)
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
    
    // Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menu_main.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellUniversity", for: indexPath) as! CollectionViewCell

        let name = menu_main[indexPath.row]["name"]
        let image = menu_main[indexPath.row]["image"]
        
        cell.name.text = name
        cell.icon.image = UIImage(named: image!)
        cell.icon.image = cell.icon.image?.withRenderingMode(.alwaysTemplate)
        cell.icon.tintColor = hexStringToUIColor(hex: menu_main[indexPath.row]["color"]!)

        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        let menu_selected = menu_main[indexPath.row]["type"]
        switch String(menu_selected!) {
        case "package": //Eventos
            print("package")
            let vc = storyboard?.instantiateViewController(withIdentifier: "PackagesViewControllerID") as! PackagesViewController
            self.show(vc, sender: nil)
            break
        case "postulate": //Eventos
            print("Postulado")

            let vc = storyboard?.instantiateViewController(withIdentifier: "ListViewControllerID") as! ListViewController
            vc.idUniversidad = 0
            vc.type = "postulation"
            self.show(vc, sender: nil)
            
            break
        default:
            break
        }
    }
    
    // ---------------
    
    @objc func blackScreenTapAction(sender: UITapGestureRecognizer) {
        blackScreen.isHidden=true
        blackScreen.frame=self.view.bounds
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 0, height: self.sidebarView.frame.height)
        }
    }
    
    func setup_ux(){
        
        self.title = "Inicio"
        
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.barTintColor = Colors.Color_universidades

        print ("UX Cell Universidad")
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 3, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        layout.itemSize = CGSize(width: self.view.frame.size.width - 10, height: 58)
        self.collectionView?.setCollectionViewLayout(layout, animated: false)
        
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

extension MainViewController: SidebarViewDelegate {
    
    func sidebarDidSelectRow(item: AnyObject) {
        // Oculto el Menu Side
        blackScreen.isHidden=true
        blackScreen.frame=self.view.bounds
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 0, height: self.sidebarView.frame.height)
        }
        let menu_side_selected = JSON(item)
        switch String(menu_side_selected["type"].stringValue) {
            case "profile_representative": //Promociones
                print("profile_representative")
                let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileAcademicViewControllerID") as! ProfileAcademicViewController
                vc.type = "profile_representative"
                self.show(vc, sender: nil)
                break
            case "profile_university":
                print("profile_university")
                let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileUniversityViewControllerID") as! ProfileUniversityViewController
                self.show(vc, sender: nil)
                break
            case "notifications":
                print("notifications")
                let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationTabBarID") as! UITabBarController
                self.show(vc, sender: nil)
                
        
                break
            case "profile_academic":
                print("profile_academic")
                let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileAcademicViewControllerID") as! ProfileAcademicViewController
                vc.type = "profile_academic"
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
