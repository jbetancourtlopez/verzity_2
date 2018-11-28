import UIKit
import SwiftyJSON
import SwiftyUserDefaults

class ListAsesorPaqueteViewController:BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var webServiceController = WebServiceController()
    var items:NSMutableArray = []
    var selected_idPaquete = 0;
    var have_package = false
    var refreshControl = UIRefreshControl()
    var usuario = Usuario()
    var idPaqueteAsesor: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ux()
        load_data()
        self.usuario = get_user()
        self.idPaqueteAsesor = self.usuario.Persona?.VestasPaquetesAsesores?.idPaqueteAsesor
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(handleRefresh), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        self.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        load_data()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.layoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    func load_data(){
        let array_parameter = ["": ""]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method: "GetPaquetesAsesoresDisponibles", doneFunction: GetPaquetesDisponibles)
    }
    
    func GetPaquetesDisponibles(status: Int, response: AnyObject){
        var json = JSON(response)
        if status == 1{
            self.items = []
            tableView.reloadData()
            let list_items = json["Data"].arrayValue
            for i in 0..<list_items.count{
                var item = JSON(list_items[i])
                
                if item["idPaqueteAsesor"].intValue == self.idPaqueteAsesor{
                    have_package = true
                    self.items.add(item)
                }
            }
            
            for i in 0..<list_items.count{
                var item = JSON(list_items[i])
                
                if item["idPaqueteAsesor"].intValue != self.idPaqueteAsesor{
                    self.items.add(item)
                }
            }
        }
        tableView.reloadData()
        hiddenGifIndicator(view: self.view)
    }
    
    func setup_ux(){
        self.title = "Paquetes asesores"
    }
    
    //Table View. -------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.items.count == 0 {
            empty_data_tableview(tableView: tableView)
            return 0
        }else{
            tableView.backgroundView = nil
            return self.items.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PackageTableViewCell
        
        var item = JSON(items[indexPath.section])
        debugPrint(item)
        
        //Evento al Boton
        cell.button_buy.addTarget(self, action: #selector(self.on_click_buy), for:.touchUpInside)
        cell.button_buy.tag = indexPath.section
        
        // Precio
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        //let amount = item["dcCosto"].doubleValue
        //let formattedString = formatter.string(for: amount)
        cell.price.text = String(format: "$ %.02f MXN", item["dcCosto"].doubleValue)
        
        cell.title_top.text = item["nbPaquete"].stringValue
        cell.vigency.text = "\(item["dcDiasVigencia"].stringValue) días de vigencia. "
        cell.description_package.text = item["desPaquete"].stringValue
        
        // Cuestionarios
        let cuestionarios = item["numCuestionariosLiberados"].stringValue
        cell.label_financing.text = "Cuestionarios a liberar: \(cuestionarios)"
        
        cell.button_buy.setTitle("COMPRAR", for: .normal)
        cell.button_buy.isEnabled = true
        
        if item["idPaqueteAsesor"].intValue == self.idPaqueteAsesor!{
           cell.button_buy.setTitle("PAQUETE ACTUAL", for: .normal)
        }
        
        // setup_ux
        cell.clipsToBounds = true
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 2
        cell.layer.borderWidth = 4
        cell.layer.shadowOffset = CGSize(width:1, height:-20)
        let borderColor: UIColor = Colors.green_dark
        cell.layer.borderColor = borderColor.cgColor
        
        return cell
    }
    
    @objc func on_click_buy(sender: UIButton){
        print("Comprar")
        let index = sender.tag
        var package = JSON(self.items[index])
        
        if package["idPaqueteAsesor"].intValue == self.idPaqueteAsesor{
            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "DetailBuyViewControllerID") as! DetailBuyViewController
            customAlert.info = package as AnyObject
            customAlert.is_paquete_asesor = 1
            customAlert.is_summary = 1
            
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.delegate = self
            self.present(customAlert, animated: true, completion: nil)
        }else{
            
            
            if (self.idPaqueteAsesor! > 0){
                let yesAction = UIAlertAction(title: "Aceptar", style: .default) { (action) -> Void in
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListAsesorSelectedViewControllerID") as! ListAsesorSelectedViewController
                    vc.package = self.items[index] as AnyObject
                    self.show(vc, sender: nil)
                }
                
                let cancelAction = UIAlertAction(title: "Cancelar", style: .default) { (action) -> Void in
                }
                
                showAlert("Atención", message: "Ya cuenta con un paquete activo. ¿Desea actualizarlo?", okAction: yesAction, cancelAction: cancelAction, automatic: false)
            }else{
                let vc = storyboard?.instantiateViewController(withIdentifier: "ListAsesorSelectedViewControllerID") as! ListAsesorSelectedViewController
                vc.package = self.items[index] as AnyObject
                self.show(vc, sender: nil)
            }
        }
        
       
    }
}

extension ListAsesorPaqueteViewController: DetailBuyViewControllerDelegate {
    func okButtonTapped(is_summary:Int) {
        if  is_summary == 0{
            if  (Defaults[.university_idUniveridad]! <= 0 || Defaults[.university_desTelefono] == "" ||  Defaults[.university_desUniversidad] == ""){
                let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileUniversityViewControllerID") as! ProfileUniversityViewController
                self.show(vc, sender: nil)
                
            }else{
                let vc = storyboard?.instantiateViewController(withIdentifier: "Main") as! MainViewController
                self.show(vc, sender: nil)
            }
        }
    }
}
