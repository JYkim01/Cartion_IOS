//
//  FAQViewController.swift
//  Cartion
//
//  Created by bellcon on 2021/01/08.
//  Copyright © 2021 belicon. All rights reserved.
//

import UIKit
import Alamofire
import ExpyTableView

class FAQViewController: UIViewController {

    @IBOutlet weak var faqTableView: ExpyTableView!
    
    private var titles = Array<String>()
    private var contents = Array<String>()
    
    private var headers: HTTPHeaders = ["Content-Type" : "application/json", "Authorization" : User.token]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        titles.removeAll()
        contents.removeAll()
        getFAQ()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FAQViewController {
    
    func getFAQ() {
        let url = URL(string: "\(User.base_url)api/faqs")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(FAQ.self, from: jsonData)
                    if json.statusCode == 200 {
                        for item in json.data.faqList {
                            self.titles.append(item.title)
                            self.contents.append(item.body)
                        }
                        self.faqTableView.reloadData()
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

extension FAQViewController: ExpyTableViewDelegate, ExpyTableViewDataSource {
    
    func tableView(_ tableView: ExpyTableView, expyState state: ExpyState, changeForSection section: Int) {
        // 열리고 닫힐 때
    }
    
    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        // 섹션 내용
        let cell = tableView.dequeueReusableCell(withIdentifier: "faq_title_cell") as! FAQTitleCell
        cell.faqTitleText.text = titles[section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // row 갯수
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // row 내용
        let cell = tableView.dequeueReusableCell(withIdentifier: "faq_content_cell", for: indexPath) as! FAQContentCell
        cell.faqContentText.attributedText = contents[indexPath.section].htmlToAttributedString
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 섹션 갯수
        return titles.count
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

class FAQTitleCell: UITableViewCell {
    
    @IBOutlet weak var faqTitleText: UILabel!
}

class FAQContentCell: UITableViewCell {
    
    @IBOutlet weak var faqContentText: UILabel!
}
