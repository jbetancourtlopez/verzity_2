//
//  ExampleViewController.swift
//  verzity
//
//  Created by Jossue Betancourt on 06/07/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {

    
    @IBOutlet var viewYoutube: YTPlayerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("video")
        // EBulMWMoFuw  KXdUNp_9oHs
        // Do any additional setup after loading the view.
        //self.viewYoutube.load(withVideoId: "EBulMWMoFuw");
        self.viewYoutube.load(withVideoId: "KXdUNp_9oHs")
        //self.viewYoutube.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewYoutube.playVideo()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
