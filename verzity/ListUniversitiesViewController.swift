import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults

class ListUniversitiesViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var webServiceController = WebServiceController()
    var type: String = ""
    var extranjero = false
    var items:NSArray = []
    var list_licensature:[Any] = []
    var usuario = Usuario()
    
    // Filtros de Busqueda
    var country = "";
    var state = ""
    
    var filtered:NSMutableArray = []
    var filtered_array:NSArray = []
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usuario = get_user()
        type = String(type)
        setup_ux()
        self.list_licensature = list_licensature as [Any]
        setup_table()
        setup_search_bar()
        
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        load_data()
    }

    func setup_table(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setup_search_bar(){
        searchBar.delegate = self
    }
    
    func setup_ux(){
        if  type == "find_favorit" {
            self.title = "Favoritos"
        } else if type == "find_university" {
            self.title = "Universidades"
        } else if type == "find_state"{
            self.title = "Universidades en \(self.state)"
        }
        
        self.navigationItem.leftBarButtonItem?.title = ""
        
        if !self.extranjero{
            navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "388E3C")
            searchBar.barTintColor = hexStringToUIColor(hex: "388E3C")
        }else {
            navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "F7BF25")
            searchBar.barTintColor = hexStringToUIColor(hex: "F7BF25")
        }
    }
    
    func load_data(name_university: String = ""){
        showGifIndicator(view: self.view)
        let persona = self.usuario.Persona
        
        if  type == "find_favorit" {
            
            let array_parameter: [String: Any] = [
                "idPersona": persona?.idPersona,
                "desCorreo": persona?.desCorreo,
                "idDireccion":persona?.idDireccion,
                "desTelefono":persona?.desTelefono,
                "Direcciones":[
                    "idDireccion":persona?.idDireccion
                ],
                "Dispositivos": [
                    [
                        "cvFirebase": persona?.Dispositivos?.cvFirebase,
                        "cvDispositivo": persona?.Dispositivos?.cvDispositivo,
                        "idDispositivo": persona?.Dispositivos?.idDispositivo
                    ]
                ]
                ] as [String : Any]
            
            
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            
            webServiceController.sendRequest_fix_get_favoritos(parameters: parameter_json_string!, extranjero: self.extranjero, doneFunction: GetListGeneral)

            
        }
        else if type == "find_university" {
            
            var array_parameter:[String: Any] = ["extranjero": self.extranjero, "nbPais": usuario.Persona?.Direcciones?.nbPais]
            
            if  name_university != "" {
                array_parameter = ["nombreUniversidad": name_university, "extranjero": self.extranjero, "nbPais": usuario.Persona?.Direcciones?.nbPais]
            }
            
            if list_licensature.count > 0{
                array_parameter = [
                    "nombreUniversidad": name_university,
                    "Licenciaturas": list_licensature,
                    "extranjero": self.extranjero,
                    "nbPais": usuario.Persona?.Direcciones?.nbPais
                ]
            }
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.BusquedaUniversidades(parameters: parameter_json_string!, doneFunction: GetListGeneral)
        
        }
        else if type == "find_state"{
            
            //self.extranjero
            
            let array_parameter_find_state = [
                "nombreEstado": self.state,
                "nbPais": self.country,
                "extranjero": false,
                ] as [String : Any]
            
            let parameter_json = JSON(array_parameter_find_state)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.get(parameters: parameter_json_string!, method:"BusquedaUniversidades", doneFunction: GetListGeneral)
        }
    }
    
    func GetListGeneral(status: Int, response: AnyObject){
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
            items = json["Data"].arrayValue as NSArray
        }else{
            items = []
        }
        tableView.reloadData()
        hiddenGifIndicator(view: self.view)
        
    }
    
    // Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Buscando
        //load_data(name_university: searchText)
        
        self.filtered.removeAllObjects()
        for item in items {
            var item_json = JSON(item)
            let nbUniversidad = item_json["nbUniversidad"].stringValue
            
            let name = nbUniversidad.lowercased()
            let sear = searchText.lowercased()
            
            let name_clean = name.folding(options: .diacriticInsensitive, locale: .current)
            let sear_clean = sear.folding(options: .diacriticInsensitive, locale: .current)
            
            var is_containt = name_clean.contains(sear_clean)
            if  (is_containt){
                print(nbUniversidad)
                print(searchText)
                
                print("Entro")
                self.filtered.add(item)
            }
        }
        
        self.filtered_array = self.filtered
        self.tableView.reloadData()
    }
    
    
    //Table View. -------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        var count:Int
        if (searchBar.text != ""){
            count = self.filtered_array.count
        }else{
            count = self.items.count
        }
        
        if count == 0 {
            empty_data_tableview(tableView: tableView)
            return 0
        }else{
            tableView.backgroundView = nil
            return count
        }
        
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
        //var item_university = JSON(items[indexPath.section])
        
        
        var item_university:JSON
        if (searchBar.text != ""){
            item_university = JSON(filtered_array[indexPath.section])
        }else{
            item_university = JSON(items[indexPath.section])
        }
        
        
        //Nombre
        cell.name.text  = item_university["nbUniversidad"].stringValue
        // Imagen
        var pathImage = item_university["pathLogo"].stringValue
        pathImage = pathImage.replacingOccurrences(of: "~", with: "")
        pathImage = pathImage.replacingOccurrences(of: "\\", with: "")
        
        let desRutaMultimedia = Defaults[.desRutaMultimedia]!

        let url =  "\(desRutaMultimedia)\(pathImage)"
        let URL = Foundation.URL(string: url)
        let image_default = UIImage(named: "default.png")
        cell.icon.kf.setImage(with: URL, placeholder: image_default)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let university = items[indexPath.section]
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailUniversity3ViewControllerID") as! DetailUniversity3ViewController
        let university_json = JSON(university)
        vc.idUniversidad = university_json["idUniversidad"].intValue
        self.show(vc, sender: nil)
    }
}
