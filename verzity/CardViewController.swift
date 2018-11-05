//
//  CardViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 21/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults

class CardViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var webServiceController = WebServiceController()
    var type: String = ""
    var idUniversidad = 0
    var list_data: AnyObject!
    var items:NSArray = []
    
    var filtered:NSMutableArray = []
    var filtered_array:NSArray = []
    
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        type = String(type)
        idUniversidad = idUniversidad as Int
        setup_ui()
        setup_ux()
        load_data(type:type)
        
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
        load_data(type:type)
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func setup_ui(){
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    func setup_ux(){
        if type == "coupons" {
           searchBar.placeholder = "Buscar cupones"
        }
    }
    
    func load_data(type: String){
        showGifIndicator(view: self.view)
        
        switch String(type) {
        case "becas":
            self.title = "Becas"
            let array_parameter = ["idUniversidad": idUniversidad]
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.GetBecasVigentes(parameters: parameter_json_string!, doneFunction: GetCardGeneral)
            break
        case "financing":
            print("financing")
            self.title = "Fmto"
            self.navigationItem.title = "Fmto"
            let array_parameter = ["idUniversidad": idUniversidad]
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.GetFinanciamientosVigentes(parameters: parameter_json_string!, doneFunction: GetCardGeneral)
            break
        case "coupons":
            self.title = "Cupones"
            let array_parameter = ["": ""]
            let parameter_json = JSON(array_parameter)
            let parameter_json_string = parameter_json.rawString()
            webServiceController.GetCuponesVigentes(parameters: parameter_json_string!, doneFunction: GetCardGeneral)
            break
        case "travel":
            self.title = "Viajes"
            
            print("travel")
            break
        default:
            break
        }
    }
    
    func GetCardGeneral(status: Int, response: AnyObject){
        var json = JSON(response)
        if status == 1{
            list_data = json["Data"].arrayValue as Array as AnyObject
            items = json["Data"].arrayValue as NSArray
            tableView.reloadData()
        }else{
            showMessage(title: response as! String, automatic: true)
        }
        hiddenGifIndicator(view: self.view)
    }
    
    // Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Buscando")
        
        self.filtered.removeAllObjects()
        for item in items {
            
            if type == "coupons" {
                var item_json = JSON(item)
                var nbCupon = item_json["nbCupon"].stringValue
                
                
                let name = nbCupon.lowercased()
                let sear = searchText.lowercased()
                
                let name_clean = name.folding(options: .diacriticInsensitive, locale: .current)
                let sear_clean = sear.folding(options: .diacriticInsensitive, locale: .current)
                
                var is_containt = name_clean.contains(sear_clean)
                
           
                if  (is_containt){
                    print("Entro")
                    self.filtered.add(item)
                }
            } else{
                
                var item_json = JSON(item)
                var universidad = JSON(item_json["Universidades"])
                let nbUniversidad = universidad["nbUniversidad"].stringValue
                
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CardTableViewCell
       
        var item:JSON
        if (searchBar.text != ""){
            item = JSON(filtered_array[indexPath.section])
        }else{
            item = JSON(items[indexPath.section])
        }
        
        print(item)
        
        var title = ""
        var name = ""
        var lblDescription = ""
        var pathImage = ""
        let size = view.frame.width
        var size_letter = 13.0
        
        if  size <= 320.0{
            size_letter = 11.0
        }

        // Becas
        if type == "becas" {
            title = item["nbBeca"].stringValue
            name = "Universidad que ofrece la beca"
            var universidad = JSON(item["Universidades"])
            
            lblDescription = universidad["nbUniversidad"].stringValue
            
            cell.name.font = UIFont.systemFont(ofSize: CGFloat(size_letter))
            
            cell.lblDescription.font =  UIFont.boldSystemFont(ofSize: 14.0)
            
            pathImage = item["pathImagen"].stringValue
            pathImage = pathImage.replacingOccurrences(of: "~", with: "")
            pathImage = pathImage.replacingOccurrences(of: "\\", with: "")
        }
        
        // Financiamiento
        if type == "financing" {
            title = item["nbFinanciamiento"].stringValue
            name = "Universidad que ofrece el financiamiento"
            
            var universidades = JSON(item["Universidades"])
            
            lblDescription = universidades["nbUniversidad"].stringValue
            cell.name.font = UIFont.systemFont(ofSize: CGFloat(size_letter))
           
            cell.lblDescription.font =  UIFont.boldSystemFont(ofSize: 14.0)
            
            pathImage = item["pathImagen"].stringValue
            pathImage = pathImage.replacingOccurrences(of: "~", with: "")
            pathImage = pathImage.replacingOccurrences(of: "\\", with: "")
        }
        
        //Cupones
        if type == "coupons" {
            title = item["nbCupon"].stringValue
            
            
            let feFin = get_date_complete_date(date_complete_string: item["feFin"].stringValue)
            lblDescription = ""
            name =  "Vencimiento:\(feFin)"
            var imagenesCupones = item["ImagenesCupones"].arrayValue
            pathImage = ""
            if imagenesCupones.count > 0{
                var cuponImagen = JSON(imagenesCupones[0])
                
                pathImage = cuponImagen["desRutaFoto"].stringValue
                pathImage = pathImage.replacingOccurrences(of: "~", with: "")
                pathImage = pathImage.replacingOccurrences(of: "\\", with: "")
            }
        }
        
        // ------
        let url_a = Defaults[.desRutaMultimedia]!
        let url =  "\(url_a)\(pathImage)"
        
        
        print(url)
        let URL = Foundation.URL(string: url)
        let image = UIImage(named: "default.png")
        
        cell.imageBackground.kf.setImage(with: URL, placeholder: image)
        cell.title.text = title
        cell.name.text = name
        cell.lblDescription.text = lblDescription
        
        cell.btnShowMore.addTarget(self, action: #selector(self.on_click_show_more), for:.touchUpInside)
        cell.btnShowMore.tag = indexPath.section
        
        return cell
    }
    
   @objc func on_click_show_more(sender: UIButton){
        let index = sender.tag
        switch String(type) {
        case "becas":
            print("becas")
            let vc = storyboard?.instantiateViewController(withIdentifier: "DetailBecasViewControllerID") as! DetailBecasViewController
            vc.detail = items[index] as AnyObject
            self.show(vc, sender: nil)
            break
        case "financing":
            let vc = storyboard?.instantiateViewController(withIdentifier: "DetailFinanciamientoViewControllerID") as! DetailFinanciamientoViewController
            vc.detail = items[index] as AnyObject
            self.show(vc, sender: nil)
            
            break
        case "coupons":
            print("coupons")
            let vc = storyboard?.instantiateViewController(withIdentifier: "QrCouponViewControllerID") as! QrCouponViewController
            var item = JSON(items[index])
            vc.idCupon = item["idCupon"].intValue
            self.show(vc, sender: nil)
            break
        default:
            break
        }
    }

}
