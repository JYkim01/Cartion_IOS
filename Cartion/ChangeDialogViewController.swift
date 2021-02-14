//
//  ChangeDialogViewController.swift
//  Cartion
//
//  Created by bellcon on 2021/01/18.
//  Copyright © 2021 belicon. All rights reserved.
//

import UIKit
import Alamofire
import CoreBluetooth

class ChangeDialogViewController: UIViewController, CBPeripheralDelegate {
    
    @IBOutlet weak var changeTable: UITableView!
    
    private var switches = Array<SwitchList>()
    
    var peripheral: CBPeripheral!
    
    var rxCharacteristic:CBCharacteristic?

    private var headers: HTTPHeaders = ["Authorization" : User.token]
    private var userId = "belicon46@gmail.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.peripheral.delegate = self
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        self.peripheral.writeValue(Data(self.onPost(str: "PSD:0")), for: self.rxCharacteristic!, type: .withResponse)
    }
    
    private func onPost(str: String) -> [UInt8] {
        var checksum = 0;
        let bytes = Array(str.utf8)
        var dataBytes = [UInt8] (repeating: 0, count: bytes.count + 1)
        
        for (index, value) in bytes.enumerated() {
            dataBytes[index] = value
            checksum += Int(value)
        }
        dataBytes[bytes.count] = UInt8((checksum % 256))
        checksum = 0;
        return dataBytes
    }
}

extension ChangeDialogViewController {
    
    // 모바일 스위치 조회
    private func getSwitch() {
        let url = URL(string: "\(User.base_url)api/\(self.userId)/horn")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(MobileSwitch.self, from: jsonData)
                    if json.statusCode == 200 {
                        for item in json.data.hornList {
                            self.switches.append(SwitchList(userId: item.userId, hornType: item.hornType, hornId: item.hornId, hornName: item.hornName, categoryName: item.categoryName, mobileSwitch: item.mobileSwitch, seq: item.seq, type: item.type))
                        }
                        self.changeTable.reloadData()
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
}

extension ChangeDialogViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if switches.count == 0 {
            return 0
        }
        
        return switches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "change_cell", for: indexPath) as! ChangeCell
        cell.hornPos.text = "\(indexPath.row + 1)"
        if switches[indexPath.row].categoryName == "기본" {
            cell.hornCategory.text = "카션 기본음"
        } else {
            cell.hornCategory.text = "카션 \(switches[indexPath.row].categoryName)"
        }
        cell.hornName.text = switches[indexPath.row].hornName
        return cell
    }
}

class ChangeCell: UITableViewCell {
    @IBOutlet weak var hornPos: UILabel!
    @IBOutlet weak var hornCategory: UILabel!
    @IBOutlet weak var hornName: UILabel!
}
