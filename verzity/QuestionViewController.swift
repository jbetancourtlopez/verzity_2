import UIKit
import SwiftyJSON
import Kingfisher

class QuestionViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    // Inputs
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    // Variables
    var webServiceController = WebServiceController()
    var items:NSArray = []
    var refreshControl = UIRefreshControl()
    var usuario = Usuario()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usuario = get_user()
        
        setup_ux()
        load_data()
        
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
        }
        
        tableView.reloadData()
        hiddenGifIndicator(view: self.view)
    }
    
    func setup_ux(){
     self.title = "Cuestionarios"
    }
    
    //Table View. -------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(items.count)
        return items.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  "Seccion "
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "cell_header") as! HeaderTableViewCell
        header.title.text = "Hola"
        header.backgroundColor = Colors.green_dark
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuestionTableViewCell
        let item = JSON(self.items[indexPath.row])
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
