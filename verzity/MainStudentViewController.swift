//
//  MainStudentViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 05/11/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftyUserDefaults

class MainStudentViewController: BaseViewController{
    
    // Inputs
    @IBOutlet var view_university: UIView!
    @IBOutlet var view_examen: UIView!
    @IBOutlet var view_becas: UIView!
    @IBOutlet var view_extranjero: UIView!
    
    // Variables
    var sidebarView: SidebarView!
    var blackScreen: UIView!
    var webServiceController = WebServiceController()
    var menu_main = Menus.menu_main_academic
    weak var delegate:SidebarViewDelegate?
    var have_paquete = 1
    var profile_menu:String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ux()
        menu_main = Menus.menu_main_academic  as [AnyObject] as! [[String : String]]

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("notificationFCM"), object: nil)
    
        //Eventos
        
        let event_on_click_university:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_university))
        view_university.addGestureRecognizer(event_on_click_university)
        
        let event_on_click_becas:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_becas))
        view_becas.addGestureRecognizer(event_on_click_becas)
        
        let event_on_click_examen:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_examen))
        view_examen.addGestureRecognizer(event_on_click_examen)
        
        let event_on_click_extranjero:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.on_click_extranjero))
        view_extranjero.addGestureRecognizer(event_on_click_extranjero)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = Colors.Color_universidades
        UINavigationBar.appearance().backgroundColor = Colors.Color_universidades
    }
    
    
    @objc func on_click_university(){
        print("University")
        let vc = storyboard?.instantiateViewController(withIdentifier: "FindUniversityViewControllerID") as! FindUniversityViewController
        vc.type = "find_university"
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
    }
    
    @objc func on_click_extranjero(){
        print("Extranjero")
    }
    
    @IBAction func on_click_cupones(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CardViewControllerID") as! CardViewController
        vc.type = "coupons"
        self.show(vc, sender: nil)
    }
    
    @IBAction func on_click_financiamientos(_ sender: Any) {
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
    
    
    
    
    
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        let menu_selected = menu_main[indexPath.row]["type"]
        switch String(menu_selected!) {
        case "find_university": //Promociones
            print("find_university")
     
            break
        case "becas":
            print("becas")
     
            break
        case "financing": //comunicados
            print("financing")
     
            break
        case "coupons": //Eventos
            print("coupons")
     
            break
        case "travel": //Eventos
            print("travel")
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "DetailMapViewControllerID") as! DetailMapViewController
            self.show(vc, sender: nil)
 
            //showMessage(title: "En proceso ...", automatic: true)
            break
        case "package": //Eventos
            print("package")
            let vc = storyboard?.instantiateViewController(withIdentifier: "PackagesViewControllerID") as! PackagesViewController
            self.show(vc, sender: nil)
            break
        case "postulate": //Eventos
            print("postulate")
            let vc = storyboard?.instantiateViewController(withIdentifier: "PostuladoViewControllerID") as! PostuladoViewController
            self.show(vc, sender: nil)
            break
        default:
            break
        }
    }
 */
    
    // ---------------
    
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
                let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationsViewControllerID") as! NotificationsViewController
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
                cerrarSesion()
                break
   
            default:
                break
        }
    }
    
    func cerrarSesion(){
        showGifIndicator(view: self.view)
        let array_parameter = [
            "cvDispositivo": Defaults[.cvDispositivo]!,
            "cvFirebase": Defaults[.cvFirebase]!,
            "idDispositivo": Defaults[.idDispositivo]!
            ] as [String : Any]
        
        debugPrint(array_parameter)
        
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.CerrarSesion(parameters: parameter_json_string!, doneFunction: cerrarSesion)
    }
    
    func cerrarSesion(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        if status == 1{
           sigout()
        }
    }
    
}

