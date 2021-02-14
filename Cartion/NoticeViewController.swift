//
//  NoticeViewController.swift
//  Cartion
//
//  Created by bellcon on 2021/01/20.
//  Copyright © 2021 belicon. All rights reserved.
//

import UIKit
import Alamofire
import ExpyTableView

class NoticeViewController: UIViewController {

    @IBOutlet weak var noticeTable: ExpyTableView!
    
    private var titles = Array<String>()
    private var contents = Array<String>()
    
    private var headers: HTTPHeaders = ["Content-Type" : "application/json", "Authorization" : User.token]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getNotice()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NoticeViewController {
    
    func getNotice() {
        let url = URL(string: "\(User.base_url)api/notices")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(Notice.self, from: jsonData)
                    if json.statusCode == 200 {
                        for item in json.data.noticeList {
                            self.titles.append(item.title)
                            self.contents.append(item.body)
                        }
                        self.noticeTable.reloadData()
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

extension NoticeViewController: ExpyTableViewDelegate, ExpyTableViewDataSource {
    
    func tableView(_ tableView: ExpyTableView, expyState state: ExpyState, changeForSection section: Int) {
        // 열리고 닫힐 때
    }
    
    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        // 섹션 내용
        let cell = tableView.dequeueReusableCell(withIdentifier: "notice_title_cell") as! NoticeTitleCell
        cell.noticeTitleText.text = titles[section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // row 갯수
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // row 내용
        let cell = tableView.dequeueReusableCell(withIdentifier: "notice_content_cell", for: indexPath) as! NoticeContentCell
        cell.noticeContentText.attributedText = contents[indexPath.section].htmlToAttributedString
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 섹션 갯수
        return titles.count
    }
}

class NoticeTitleCell: UITableViewCell {
    
    @IBOutlet weak var noticeTitleText: UILabel!
}

class NoticeContentCell: UITableViewCell {
    
    @IBOutlet weak var noticeContentText: UILabel!
}
