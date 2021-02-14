//
//  CartionInfoViewController.swift
//  Cartion
//
//  Created by bellcon on 2021/01/11.
//  Copyright © 2021 belicon. All rights reserved.
//

import UIKit
import Alamofire

class CartionInfoViewController: UIViewController {
    
    @IBOutlet weak var cartionInfoTableView: UITableView!
    
    private var infos = Array<String>()
    
    private let headers: HTTPHeaders = ["Authorization" : User.token, "Content-Type" : "application/json"]

    override func viewDidLoad() {
        super.viewDidLoad()

        getInfo()
    }
    
    private func getInfo() {
        let url = URL(string: "\(User.base_url)api/use-apps")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(CartionInfo.self, from: jsonData)
                    if json.statusCode == 200 {
                        for info in json.data.useAppList {
                            self.infos.append(info.imageUrl)
                            self.cartionInfoTableView.rowHeight = 800
                            self.cartionInfoTableView.reloadData()
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

extension CartionInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if infos.count == 0 {
            return 0
        }
        return infos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartion_info_cell", for: indexPath) as! CartionInfoCell
        let url = URL(string: infos[indexPath.row])
        DispatchQueue.main.async {
            let data = try? Data(contentsOf: url!)
            cell.infoImage.image = UIImage(data: data!)
        }
        return cell
    }
}

class CartionInfoCell: UITableViewCell {
    
    @IBOutlet weak var infoImage: UIImageView!
}
