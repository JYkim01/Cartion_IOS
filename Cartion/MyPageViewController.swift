//
//  MyPageViewController.swift
//  Cartion
//
//  Created by bellcon on 2021/01/12.
//  Copyright © 2021 belicon. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

class MyPageViewController: UIViewController {
    
    @IBOutlet weak var myPageBannerCollectionView: UICollectionView!
    
    @IBOutlet weak var myPageScroll: UIScrollView!
    @IBOutlet weak var myPageContainer: UIView!
    @IBOutlet weak var myPageEmailText: UITextField!
    @IBOutlet weak var myPagePhoneText: UITextField!
    @IBOutlet weak var myPageTable: UITableView!
    @IBOutlet weak var myPageConfirm: UIButton!
    
    private var headers: HTTPHeaders = ["Content-Type" : "application/json", "Authorization" : User.token]
    
    private var banners = Array<String>()
    private var bannerPos = 0
    
    private var names = Array<String>()
    private var deviceId = ""
    private var name = ""
    
    private var isEditMode = false
    private var isNameEditMode = false
    private var isDelete = false

    override func viewDidLoad() {
        super.viewDidLoad()

        getBanner()
        bannerTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.names.removeAll()
        getUser()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onKeyBoard(_:)))
        myPageContainer.addGestureRecognizer(gesture)
    }
    
    private func getBanner() {
        let url = URL(string: "\(User.base_url)api/banners")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(Banner.self, from: jsonData)
                    if json.statusCode == 200 {
                        for banner in json.data.bannerList {
                            self.banners.append(banner.imageURL)
                            self.myPageBannerCollectionView.reloadData()
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
    
    // 사용자 조회
    private func getUser() {
        let url = URL(string: "\(User.base_url)api/user/\(User.email)")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(UserInfo.self, from: jsonData)
                    if json.statusCode == 200 {
                        self.myPageEmailText.text = json.data.userId
                        self.myPagePhoneText.text = json.data.phoneNumber
                        if json.data.devices.count != 0 {
                            self.deviceId = json.data.devices[0].deviceId
                            self.name = json.data.devices[0].deviceName
                            self.names.append("\(json.data.devices[0].deviceId) : \(json.data.devices[0].deviceName)")
                            self.myPageTable.reloadData()
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
    
    @IBAction func onSettins(_ sender: Any) {
        self.myPageEmailText.isEnabled = true
        self.myPagePhoneText.isEnabled = true
        self.isEditMode = true
        self.myPageTable.reloadData()
        self.myPageConfirm.isHidden = false
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        getModify()
    }
    
    @objc private func onKeyBoard(_ sender: UITapGestureRecognizer) {
        myPagePhoneText.resignFirstResponder()
    }
}

extension MyPageViewController {
    
    private func getModify() {
        let url = URL(string: "\(User.base_url)api/user/\(User.email)")
        
        let param: Parameters = [
            "phoneNumber" : self.myPagePhoneText.text!
        ]
        
        let alamo = AF.request(url!, method: .put, parameters: param, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(SignUp.self, from: jsonData)
                    if json.statusCode == 200 {
                        self.myPageEmailText.isEnabled = false
                        self.myPagePhoneText.isEnabled = false
                        self.isEditMode = false
                        self.myPageTable.reloadData()
                        self.myPageConfirm.isHidden = true
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

extension MyPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if banners.count == 0 {
            return 0
        }
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "my_page_banner_cell", for: indexPath) as! MyPageBannerCell
        let url = URL(string: banners[indexPath.row])
        DispatchQueue.main.async {
            let data = try? Data(contentsOf: url!)
            cell.imgView.image = UIImage(data: data!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: myPageBannerCollectionView.frame.size.width  , height:  myPageBannerCollectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        bannerPos = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    // 2초마다 실행되는 타이머
    func bannerTimer() {
        let _: Timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (Timer) in
            self.bannerMove()
        }
    }
    
    // 배너 움직이는 매서드
    func bannerMove() {
        // 현재페이지가 마지막 페이지일 경우
        if bannerPos == banners.count-1 {
            // 맨 처음 페이지로 돌아감
            myPageBannerCollectionView.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: true)
            bannerPos = 0
            return
        }
        // 다음 페이지로 전환
        bannerPos += 1
        myPageBannerCollectionView.scrollToItem(at: NSIndexPath(item: bannerPos, section: 0) as IndexPath, at: .right, animated: true)
    }
}

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if names.count == 0 {
            return 0
        }
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEditMode == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "my_cartion_setting", for: indexPath) as! MySettingCell
            cell.nameEdit.placeholder = self.name
            if isNameEditMode == false {
                cell.nameConfirm.setImage(UIImage(named: "trash_on"), for: .normal)
//                cell.nameConfirm.isHidden = true
            } else {
                cell.nameConfirm.setImage(UIImage(named: "confirm_button"), for: .normal)
//                cell.nameConfirm.isHidden = false
            }
            cell.nameEdit.addTarget(self, action: #selector(self.textFieldDidChange(sender:)), for: .editingChanged)
            cell.nameConfirm.addTarget(self, action: #selector(onNameEdit(sender:)), for: .touchUpInside)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "my_cartion_cell", for: indexPath) as! MyCartionCell
            cell.nameLabel.text = names[indexPath.row]
//            if isNameEditMode == false {
//                cell.nameDeleteBtn.isHidden = false
//            } else {
//                cell.nameDeleteBtn.isHidden = true
//            }
            cell.nameDeleteBtn.addTarget(self, action: #selector(onDelete(sender:)), for: .touchUpInside)
            cell.nameDeleteBtn.tag = indexPath.row
            return cell
        }
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        name = sender.text!
        if name == "" {
            if isNameEditMode == true {
                isNameEditMode = false
                self.myPageTable.reloadData()
            }
        } else {
            if isNameEditMode == false {
                isNameEditMode = true
                self.myPageTable.reloadData()
            }
        }
    }
    
    @objc func onNameEdit(sender: UIButton) {
        if isNameEditMode == false {
            delete(urlString: "\(User.base_url)api/\(User.email)/device/\(self.deviceId)")
        } else {
            nameModify(urlString: "\(User.base_url)api/device/\(self.deviceId)", name: self.name)
        }
    }
    
    @objc func onDelete(sender: UIButton) {
        delete(urlString: "\(User.base_url)api/\(User.email)/device/\(self.deviceId)")
    }
    
    private func nameModify(urlString: String, name: String) {
        let url = URL(string: urlString)!
        
        let param: Parameters = [
            "deviceName": name
        ]
        
        let alamo = AF.request(url, method: .put, parameters: param, encoding: JSONEncoding.default, headers: headers)
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(SignUp.self, from: jsonData)
                    if json.statusCode == 200 {
                        self.names[0] = "\(self.deviceId) : \(self.name)"
                        self.myPageEmailText.isEnabled = false
                        self.myPagePhoneText.isEnabled = false
                        self.isEditMode = false
                        self.isNameEditMode = false
                        self.myPageTable.reloadData()
                        self.myPageConfirm.isHidden = true
                    }
                } catch(let err) {
                    print("ERROR: \(err.localizedDescription)" )
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    private func delete(urlString: String) {
        
        print(urlString)
        let url = URL(string: urlString)!
        
        let alamo = AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(SignUp.self, from: jsonData)
                    if json.statusCode == 200 {
                        let alert = UIAlertController(title: "카션을 삭제 하시겠습니까?", message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "네", style: .default, handler: { action in
                            self.names.removeAll()
                            self.myPageEmailText.isEnabled = false
                            self.myPagePhoneText.isEnabled = false
                            self.isEditMode = false
                            self.isNameEditMode = false
                            self.myPageTable.reloadData()
                            self.myPageConfirm.isHidden = true
                            UserDefaults.standard.setValue(true, forKey: "delete")
                            self.view.makeToast("카션이 제거 되었습니다.\n카션을 연결 후 다시 등록해주세요.")
                        })
                        let cancelAction = UIAlertAction(title: "아니요", style: .cancel, handler: nil)
                        
                        alert.addAction(okAction)
                        alert.addAction(cancelAction)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                } catch(let err) {
                    print("Delete ERROR: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
}

extension MyPageViewController {
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 30, y: self.view.frame.size.height-50, width: 250, height: 80))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 10.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { (isCompleted) in
            toastLabel.removeFromSuperview()
        }
    )}
}

class MyPageBannerCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
}

class MyCartionCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameDeleteBtn: UIButton!
}

class MySettingCell: UITableViewCell {
 
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var nameConfirm: UIButton!
}
