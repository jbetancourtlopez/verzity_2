//
//  ListAcademicsViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 27/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class ListAcademicsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var webServiceController = WebServiceController()
    var items:NSArray = []
    var sections: NSMutableArray = []
    var list_licensature_array:[Any] = []
    
    var button_find = UIBarButtonItem()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
        let array_parameter = ["": ""]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.GetProgramasAcademicos(parameters: parameter_json_string!, doneFunction: GetList)
    }
    
    func GetList(status: Int, response: AnyObject){
        var json = JSON(response)
        if status == 1{
            items = json["Data"].arrayValue as NSArray
            for item in items{
                
                var item_json = JSON(item)
                var catNivel = JSON(item_json["CatNivelEstudios"])
                
                let indice = validar_seccion(idCatNivelEstudios: Int64(catNivel["idCatNivelEstudios"].intValue))
                if indice >= 0 {

                    let item_licensature = [
                        "idLicenciatura": item_json["idLicenciatura"].intValue,
                        "nbLicenciatura": item_json["nbLicenciatura"].stringValue,
                        "is_checked": 0
                        ] as [String : Any]
                    
                    let section_aux = sections[indice] as! NSDictionary
                    var list_licensature_aux = section_aux["list_licensature"] as! [Any]
                    
                    //list_licensature_aux[0] = item_licensature
                     
                    
                    list_licensature_aux.append(item_licensature)  // adding(item_licensature)
                    
                    let oldNivel:NSDictionary = [
                            "nbNivelEstudios": "\(catNivel["nbNivelEstudios"].stringValue)",
                            "idCatNivelEstudios":catNivel["idCatNivelEstudios"].intValue,
                            "list_licensature": list_licensature_aux
                        ]
                    sections[indice] = oldNivel
                    
                    
                }else{
                    let newNivel:NSDictionary = [
                        "nbNivelEstudios":catNivel["nbNivelEstudios"].stringValue,
                        "idCatNivelEstudios":catNivel["idCatNivelEstudios"].intValue,
                        "list_licensature": [
                                                [
                                                    "idLicenciatura": 0,
                                                    "nbLicenciatura": "Todos",
                                                    "is_checked": 0
                                                ],
                                                [
                                                    "idLicenciatura": item_json["idLicenciatura"].intValue,
                                                    "nbLicenciatura": item_json["nbLicenciatura"].stringValue,
                                                    "is_checked": 0
                                                    
                                                ]
                                            ]
                    ]
                    sections.add(newNivel)
                }
            }
            
        }
        debugPrint(sections)
        tableView.reloadData()
        hiddenGifIndicator(view: self.view)
        
    }
    
    func  validar_seccion( idCatNivelEstudios: Int64) -> Int{
        var seccion_indice : Int = 0
        for section in sections{
            var aux_section = JSON(section)
            if aux_section["idCatNivelEstudios"].intValue == idCatNivelEstudios{
                return seccion_indice
            }
            seccion_indice += 1;
        }
        return -1
    }
    
    func setup_ux(){
        
        let image = UIImage(named: "ic_action_search")?.withRenderingMode(.alwaysOriginal)
        button_find = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(on_click_find))
        
        self.navigationItem.leftBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem = nil
        //
    }
    
    @objc func on_click_find(sender: AnyObject) {
        
    
        let vc = storyboard?.instantiateViewController(withIdentifier: "ListUniversitiesViewControllerID") as! ListUniversitiesViewController
        vc.type = "find_university"
        vc.list_licensature = list_licensature_array
        self.show(vc, sender: nil)
 
    }
    
    //Table View. -------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section_item = JSON(sections[section])
        let count = section_item["list_licensature"].count
        return count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section_item = JSON(sections[section])
        let title = section_item["nbNivelEstudios"].stringValue
        return  "Seccion \(title)"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as! HeaderTableViewCell
        
        let section_item = JSON(sections[section])
        let title = section_item["nbNivelEstudios"].stringValue
        print("Title: \(title)")
        
        header.title.text = title
        header.backgroundColor = Colors.green_dark
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AcademicsTableViewCell
        let section_item = JSON(sections[indexPath.section])
        let rows = section_item["list_licensature"].arrayValue
        let row = JSON(rows[indexPath.row])
        cell.name.text = row["nbLicenciatura"].stringValue
        cell.layer.borderWidth = 3
        cell.clipsToBounds = true
        
        // Swicth
        cell.swich_item.setOn(false, animated: true)
        if row["is_checked"].intValue == 1{
            cell.swich_item.setOn(true, animated: true)
        }
        
        cell.swich_item.row = indexPath.row
        cell.swich_item.section = indexPath.section
        
        cell.swich_item.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        return cell
    }
    
     @objc func switchChanged(_ sender : CustomSwich!){
        set_active_swich(row: sender.row, section: sender.section, sender : sender!)
    }
    
    func set_active_swich(row:Int, section:Int, sender : CustomSwich!){
        //       print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        //print("Antes")
        //debugPrint(sections)
        let section_aux = sections[section] as! NSDictionary
        var list_licensature_aux = section_aux["list_licensature"] as! [Any]
        
        var is_checked = 0
        if sender.isOn{
            is_checked = 1
        }
        
        var updatate_item_licensature = JSON(list_licensature_aux[row])
        let item_licensature = [
            "idLicenciatura": updatate_item_licensature["idLicenciatura"].intValue,
            "nbLicenciatura": updatate_item_licensature["nbLicenciatura"].stringValue,
            "is_checked": is_checked
            ] as [String : Any]
        list_licensature_aux[row] = item_licensature
        
        // Si el Swich es el de TODOS
        if updatate_item_licensature["idLicenciatura"].intValue == 0 {
            
            print(list_licensature_aux.count)
            
            for i in 0 ..< list_licensature_aux.count{
                
                var updatate_item_licensature_for = JSON(list_licensature_aux[i])
                let item_licensature_for = [
                    "idLicenciatura": updatate_item_licensature_for["idLicenciatura"].intValue,
                    "nbLicenciatura": updatate_item_licensature_for["nbLicenciatura"].stringValue,
                    "is_checked": is_checked
                    ] as [String : Any]
                list_licensature_aux[i] = item_licensature_for
            }
            
            tableView.reloadData()
        }
        
        
        
        let oldNivel:NSDictionary = [
            "nbNivelEstudios": section_aux["nbNivelEstudios"] as! String,
            "idCatNivelEstudios": section_aux["idCatNivelEstudios"] as! Int,
            "list_licensature": list_licensature_aux
        ]
        sections[section] = oldNivel
        
        //print("Despues")
        //debugPrint(sections)
        
        if validate_any_swich_active() > 0{
            self.navigationItem.rightBarButtonItem = button_find
        }
        else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    

    func validate_any_swich_active()-> Int{
        
        list_licensature_array = []
        var is_any_swich_active = 0
        for section_i in 0 ..< sections.count{
            
            let section_item = sections[section_i] as! NSDictionary
            var list_licensature_aux = section_item["list_licensature"] as! [Any]
            
            for row_i in 0 ..< list_licensature_aux.count{
                
                var row_item = JSON(list_licensature_aux[row_i])
                if  row_item["is_checked"].intValue == 1{
                    is_any_swich_active = is_any_swich_active + 1
                    
                    if row_item["idLicenciatura"].intValue != 0 {
                        let item_parameter = ["idLicenciatura": row_item["idLicenciatura"].intValue]
                        list_licensature_array.append(item_parameter)
                    }
                    

                }
            }
        }
        
        return is_any_swich_active
    }
    


}
