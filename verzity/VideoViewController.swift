//
//  VideoViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 29/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SwiftyJSON
import Kingfisher
import SwiftyUserDefaults


class VideoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var webServiceController = WebServiceController()
    var list_data: AnyObject!
    var items:NSArray = []
    var idUniversidad: Int = 0
    @IBOutlet var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Videos"
        idUniversidad = idUniversidad as Int
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
        let array_parameter = ["idUniversidad": idUniversidad]
        let parameter_json = JSON(array_parameter)
        let parameter_json_string = parameter_json.rawString()
        webServiceController.GetVideos(parameters: parameter_json_string!, doneFunction: GetVideo)
    }
    func GetVideo(status: Int, response: AnyObject){
        var json = JSON(response)
        debugPrint(json)
        if status == 1{
            list_data = json["Data"].arrayValue as Array as AnyObject
            items = json["Data"].arrayValue as NSArray
            tableView.reloadData()
        }
        hiddenGifIndicator(view: self.view)
    }
    
    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.items.count == 0 {
            empty_data_tableview(tableView: tableView)
            return 0
        }else{
            tableView.backgroundView = nil
            return self.items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var item = JSON(items[indexPath.row])
        var video = item["desRutaVideo"].stringValue
        var cell_name = ""
        if video.isEmpty {
            cell_name = "cell_youtube"
        }else{
            cell_name = "cell_player"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cell_name, for: indexPath) as! VideoTableViewCell
        
        if cell_name == "cell_youtube"{
            cell.viewYoutube.load(withVideoId: item["urlVideo"].stringValue)
            cell.viewYoutube.playVideo()
            
        }else{
            
            //Video de Ruta
            // https://www.youtube.com/watch?v=X3wwI1NDeKc
            //"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
            let url_string = item["desRutaVideo"].stringValue
            
            
            var desRutaVideo = item["desRutaVideo"].stringValue
            desRutaVideo = desRutaVideo.replacingOccurrences(of: "~", with: "")
            desRutaVideo = desRutaVideo.replacingOccurrences(of: "\\", with: "")
            
            var url_multimedia = Defaults[.desRutaMultimedia]! + desRutaVideo
            
           
            
            let video_url = NSURL(string: url_multimedia)
            let avPlayer = AVPlayer(url: video_url as! URL)
            cell.playerView?.playerLayer.player = avPlayer
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
            
            cell.playerView.tag = indexPath.row
            cell.playerView.addGestureRecognizer(tapGesture)
            
            
            //cell.playerView.player?.play()
        }
       
        
       
        cell.title.text = item["nbVideo"].stringValue
        cell.video_description.text = item["desVideo"].stringValue
  
        cell.layer.borderWidth = 3
        cell.clipsToBounds = true
        
        return cell
        
    }
    
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        print("tap tap")
        
        var tag = recognizer.view?.tag
        print(tag)
        
        var item = JSON(items[tag!])
        var desRutaVideo = item["desRutaVideo"].stringValue
        desRutaVideo = desRutaVideo.replacingOccurrences(of: "~", with: "")
        desRutaVideo = desRutaVideo.replacingOccurrences(of: "\\", with: "")
        
        var url_multimedia = Defaults[.desRutaMultimedia]! + desRutaVideo
        let video_url = NSURL(string: url_multimedia)
        
         print(url_multimedia)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "AVPlayerViewControllerID") as! AVPlayerViewController
     
       
        
     vc.navigationItem.backBarButtonItem =
            UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        vc.player = AVPlayer(url: video_url as! URL)
        vc.player?.play()
        
        self.show(vc, sender: nil)
        //super.showDetailViewController(vc, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Entro 1")
        if segue.identifier == "showVideoPlayer" {
            print("Entro")
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                var item = JSON(items[indexPath.row])
                
                
                var desRutaVideo = item["desRutaVideo"].stringValue
                desRutaVideo = desRutaVideo.replacingOccurrences(of: "~", with: "")
                desRutaVideo = desRutaVideo.replacingOccurrences(of: "\\", with: "")
                
                var url_multimedia = Defaults[.desRutaMultimedia]! + desRutaVideo
                
                print(url_multimedia)
                
                let destination = segue.destination as! AVPlayerViewController
                let video_url = NSURL(string: url_multimedia)
                destination.player = AVPlayer(url: video_url as! URL)
                destination.player?.play()
            }
        }
    }
    



}

