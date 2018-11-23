import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults

class ListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // Inputs
    @IBOutlet weak var tableView: UITableView!
    
    // Variables
    var webServiceController = WebServiceController()
    var type: String = ""
    
    var list_prospectus = Menus.list_prospectus
    var list_postulation = Menus.list_postulation
    var list_academics: NSArray = []
    var idUniversidad: Int!
    var fgAplicaProspectusVideos: Bool!
    var fgAplicaProspectusVideo: Bool!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        type = String(type)
        setup_ux()
        load_data()
    }
  
    func setup_ux(){
        
        if type == "prospectus"{
           self.title = "Prospectus"
        }else if type == "academics"{
            self.title = "Seleccionar nivel académico"
        }else if type == "postulation" {
            self.title = "Seleccionar tipo postulación"
        }
    }
    
    func load_data(){
        if type == "prospectus"{
            
            list_prospectus = Menus.list_prospectus_folletos  as [AnyObject] as! [[String : String]]

            if  self.fgAplicaProspectusVideo || self.fgAplicaProspectusVideos{
                list_prospectus = Menus.list_prospectus  as [AnyObject] as! [[String : String]]
            }
        }else if type == "academics"{
            showGifIndicator(view: self.view)
            let array_parameter = ["": ""]
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.get(parameters: parameter_json_string!, method: Singleton.GetNivelesAcademicos, doneFunction:callback_load_data)
        }else if type == "postulation" {
            list_postulation = Menus.list_postulation  as [AnyObject] as! [[String : String]]
        }
    }
    
    func callback_load_data(status: Int, response: AnyObject){
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
            list_academics = json["Data"].arrayValue as NSArray
        }
        tableView.reloadData()
        hiddenGifIndicator(view: self.view)
    }
    
    //Table View. -------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        
        if type == "prospectus"{
            count = list_prospectus.count
        }else if type == "academics"{
           count = list_academics.count
        }else if type == "postulation"{
            count = list_postulation.count
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell
        
        if type == "prospectus"{
            list_prospectus = Menus.list_prospectus  as [AnyObject] as! [[String : String]]
            // Name
            cell.name.text  = list_prospectus[indexPath.section]["name"]
            
            // Image
            cell.icon.image = UIImage(named: list_prospectus[indexPath.section]["image"]!)
            cell.icon.image = cell.icon.image?.withRenderingMode(.alwaysTemplate)
            cell.icon.tintColor = hexStringToUIColor(hex: list_prospectus[indexPath.section]["color"]!)
        }else if type == "academics"{
            var item:JSON
            item = JSON(list_academics[indexPath.section])
            
            let name = item["nbNivelEstudios"].stringValue
            cell.name.text = name
            cell.name.numberOfLines = 3
            cell.name.font = UIFont.systemFont(ofSize: 13.0) //systemFontSize(size:14.0) //systemFontOfSize(16.0);
            
            // Image
            cell.icon.image = UIImage(named: "ic_mortarboard")
            cell.icon.image = cell.icon.image?.withRenderingMode(.alwaysTemplate)
            //cell.icon.tintColor = hexStringToUIColor(hex: list_prospectus[indexPath.section]["color"]!)
        }else if type == "postulation"{
            // Name
            cell.name.text  = list_postulation[indexPath.section]["name"]
            
            // Image
            cell.icon.image = UIImage(named: list_postulation[indexPath.section]["image"]!)
            cell.icon.image = cell.icon.image?.withRenderingMode(.alwaysTemplate)
            cell.icon.tintColor = hexStringToUIColor(hex: list_postulation[indexPath.section]["color"]!)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Click")
        
        if type == "prospectus"{
            let option = list_prospectus[indexPath.section]["type"]
            
            switch String(option!) {
            case "videos":
                print("Videos")
                let vc = storyboard?.instantiateViewController(withIdentifier: "VideoViewControllerID") as! VideoViewController
                vc.idUniversidad = idUniversidad
                self.show(vc, sender: nil)
                break
            case "digital":
                print("Digital")
                openUrl(scheme: "http://www.google.com")
                break
            default:
                break
            }
        }else if type == "academics"{
            print("Academicos")
            var item = JSON(list_academics[indexPath.section])
            let vc = storyboard?.instantiateViewController(withIdentifier: "ListAcademicsViewControllerID") as! ListAcademicsViewController
            vc.nbNivelEstudios = item["nbNivelEstudios"].stringValue
            vc.idCatNivelEstudios = item["idCatNivelEstudios"].intValue
            self.show(vc, sender: nil)
        }else if type == "postulation"{
            print("Postulados")
            
            let option = list_postulation[indexPath.section]["type"]
            
            switch String(option!) {
            case "becas":
                print("Becas")
                let vc = storyboard?.instantiateViewController(withIdentifier: "PostuladoViewControllerID") as! PostuladoViewController
                vc.tipo = 2
                self.show(vc, sender: nil)
                break
            case "finan":
                print("Financiamietos")
                let vc = storyboard?.instantiateViewController(withIdentifier: "PostuladoViewControllerID") as! PostuladoViewController
                vc.tipo = 3
                self.show(vc, sender: nil)
                break
            case "universidad":
                print("Universidad")
                let vc = storyboard?.instantiateViewController(withIdentifier: "PostuladoViewControllerID") as! PostuladoViewController
                vc.tipo = 1
                self.show(vc, sender: nil)
                
                break
            default:
                break
            }
        }

        
    }
    


}
