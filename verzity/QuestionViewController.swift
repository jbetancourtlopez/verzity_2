import UIKit
import SwiftyJSON
import Kingfisher

class QuestionViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,  UISearchBarDelegate {

    // Inputs
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    // Variables
    var webServiceController = WebServiceController()
    var items:NSArray = []
    var refreshControl = UIRefreshControl()
    var usuario = Usuario()
    var sections: NSMutableArray = []
    var actionButton : ActionButton!
    var search = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usuario = get_user()
        
        setup_ux()
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(handleRefresh), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        load_data()
    }
    
    @objc func handleRefresh() {
        load_data()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func load_data(){
        showGifIndicator(view: self.view)
        let array_parameter = ["idPersona": usuario.Persona?.idPersona] as [String : Any]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method: "getEvaluaciones", doneFunction: callback_load_data)
    }
    
    func callback_load_data(status: Int, response: AnyObject){
        var json = JSON(response)
        print(json)
        items = []
        if status == 1{
            self.items = json["Data"].arrayValue as NSArray
            build_data()
        }
        
    
        hiddenGifIndicator(view: self.view)
    }
    
    func setup_ux(){
        self.title = "Cuestionarios"
        
        navigationController?.navigationBar.barTintColor = Colors.Color_examen
        search_bar.barTintColor = Colors.Color_examen
        
        let postularse = ActionButtonItem(title: "Consultar paquetes", image: #imageLiteral(resourceName: "ic_notification_green"))
        postularse.action = { item in self.self.on_click_asesor() }
        
        actionButton = ActionButton(attachedToView: self.view, items: [postularse])
        actionButton.setTitle("+", forState: UIControlState())
        actionButton.backgroundColor = UIColor(red: 255.0/255.0, green: 157.0/255.0, blue: 0.0/255.0, alpha: 1)
        actionButton.action = { button in button.toggleMenu()}
    }
    
    func on_click_asesor(){
        print("Paquetes Asesor")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ListAsesorPaqueteViewControllerID") as! ListAsesorPaqueteViewController
        self.show(vc, sender: nil)
    }
    
    //Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.search = searchText
        build_data()
    }
    
    func build_data(){
        
        let sear = self.search.lowercased()
        let sear_clean = sear.folding(options: .diacriticInsensitive, locale: .current)
        
        var list_no_pay:[Any] = []
        var list_pay:[Any] = []
        
        for item in self.items{
            var item_json = JSON(item)
            var evaluacion = JSON(item_json["Evaluaciones"])
            var is_pay = evaluacion["idPruebaAplica"].intValue
            var name = evaluacion["nbEvaluacion"].stringValue
            name = name.lowercased()
            let name_clean = name.folding(options: .diacriticInsensitive, locale: .current)
        
            if sear == ""{
                if is_pay == 0{
                    list_no_pay.append(item)
                }else{
                    list_pay.append(item)
                }
            } else{
                var is_containt = name_clean.contains(sear_clean)
                if  (is_containt){
                    if is_pay == 0{
                        list_no_pay.append(item)
                    }else{
                        list_pay.append(item)
                    }
                }
            }
        }
        
        sections[0] = list_no_pay
        sections[1] = list_pay
        self.tableView.reloadData()
    }
    
    //Table View. -------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("section: \(section)")
        let section_item = JSON(sections[section])
        let count = section_item.count
        print(count)
        return count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  "Seccion "
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "cell_header") as! HeaderTableViewCell
        
        if section == 0{
           header.title.text = "BÁSICO"
        }else{
             header.title.text = "DE PAGA"
        }
        
       
        header.backgroundColor = Colors.green_dark
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuestionTableViewCell
        
        let list = JSON(sections[indexPath.section])

        
        let item = JSON(list[indexPath.row])
        let estatus = JSON(item["Estatus"])
        let evaluaciones = JSON(item["Evaluaciones"])
        
        let idEstatus = estatus["idEstatus"].intValue
        
        
        if (idEstatus == 7){
            cell.buton_start.setTitle("PRESENTAR", for: UIControlState.normal)
            cell.buton_start.backgroundColor = hexStringToUIColor(hex: "ff9d00")
        } else if (idEstatus == 9) {
            cell.buton_start.setTitle("VER RESULTADO", for: UIControlState.normal)
            cell.buton_start.backgroundColor = hexStringToUIColor(hex: "00600F")
        }else if (idEstatus == 8) {
            cell.buton_start.setTitle("CONTINUAR", for: UIControlState.normal)
            cell.buton_start.backgroundColor = hexStringToUIColor(hex: "FF0000")
        }
        
        cell.status.text = estatus["desEstatus"].stringValue
        cell.title.text = evaluaciones["nbEvaluacion"].stringValue
        
        cell.buton_start.addTarget(self, action: #selector(self.on_click_start), for:.touchUpInside)
        cell.buton_start.tag = indexPath.row
        return cell
    }
    
    @objc func on_click_start(sender: UIButton){
        let index = sender.tag
    
        let item = JSON(self.items[index])
        let estatus = JSON(item["Estatus"])
        
        let idEstatus = estatus["idEstatus"].intValue
        
        if idEstatus != 9{
            let vc = storyboard?.instantiateViewController(withIdentifier: "QuizViewControllerID") as! QuizViewController
            vc.question = item
            self.show(vc, sender: nil)
        }else{
            print("Abrir Modal")
            
            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "QuestionResultViewControllerID") as! QuestionResultViewController
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.delegate = self
            customAlert.question = item
            self.present(customAlert, animated: true, completion: nil)
        }
    }
}

extension QuestionViewController: QuestionResultViewControllerDelegate{
    func closeButtonTapped() {
        print("Close Button")
    }
}
