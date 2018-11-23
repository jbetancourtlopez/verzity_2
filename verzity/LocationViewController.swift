import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults

class LocationViewController: BaseViewController,  UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Inputs
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    // Variables
    var webServiceController = WebServiceController()
    var type: String = ""
    var country = ""
    let list = ["Uno"]
    
    var list_countries: NSArray = []
    var list_states: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ux()
        load_data_country()
    }
    
    func setup_ux(){
        
        if type == "prospectus"{
            self.title = "local"
        }else if type == "extra"{
            self.title = ""
        }
    }
    
    func load_data_country(){
        showGifIndicator(view: self.view)
        let array_parameter = ["": ""]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method: "GetPaises", doneFunction:callback_load_data_country)
        
    }
    
    func callback_load_data_country(status: Int, response: AnyObject){
        var json = JSON(response)
        if status == 1{
            list_countries = json["Data"].arrayValue as NSArray
        }
        pickerView.reloadAllComponents()
        hiddenGifIndicator(view: self.view)
    }
    
    func load_data_states(country:JSON){
        showGifIndicator(view: self.view)
     
        let parameter_json_string = country.rawString()
        webServiceController.get(parameters: parameter_json_string!, method: "GetEstados", doneFunction:callback_load_data_states)
        
    }
    
    func callback_load_data_states(status: Int, response: AnyObject){
        var json = JSON(response)
        print(json)
        if status == 1{
            list_states = json["Data"].arrayValue as NSArray
        }else{
            list_states = []
        }
        tableView.reloadData()
        hiddenGifIndicator(view: self.view)
    }
    
    // Tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = list_states.count
        
        if count == 0 {
            empty_data_tableview(tableView: tableView, string: "No se encontraron elementos1.", color: "FFFFFF")
            return 0
        }else{
            tableView.backgroundView = nil
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default , reuseIdentifier: "cell")
        
        var item = JSON(list_states[indexPath.row])
        
        cell.textLabel?.text = item["nbEstado"].stringValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var item = JSON(list_states[indexPath.row])
        
       
            

        
        print("find_state")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ListUniversitiesViewControllerID") as! ListUniversitiesViewController
        vc.country = self.country
        vc.state = item["nbEstado"].stringValue
        vc.type = "find_state"
        self.show(vc, sender: nil)
        
    }
    // PickerView
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(list_countries[row])
        load_data_states(country: JSON(list_countries[row]))
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var item = JSON(list_countries[row])
        self.country = item["nbPais"].stringValue
        return item["nbPais"].stringValue
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list_countries.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    

}