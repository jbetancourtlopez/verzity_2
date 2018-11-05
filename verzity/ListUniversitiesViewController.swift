//
//  ListUniversitiesViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 26/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.

import UIKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults


class ListUniversitiesViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var webServiceController = WebServiceController()
    var type: String = ""
    var items:NSArray = []
    var list_licensature:[Any] = []
    
    var filtered:NSMutableArray = []
    var filtered_array:NSArray = []
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        type = String(type)
        self.list_licensature = list_licensature as [Any]
        setup_table()
        setup_search_bar()
        setup_ux()
        //load_data()
        
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
        }
        self.navigationItem.leftBarButtonItem?.title = ""
    }
    
    func load_data(name_university: String = ""){
        showGifIndicator(view: self.view)
        if  type == "find_favorit" {
            let idPersona = Defaults[.academic_idPersona]
            let array_parameter = ["idPersona": idPersona]
            debugPrint(array_parameter)
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.GetFavoritos(parameters: parameter_json_string!, doneFunction: GetListGeneral)
        } else if type == "find_university" {
            
            var array_parameter:[String: Any] = ["": ""]
            
            if  name_university != "" {
                array_parameter = ["nombreUniversidad": name_university]
            }
            
            if list_licensature.count > 0{
                
                array_parameter = [
                    "nombreUniversidad": name_university,
                    "Licenciaturas": list_licensature
                    ]
            }
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            
            print(parameter_json_string)
            webServiceController.BusquedaUniversidades(parameters: parameter_json_string!, doneFunction: GetListGeneral)
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
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailUniversityViewControllerID") as! DetailUniversityViewController
        let university_json = JSON(university)
        vc.idUniversidad = university_json["idUniversidad"].intValue
        self.show(vc, sender: nil)
    }
    


}
