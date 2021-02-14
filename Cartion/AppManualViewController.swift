//
//  AppManualViewController.swift
//  Cartion
//
//  Created by bellcon on 2021/01/11.
//  Copyright © 2021 belicon. All rights reserved.
//

import UIKit
import Alamofire

class AppManualViewController: UIViewController {

    @IBOutlet weak var appManualTableView: UITableView!
    
    private var appManuals = Array<String>()
    
    private let headers: HTTPHeaders = ["Authorization" : User.token, "Content-Type" : "application/json"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getManual()
    }
    
    private func getManual() {
     
        let url = URL(string: "\(User.base_url)api/app-manual")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(AppManual.self, from: jsonData)
                    if json.statusCode == 200 {
                        for manual in json.data.appManualList {
                            self.appManuals.append(manual.imageUrl)
                            self.appManualTableView.rowHeight = 600
                            self.appManualTableView.reloadData()
                        }
                    }
                } catch(let err) {
                    print("Error: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Failure: \(err.localizedDescription)")
                break
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AppManualViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if appManuals.count == 0 {
            return 0
        }
        return appManuals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "app_manual_cell", for: indexPath) as! AppManualCell
        let url = URL(string: appManuals[indexPath.row])
        DispatchQueue.main.async {
            let data = try? Data(contentsOf: url!)
            cell.appManualImage.image = UIImage(data: data!)
        }
        return cell
    }
}

class AppManualCell: UITableViewCell {
    
    @IBOutlet weak var appManualImage: UIImageView!
}
