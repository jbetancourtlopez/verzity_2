//
//  PostuladoViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 03/07/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftyUserDefaults


class PostuladoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var webServiceController = WebServiceController()
    var items:NSArray = []
    var sections: NSMutableArray = []
    
    var list_licensature: [Any] = []
    var list_becas: [Any] = []
    var list_financing: [Any] = []
    var list_postulate: [Any] = []
    var list_sections: [String] = []
    
     var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 60
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
        let array_parameter = ["idUniversidad": Defaults[.university_idUniveridad]]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.GetPostulados(parameters: parameter_json_string!, doneFunction: GetList)
    }
    
    func GetList(status: Int, response: AnyObject){
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
            items = json["Data"].arrayValue as NSArray
            
            for item in items{
                
                var item_json = JSON(item)
                let nombreSeccion = item_json["NombreSeccion"].stringValue
                
                if  !item_json["licenciatura"].isEmpty {
                    print("Entro a Licenciatura")
                    let item = [
                        "person" : JSON(item_json["persona"]),
                        "NombreSeccion" : JSON(item_json["NombreSeccion"]),
                        
                        "fechaPostulacion": item_json["fechaPostulacion"].stringValue,
                        "type_name": "licenciatura",
                        "type":  JSON(item_json["licenciatura"])
                    ]  as [String : Any]
                    list_licensature.append(item)
                    
                }
                else if  !item_json["beca"].isEmpty {
                    let item = [
                        "person" : JSON(item_json["persona"]),
                         "NombreSeccion" : JSON(item_json["NombreSeccion"]),
                        "fechaPostulacion": item_json["fechaPostulacion"].stringValue,
                        "type_name": "beca",
                        "type": JSON(item_json["beca"])
                        ] as [String : Any]
                    list_becas.append(item)
                    
                } else if  !item_json["financiamiento"].isEmpty {
                    let item = [
                        "person" : JSON(item_json["persona"]),
                         "NombreSeccion" : JSON(item_json["NombreSeccion"]),
                         "fechaPostulacion": item_json["fechaPostulacion"].stringValue,
                         "type_name": "financiamiento",
                         "type": JSON(item_json["financiamiento"])
                        ] as [String : Any]
                    list_financing.append(item)
                }
            }
            
            
            if list_licensature.count > 0 {
                list_postulate.append(list_licensature)
                list_sections.append("Programas académicos")
            }
            
            if  list_becas.count > 0 {
                list_postulate.append(list_becas)
                list_sections.append("Becas")
            }
            
            if list_financing.count > 0 {
                list_postulate.append(list_financing)
                list_sections.append("Financiamientos")
            }
            
            
            
        }
        tableView.reloadData()
        hiddenGifIndicator(view: self.view)
    }

    
    func setup_ux(){
        self.navigationItem.leftBarButtonItem?.title = ""
        showGifIndicator(view: self.view)
    }
    
    //Table View. -------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.list_sections.count == 0 {
            empty_data_tableview(tableView: tableView)
            return 0
        }else{
            tableView.backgroundView = nil
            return self.list_sections.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section_item = self.list_postulate[section] as! [Any]
        return section_item.count // count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as! HeaderTableViewCell
        header.title.text = self.list_sections[section]
        header.backgroundColor = Colors.green_dark
        return header
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostuladosTableViewCell
     
        let section_item = self.list_postulate[indexPath.section] as! [Any]
        let row = section_item[indexPath.row]
        let row_json = JSON(row)
        
        let fecha_postulacion = row_json["fechaPostulacion"].stringValue
        let person = JSON(row_json["person"])
        let type = JSON(row_json["type"])
        let type_name = JSON(row_json["type_name"])
        
        
        
        
        var postulate_date_array = fecha_postulacion.components(separatedBy: "T")
        
        cell.postulate_date.text = postulate_date_array[0]
        cell.postulate_day.text = get_day_of_week(today: postulate_date_array[0])
        cell.postulate_name_academic.text = person["nbCompleto"].stringValue
        
        var postulate_name = ""
        if type_name == "licenciatura"{
            debugPrint(type)
            var catNivelEstudios = JSON(type["CatNivelEstudios"])
            
            let nbNivelEstudios = catNivelEstudios["nbNivelEstudios"].stringValue
            print(nbNivelEstudios)
            
            postulate_name = "\(type["nbLicenciatura"].stringValue) - \(nbNivelEstudios)"
            
            print(postulate_name)
            
        } else  if type_name == "beca" {
            postulate_name = type["nbBeca"].stringValue
        } else  if type_name == "financiamiento" {
            postulate_name = type["nbFinanciamiento"].stringValue
        }
        
        
        cell.postulate_university.text = postulate_name
           
        //https://stackoverflow.com/questions/44663217/swift-change-the-tableviewcell-border-color-according-to-data
        
        cell.clipsToBounds = true
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 2
        cell.layer.borderWidth = 2
        cell.layer.shadowOffset = CGSize(width:1, height:-20)
        let borderColor: UIColor = Colors.green_dark
        cell.layer.borderColor = borderColor.cgColor

        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let section_item = self.list_postulate[indexPath.section] as! [Any]
        let row = section_item[indexPath.row]
        //let row_json = JSON(row)

        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewControllerID") as! DetailViewController
        vc.type = "postulado"
        vc.detail = row as AnyObject
        self.show(vc, sender: nil)
    }
    
    
 


}
