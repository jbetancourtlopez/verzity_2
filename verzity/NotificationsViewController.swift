import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults

class NotificationsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var webServiceController = WebServiceController()
    var items: NSArray = []
    var refreshControl = UIRefreshControl()
    var type = ""
    var usuario = Usuario()
    
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.items = []
        self.tableView.reloadData()
        
        if self.type == "student_notify"{
            load_notifications_student()
        }else{
            load_notifications()
        }
        
    }

    @objc func handleRefresh() {
        self.items = []
        self.tableView.reloadData()
        load_notifications_student()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func load_notifications(){
        let array_parameter = [
            "desCorreo": usuario.Persona?.desCorreo,
            "idPersona": usuario.Persona?.idPersona,
            "idDireccion": usuario.Persona?.idDireccion,
            "nbCompleto": usuario.Persona?.nbCompleto,
            "desTelefono": usuario.Persona?.desTelefono,
            "Dispositivos": [
                [
                    "cvDispositivo": usuario.Persona?.Dispositivos?.cvDispositivo,
                    "cvFirebase": usuario.Persona?.Dispositivos?.cvFirebase,
                    "idDispositivo": usuario.Persona?.Dispositivos?.idDispositivo
                ]
            ]
        ] as [String : Any]
        
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.ConsultarNotificaciones(parameters: parameter_json_string!, doneFunction: ConsultarNotificaciones)
    }
    
    func load_notifications_student(){
        let array_parameter = [
            "desCorreo": usuario.Persona?.desCorreo,
            "idPersona": usuario.Persona?.idPersona,
            "idDireccion": usuario.Persona?.idDireccion,
            "nbCompleto": usuario.Persona?.nbCompleto,
            "desTelefono": usuario.Persona?.desTelefono,
            "Dispositivos": [
                [
                    "cvDispositivo": usuario.Persona?.Dispositivos?.cvDispositivo,
                    "cvFirebase": usuario.Persona?.Dispositivos?.cvFirebase,
                    "idDispositivo": usuario.Persona?.Dispositivos?.idDispositivo
                ]
            ]
            ] as [String : Any]
     
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method:"ConsultarNotificacionesUniversitario", doneFunction: ConsultarNotificaciones)
    }
    
    func ConsultarNotificaciones(status: Int, response: AnyObject){
        var json = JSON(response)
        print(json)
        hiddenGifIndicator(view: self.view)
        if status == 1{
            items = json["Data"].arrayValue as NSArray
        }
        tableView.reloadData()
    }
    
    func setup_ux(){
        showGifIndicator(view: self.view)
        self.title = "Notificaciones"
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
        
        var notificacionEstatusList = JSON(item["NotificacionEstatus"])
        var notificacionEstatus = JSON(notificacionEstatusList[0])
        var status = JSON(notificacionEstatus["Estatus"])
        
        var feRegistro = item["feRegistro"].stringValue
        var feRegistro_array = feRegistro.components(separatedBy: "T")
        
        var hourRegistro = feRegistro_array[1]
        var hourRegistro_array = hourRegistro.components(separatedBy: ".")
        hourRegistro = hourRegistro_array[0]
        
        let date = get_date_complete(date_complete_string: item["feRegistro"].stringValue)
        let day = get_day_of_week(today: feRegistro_array[0])

        cell.title_notification.text = item["desAsunto"].stringValue + " - " + day + " " + date
        
        if status["desEstatus"].stringValue == "PENDIENTE"{
            cell.title_notification.font = UIFont.boldSystemFont(ofSize: 14.0)
            cell.image_notification.image = UIImage(named: "ic_notification_green")
        }else{
            cell.title_notification.font = UIFont.systemFont(ofSize: 14.0)
            cell.image_notification.image = UIImage(named: "ic_action_notifications")
        }
        cell.description_notificaction.text = item["desMensaje"].stringValue
        
        //Icono
        cell.image_notification.image = cell.image_notification.image?.withRenderingMode(.alwaysTemplate)
        cell.image_notification.tintColor = Colors.green_dark
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var item = JSON(items[indexPath.section])
        let idNotificacion = item["idNotificacion"].intValue
        
        print(item)
        
        if self.type == "student_notify"{
            
            ActrualizarStatusNotE(idNotificacion:idNotificacion)
            
            print("Abrir examen")
            print(item["idDiscriminador"].intValue)
        
            let vc = storyboard?.instantiateViewController(withIdentifier: "QuizViewControllerID") as! QuizViewController
            vc.idEvaluacion = item["idDiscriminador"].intValue
            vc.idEvaluacionPersona = item["idPersonaEnvia"].intValue
            self.show(vc, sender: nil)
            

        }else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewControllerID") as! DetailViewController
            vc.idNotificacion = idNotificacion
            vc.type = "notificacion"
            self.show(vc, sender: nil)
        }
 
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
