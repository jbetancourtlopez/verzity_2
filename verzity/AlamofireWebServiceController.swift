//
//  AlamofireWebServiceController.swift
//  verzity
//
//  Created by Jossue Betancourt on 21/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class AlamofireWebServiceController {
    
    var request: Alamofire.Request?
    
    static let REQUEST_METHOD_POST = "POST"
    static let REQUEST_METHOD_GET = "GET"
    
    func sendRequest(url: String,  requestMethod: String,  jsonObject: String, completionHandler: @escaping (Any?, Error?) -> () ){
        
        let json_parameters: Parameters = ["json": jsonObject]
        print("Alamore")
        debugPrint(json_parameters)
        if requestMethod == "GET" {
            Alamofire.request(url, method: .get, parameters: json_parameters)
                .validate()
                .responseJSON { response in
                    if let value = response.value {
                        completionHandler(value, response.error)
                    }
            }
        }
        else if requestMethod == "POST" {
            Alamofire.request(url, method: .post, parameters: json_parameters)
                .validate()
                .responseJSON { response in
                    if let value = response.value {
                        completionHandler(value, response.error)
                    }
            }
        }
    }
    
    func load_data(){
        let url = "http://avicolasanjosemx.com.mx/webmin/login/login_auth"
        Alamofire.request(url,
                          method: .get)
            .validate()
            .responseJSON { response in
                //debugPrint(response)
                if let value = response.value {
                    let json = JSON(value)
                    debugPrint(json)
                }
                
        }
    }
    
    // Upload File
    func requestWith(endUrl: String, imageData: Data?, parameters: [String : Any], completionHandler: @escaping (Any?, Error?) -> ()){
        
        let url = endUrl
        
        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "fileToUpload", fileName: "fileToUpload", mimeType: "image/jpg")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in

                    if let err = response.error{
                        debugPrint(err)
                        return
                    }
                    
                    if let value = response.value {
                        print("Exito")
                        completionHandler(value, response.error)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
               
            }
        }
    }
}

