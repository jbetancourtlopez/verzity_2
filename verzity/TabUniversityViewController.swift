import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults

class TabUniversityViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Inputs
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segment: UISegmentedControl!
    
    // Variables
    var webServiceController = WebServiceController()
    var items: NSMutableArray = []
    var refreshControl = UIRefreshControl()
    var usuario = Usuario()
    var segment_selected = 0;
    
    @IBOutlet weak var tab_button: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup_ux()
        self.usuario = get_user()
        
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
        //self.tabBarItem.tag
        print("buton: \(tab_button.tag)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.items = []
        tableView.reloadData()
        load_data()
    }
    
    @objc func handleRefresh() {
        self.items = []
        self.tableView.reloadData()
        load_data()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
    @IBAction func on_click_segment(_ sender: Any) {
        print("click")
        let index = segment.selectedSegmentIndex
    
        self.segment_selected = index
        load_data()
    }
    
    
    func load_data(){
        let  persona = self.usuario.Persona
        let array_parameter = [
            "desCorreo": persona?.desCorreo,
            "idPersona": persona?.idPersona,
            "idDireccion": persona?.idDireccion,
            "nbCompleto": persona?.nbCompleto ,
            "desTelefono": persona?.desTelefono,
            "Dispositivos": [
                [
                    "cvDispositivo": persona?.Dispositivos?.cvDispositivo,
                    "cvFirebase": persona?.Dispositivos?.cvFirebase,
                    "idDispositivo": persona?.Dispositivos?.idDispositivo
                ]
            ]
            ] as [String : Any]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method:"ConsultarNotificaciones", doneFunction: callback_load_data)
    }
    
    
    func callback_load_data(status: Int, response: AnyObject){
        var json = JSON(response)
        hiddenGifIndicator(view: self.view)
        if status == 1{
            self.items = []
            
            let list_items = JSON(json["Data"][tab_button.tag]["Notificaciones"]).arrayValue as NSArray
            
            for i in 0..<list_items.count{
           
                var item_i = JSON(list_items[i])
                
                var notificacionEstatusList = JSON(item_i["NotificacionEstatus"])
                var notificacionEstatus = JSON(notificacionEstatusList[0])
                var status = JSON(notificacionEstatus["Estatus"])
                
                print(status["desEstatus"].stringValue)
                
                if status["desEstatus"].stringValue == "PENDIENTE" && segment_selected == 2{
                    self.items.add(item_i)
                }else if status["desEstatus"].stringValue == "VISTO" && segment_selected == 1{
                    self.items.add(item_i)
                }else if segment_selected == 0{
                    self.items.add(item_i)
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func setup_ux(){
    }
    
    //Table View. -------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.items.count == 0 {
            empty_data_tableview(tableView: tableView)
            return 0
        }else{
            tableView.backgroundView = nil
            return  self.items.count
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationsTableViewCell
        var item = JSON(items[indexPath.section])
        
        // Estatus
        var notificacionEstatusList = JSON(item["NotificacionEstatus"])
        var notificacionEstatus = JSON(notificacionEstatusList[0])
        var status = JSON(notificacionEstatus["Estatus"])

        if status["desEstatus"].stringValue == "PENDIENTE"{
            cell.title_notification.font = UIFont.boldSystemFont(ofSize: 14.0)
            cell.image_notification.image = UIImage(named: "ic_notification_green")
        }else{
            cell.title_notification.font = UIFont.systemFont(ofSize: 14.0)
            cell.image_notification.image = UIImage(named: "ic_action_notifications")
        }

        var feRegistro = item["feRegistro"].stringValue
        var feRegistro_array = feRegistro.components(separatedBy: "T")

        var hourRegistro = feRegistro_array[1]
        var hourRegistro_array = hourRegistro.components(separatedBy: ".")
        hourRegistro = hourRegistro_array[0]

        let date = get_date_complete(date_complete_string: item["feRegistro"].stringValue)
        let day = get_day_of_week(today: feRegistro_array[0])
        cell.title_notification.text = item["desAsunto"].stringValue + " - " + day + " " + date

        cell.description_notificaction.text = item["desMensaje"].stringValue

        //Icono
        cell.image_notification.image = cell.image_notification.image?.withRenderingMode(.alwaysTemplate)
        cell.image_notification.tintColor = Colors.green_dark
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var item = JSON(items[indexPath.section])
        let idNotificacion = item["idNotificacion"].intValue
        
        ActrualizarStatusNotE(idNotificacion:idNotificacion)

        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewControllerID") as! DetailViewController
        vc.idNotificacion = idNotificacion
        vc.type = "notificacion"
        self.show(vc, sender: nil)
        
        
    }
    
    func ActrualizarStatusNotE(idNotificacion: Int){
        let array_parameter = [
            "idDispositivo": usuario.Persona?.Dispositivos?.idDispositivo,
            "idNotificacion": idNotificacion,
            ] as [String : Any]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method:"ActrualizarStatusNotE", doneFunction: Callback_ActrualizarStatusNotE)
    }
    
    func Callback_ActrualizarStatusNotE(status: Int, response: AnyObject){
        
    }
}
