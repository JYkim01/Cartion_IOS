//
//  IntroVideoController.swift
//  Cartion
//
//  Created by bellcon on 2021/02/11.
//  Copyright © 2021 belicon. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class IntroVideoController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UserDefaults.standard.setValue(false, forKey: "intro")
        let player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "intro", ofType: "mp4")!))
        
        let layer = AVPlayerLayer(player: player)
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        
        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name:
        NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func videoDidEnd(notification: NSNotification) {
        self.dismiss(animated: true, completion: nil)
    }
}
