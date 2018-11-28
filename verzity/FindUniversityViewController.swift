import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults

class FindUniversityViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    // Inputs
    @IBOutlet var page_control: UIPageControl!
    @IBOutlet var image: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var container_image: UIView!
    @IBOutlet var contrains_height: NSLayoutConstraint!
    
    // Variables
    var webServiceController = WebServiceController()
    let menu_main = Menus.menu_find_university
    var type_menu: String = ""
    var list_data: AnyObject!
    var items:NSArray = []
    var is_register_visit = false
    var extanjero = false
    
    var timer: Timer!
    var updateCounter: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ux()
        
        if self.type_menu == "find_university_extra"{
            self.extanjero = true
        }
        
        //Evento Imagen Banner
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        load_banners()
        self.navigationItem.leftBarButtonItem?.title = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }


    // Evento al hacer click sobre un Banner
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        
        if(!self.is_register_visit){
            self.is_register_visit = true
            if items.count > 0 {
                do {
                    print("Count:\(updateCounter)")
                    print("total: \(items.count)")
                    // Registramos la Visista
                    showGifIndicator(view: self.view)
                    var  banner_item = JSON(items[updateCounter - 1])
                    let array_parameter = [
                        "idBanner": banner_item["idBanner"].intValue,
                        "idPersona": Defaults[.academic_idPersona]
                        
                        ] as [String : Any]
                    let parameter_json = JSON(array_parameter)
                    let parameter_json_string = parameter_json.rawString()
                    webServiceController.RegistrarVisitaBanners(parameters: parameter_json_string!, doneFunction: RegistrarVisitaBanners)
                } catch let error {
                    print(error.localizedDescription)
                }
            }else{
                print("Error")
            }
        }
    }
    
    func RegistrarVisitaBanners(status: Int, response: AnyObject){
        hiddenGifIndicator(view: self.view)
        self.is_register_visit = false
        if status == 1{
            var  banner_item = JSON(items[updateCounter - 1])
            let url = banner_item["desSitioWeb"].stringValue
            if FormValidate.validateUrl(urlString: url as NSString){
                openUrl(scheme: url)
            }else{
                showMessage(title: "No cuenta con sitio web.", automatic: true)
            }
        }
    }
    
    func load_banners(){
        showGifIndicator(view: self.view)
        let array_parameter = ["": ""]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.GetBannersVigentes(parameters: parameter_json_string!, doneFunction: getBanners)
   
    }
    
    func getBanners(status: Int, response: AnyObject){
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
             hiddenGifIndicator(view: self.view)
            list_data = json["Data"].arrayValue as Array as AnyObject
            items = json["Data"].arrayValue as NSArray
            updateTimer()
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(FindUniversityViewController.updateTimer), userInfo: nil, repeats: true)
        }
        
        if  items.count == 0{
            container_image.isHidden = true
            contrains_height.constant = 0
        }
        hiddenGifIndicator(view: self.view)
    }
    
    func setup_ux(){
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "Univ."
        updateCounter = 0
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    // Timer de los Banners de Universidades
    @objc internal func updateTimer(){
        if (updateCounter < (items.count)){
            page_control.currentPage = updateCounter

            let banner_data = items[updateCounter]
            var banner = JSON(banner_data)
            
            var pathImage = banner["desRutaFoto"].stringValue
            pathImage = pathImage.replacingOccurrences(of: "~", with: "")
            pathImage = pathImage.replacingOccurrences(of: "\\", with: "")
            
            let desRutaMultimedia = Defaults[.desRutaMultimedia]!
            
            let url =  "\(desRutaMultimedia)\(pathImage)"
            let URL = Foundation.URL(string: url)
            let image_default = UIImage(named: "default.png")
            image?.kf.setImage(with: URL, placeholder: image_default)
            updateCounter = updateCounter + 1
            
            register_visor_banner(banner: banner)
            
        }else{
            updateCounter = 0;
        }
    }
    
    
    func register_visor_banner(banner:JSON){
        let array_parameter = ["idBanner": banner["idBanner"].intValue]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method: "RegistrarVisorBanners", doneFunction: callback_register_visor_banner)
    }
    
    func callback_register_visor_banner(status: Int, response: AnyObject){
        //print(response)
        print("Registrar Visita")
    }
    
    //Table View. -------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.menu_main.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell
        var menu_item = JSON(menu_main[indexPath.section])
        
        cell.icon.image = UIImage(named: menu_item["image"].stringValue)
        cell.name.text = menu_item["name"].stringValue
        cell.icon.image = cell.icon.image?.withRenderingMode(.alwaysTemplate)
        cell.icon.tintColor = hexStringToUIColor(hex: menu_main[indexPath.section]["color"]!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let menu_selected = menu_main[indexPath.section]["type"]
        
        switch String(menu_selected!) {
        case "find_university": //Promociones
            print("find_university")
            let vc = storyboard?.instantiateViewController(withIdentifier: "ListUniversitiesViewControllerID") as! ListUniversitiesViewController
            vc.type = menu_selected!
            vc.extranjero = self.extanjero
            self.show(vc, sender: nil)
            break
        case "find_academics":
            // let vc = storyboard?.instantiateViewController(withIdentifier: "ListAcademicsViewControllerID") as! ListAcademicsViewController
            // //vc.type = menu_selected!
            // self.show(vc, sender: nil)

            print("Academicos")
            let vc = storyboard?.instantiateViewController(withIdentifier: "ListViewControllerID") as! ListViewController
            vc.idUniversidad = 0
            vc.type = "academics"
            self.show(vc, sender: nil)

            break
        case "find_next_to_me": //comunicados
            print("find_next_to_me")
            let vc = storyboard?.instantiateViewController(withIdentifier: "FindMapViewControllerID") as! FindMapViewController
            vc.type = menu_selected!
            self.show(vc, sender: nil)
            break
        case "find_euu": //Eventos
            print("location")
            let vc = storyboard?.instantiateViewController(withIdentifier: "LocationViewControllerID") as! LocationViewController
            vc.type = self.type_menu
            self.show(vc, sender: nil)
            break
        case "find_favorit": //Eventos
            print("find_favorit")
            let vc = storyboard?.instantiateViewController(withIdentifier: "ListUniversitiesViewControllerID") as! ListUniversitiesViewController
            vc.type = menu_selected!
            vc.extranjero = self.extanjero
            self.show(vc, sender: nil)
            break
        default:
            break
        }
    }
    

}
