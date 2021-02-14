//
//  UserAuthViewController.swift
//  Cartion
//
//  Created by bellcon on 2020/11/11.
//  Copyright © 2020 belicon. All rights reserved.
//

import UIKit
import Alamofire

class UserAuthViewController: UIViewController {
    
    private var headers: HTTPHeaders = ["Content-Type": "application/json", "Authorization" : User.token]

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func onAgree(_ sender: Any) {
        let url = URL(string: "\(User.base_url)api/agreement")
        
        let alamo = AF.request(url!, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(LoginAuth.self, from: jsonData)
                    if json.statusCode == 200 {
                        let vc = self.storyboard!.instantiateViewController(identifier: "main_tab_vc")
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                } catch(let err) {
                    print(err.localizedDescription)
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
