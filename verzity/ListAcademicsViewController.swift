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
    var items:NSMutableArray = []
    var list_licensature_array:[Any] = []

    var button_find = UIBarButtonItem()
    var refreshControl = UIRefreshControl()
    
    var idCatNivelEstudios: Int!
    var nbNivelEstudios: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let array_parameter = ["idCatNivelEstudios": self.idCatNivelEstudios,
                               "nbNivelEstudios": self.nbNivelEstudios,
                               ] as [String : Any]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.get(parameters: parameter_json_string!, method: Singleton.GetProgramasAcademicos, doneFunction: callback_load_data)
    }
    
    func callback_load_data(status: Int, response: AnyObject){
        var json = JSON(response)
        items = []
        if status == 1{
            var items_list = json["Data"].arrayValue as NSArray
            var i = 1
            
            items[0] = [
                "idLicenciatura": 0,
                "nbLicenciatura": "Todos",
                "is_checked": 0
            ] as NSDictionary
            
            for item in items_list{
                
                var item_json = JSON(item)
                let item_aux: NSDictionary = [
                    "nbLicenciatura" : item_json["nbLicenciatura"].stringValue,
                    "idLicenciatura" : item_json["idLicenciatura"].intValue,
                    "is_checked": 0
                ]
                items[i] = item_aux
                
                i = i + 1
            }
            
        }
        
        tableView.reloadData()
        hiddenGifIndicator(view: self.view)
    }
    
   
    
    func setup_ux(){
        tableView.delegate = self
        tableView.dataSource = self
        
        let image = UIImage(named: "ic_action_search")?.withRenderingMode(.alwaysOriginal)
        button_find = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(on_click_find))
        
        self.navigationItem.leftBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @objc func on_click_find(sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ListUniversitiesViewControllerID") as! ListUniversitiesViewController
        vc.type = "find_university"
        vc.list_licensature = list_licensature_array
        self.show(vc, sender: nil)
    }
    
    //Table View. -------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  "Seccion "
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as! HeaderTableViewCell
        header.title.text = self.nbNivelEstudios
        header.backgroundColor = Colors.green_dark
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AcademicsTableViewCell
       

        let item = JSON(items[indexPath.row])
        cell.name.text = item["nbLicenciatura"].stringValue
        cell.layer.borderWidth = 3
        cell.clipsToBounds = true

        // Swicth
        cell.swich_item.setOn(false, animated: true)
        if item["is_checked"].intValue == 1{
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

       // let section_aux = sections[section] as! NSDictionary
       // var list_licensature_aux = section_aux["list_licensature"] as! [Any]

        var is_checked = 0
        if sender.isOn{
            is_checked = 1
        }

        var updatate_item = JSON(items[row])
        let item_licensature = [
            "idLicenciatura": updatate_item["idLicenciatura"].intValue,
            "nbLicenciatura": updatate_item["nbLicenciatura"].stringValue,
            "is_checked": is_checked
            ] as [String : Any]
        items[row] = item_licensature

        // Si el Swich es el de TODOS
        if updatate_item["idLicenciatura"].intValue == 0 {

            print(items.count)

            for i in 0 ..< items.count{

                var updatate_item_licensature_for = JSON(items[i])
                let item_licensature_for = [
                    "idLicenciatura": updatate_item_licensature_for["idLicenciatura"].intValue,
                    "nbLicenciatura": updatate_item_licensature_for["nbLicenciatura"].stringValue,
                    "is_checked": is_checked
                    ] as [String : Any]
                items[i] = item_licensature_for
            }

            tableView.reloadData()
        }



//        let oldNivel:NSDictionary = [
//            "nbNivelEstudios": section_aux["nbNivelEstudios"] as! String,
//            "idCatNivelEstudios": section_aux["idCatNivelEstudios"] as! Int,
//            "list_licensature": list_licensature_aux
//        ]
//        sections[section] = oldNivel

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
     
        for index in 0 ..< items.count{

            var row_item = JSON(items[index])
            if  row_item["is_checked"].intValue == 1{
                is_any_swich_active = is_any_swich_active + 1

                if row_item["idLicenciatura"].intValue != 0 {
                    let item_parameter = ["idLicenciatura": row_item["idLicenciatura"].intValue]
                    list_licensature_array.append(item_parameter)
                }
            }
        }
        return is_any_swich_active
    }

}
