//
//  SafeDialogViewController.swift
//  Cartion
//
//  Created by bellcon on 2021/01/18.
//  Copyright © 2021 belicon. All rights reserved.
//

import UIKit

class SafeDialogViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func onBack(_ sender: Any) {
        UserDefaults.standard.setValue("safe", forKey: "safe")
        self.dismiss(animated: true, completion: nil)
    }
}
