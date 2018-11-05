//
//  PlayerViewClass.swift
//  verzity
//
//  Created by Jossue Betancourt on 29/06/18.
//  Copyright © 2018 Jossue Betancourt. All rights reserved.
//

import AVFoundation
import UIKit
import AVKit

class PlayerViewClass: UIView {
    
    override static var layerClass: AnyClass{
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer{
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer?{
        get{
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
}

