//
//  HornViewController.swift
//  Cartion
//
//  Created by bellcon on 2021/01/04.
//  Copyright © 2021 belicon. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import AVKit
import Toast_Swift

class HornViewController: UIViewController {
    
    @IBOutlet weak var hornBannerCollection: UICollectionView!
    @IBOutlet weak var hornAllBtn: UIButton!
    @IBOutlet weak var hornAllBar: UIView!
    @IBOutlet weak var hornCustomBtn: UIButton!
    @IBOutlet weak var hornCustomBar: UIView!
    @IBOutlet weak var hornCategoryText: UITextField!
    @IBOutlet weak var hornTable: UITableView!
    @IBOutlet weak var hornShopBtn: UIButton!
    
    private var banners = Array<String>()
    private var bannerPos = 0
    
    private var categorys = Array<CategoryList>()
    private var categoryId = ""
    
    private var hornList = Array<HornList>()
    private var limit = 20
    
    private let headers: HTTPHeaders = ["Authorization" : User.token, "Content-Type" : "application/json"]
    
//    private var audioPlayer : AVPlayer!
    private var audioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        getBanner()
        bannerTimer()
        getHorn()
        onCategoryPicker()
        getCategorySettins()
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
                            self.hornBannerCollection.reloadData()
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
    
    @IBAction func onAllBtn(_ sender: Any) {
        hornAllBtn.setTitleColor(UIColor(rgb: 0x7F44A6), for: .normal)
        hornAllBtn.titleLabel?.font = UIFont(name: "S-CoreDream-7ExtraBold", size: 11)
        hornAllBar.isHidden = false
        hornAllBar.backgroundColor = UIColor(rgb: 0x7F44A6)
        hornCustomBtn.setTitleColor(UIColor(rgb: 0x606060), for: .normal)
        hornCustomBtn.titleLabel?.font = UIFont(name: "S-CoreDream-5Medium", size: 11)
        hornShopBtn.isHidden = true
        if hornCustomBar.isHidden == false {
            hornList.removeAll()
            getHorn()
        }
        hornCustomBar.isHidden = true
//        hornCustomBar.backgroundColor = UIColor(rgb: 0x606060)
    }
    
    @IBAction func onCustomBtn(_ sender: Any) {
        hornAllBtn.setTitleColor(UIColor(rgb: 0x606060), for: .normal)
        hornAllBtn.titleLabel?.font = UIFont(name: "S-CoreDream-5Medium", size: 11)
//        hornAllBar.backgroundColor = UIColor(rgb: 0x606060)
        hornShopBtn.isHidden = false
        if hornAllBar.isHidden == false {
            hornList.removeAll()
            getCustomHorn()
        }
        hornAllBar.isHidden = true
        hornCustomBtn.setTitleColor(UIColor(rgb: 0x7F44A6), for: .normal)
        hornCustomBtn.titleLabel?.font = UIFont(name: "S-CoreDream-7ExtraBold", size: 11)
        hornCustomBar.isHidden = false
        hornCustomBar.backgroundColor = UIColor(rgb: 0x7F44A6)
    }
    
    @IBAction func onCategory(_ sender: Any) {
        onCategoryReload(id: categoryId)
    }
    
    @IBAction func onHornShop(_ sender: Any) {
        let url = URL(string: "http://www.cartion.co.kr/front/community/bbsList.do?bbsId=request")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension HornViewController {
    
    func getHorn() {
        let url = URL(string: "\(User.base_url)api/horns?offset=0&limit=\(limit)&categoryId=")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: URLEncoding.queryString, headers: headers)
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(Horn.self, from: jsonData)
                    if json.statusCode == 200 {
                        for item in json.data.hornList {
                            self.hornList.append(HornList(hornId: item.hornId, hornName: item.hornName, categoryName: item.categoryName, wavPath: item.wavPath, adpcmPath: item.adpcmPath))
                            self.hornTable.reloadData()
                        }
                    }
                } catch(let err) {
                    print("HORN ERROR: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Horn Failure: \(err.localizedDescription)")
                break
            }
        }
    }
    
    func getCustomHorn() {
        let url = URL(string: "\(User.base_url)api/customHorns")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(CustomHorn.self, from: jsonData)
                    if json.statusCode == 200 {
                        if json.data.hornList.count == 0{
                            self.hornTable.reloadData()
                        } else {
                            for item in json.data.hornList {
                                self.hornList.append(HornList(hornId: item.hornId, hornName: item.hornName, categoryName: item.categoryName, wavPath: item.wavPath, adpcmPath: item.adpcmPath))
                                self.hornTable.reloadData()
                            }
                        }
                    }
                } catch(let err) {
                    print("CustomHorn ERROR: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("CustomHorn Failure: \(err.localizedDescription)")
                break
            }
        }
    }
}

extension HornViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func onCategoryReload(id: String) {
        self.hornList.removeAll()
        let url = URL(string: "\(User.base_url)api/horns?offset=0&limit=20&categoryId=\(id)")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: URLEncoding.queryString, headers: headers)
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(Horn.self, from: jsonData)
                    if json.statusCode == 200 {
                        for item in json.data.hornList {
                            self.hornList.append(HornList(hornId: item.hornId, hornName: item.hornName, categoryName: item.categoryName, wavPath: item.wavPath, adpcmPath: item.adpcmPath))
                            self.hornTable.reloadData()
                        }
                    }
                } catch(let err) {
                    print("HORN ERROR: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Horn Failure: \(err.localizedDescription)")
                break
            }
        }
    }
    
    func getCategorySettins() {
        let url = URL(string: "\(User.base_url)api/categories")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(Category.self, from: jsonData)
                    if json.statusCode == 200 {
                        self.categorys.append(CategoryList(categoryId: "", categoryName: "전체"))
                        for item in json.data.categoryList {
                            self.categorys.append(CategoryList(categoryId: item.categoryId, categoryName: item.categoryName))
                        }
                    }
                } catch(let err) {
                    print("Category ERROR: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Category Failure: \(err.localizedDescription)")
                break
            }
        }
    }
    
    func onCategoryPicker() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        hornCategoryText.inputView = pickerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categorys.count
    }


    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categorys[row].categoryName
    }


    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("\(categorys[row].categoryId) : \(categorys[row].categoryName)")
        hornCategoryText.text = categorys[row].categoryName
        categoryId = categorys[row].categoryId
        self.view.endEditing(true)
    }
}

extension HornViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if banners.count == 0 {
            return 0
        }
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "horn_banner_cell", for: indexPath) as! HornBannerCell
        let url = URL(string: banners[indexPath.row])
        let data = try? Data(contentsOf: url!)
        cell.imgView.image = UIImage(data: data!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: hornBannerCollection.frame.size.width  , height:  hornBannerCollection.frame.height)
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
            hornBannerCollection.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: true)
            bannerPos = 0
            return
        }
        // 다음 페이지로 전환
        bannerPos += 1
        hornBannerCollection.scrollToItem(at: NSIndexPath(item: bannerPos, section: 0) as IndexPath, at: .right, animated: true)
    }
}

extension HornViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hornList.count == 0 {
            return 0
        }
        return hornList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "horn_cell", for: indexPath) as! HornCell
        cell.hornPos.text = "\(indexPath.row + 1)"
        if hornList[indexPath.row].categoryName == "기본" {
            cell.hornCategory.text = "카션 기본음"
        } else {
            cell.hornCategory.text = "카션 \(hornList[indexPath.row].categoryName)"
        }
        cell.hornName.text = hornList[indexPath.row].hornName
        cell.hornPlay.addTarget(self, action: #selector(onPreview(sender:)), for: .touchUpInside)
        cell.hornPlay.tag = indexPath.row
        cell.hornDown.addTarget(self, action: #selector(onDownload(sender:)), for: .touchUpInside)
        cell.hornDown.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == hornList.count {
            limit = limit + 20
            print("\(limit)")
            hornList.removeAll()
            getHorn()
        }
    }
    
    @objc func onPreview(sender: UIButton) {
        play(urlString: "https://api.cartion.co.kr:9984/api/horn/wav/\(hornList[sender.tag].hornId)/")
    }
    
    @objc func onDownload(sender: UIButton) {
        down(urlString: "https://api.cartion.co.kr:9984/api/horn/ADPCM/\(hornList[sender.tag].hornId)/", fileName: hornList[sender.tag].hornId, index: sender.tag)
    }
    
    func play(urlString: String) {
        
        let url = URL(string: urlString)
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: URLEncoding.queryString, headers: headers)
        alamo.responseData() { response in
            switch response.result {
            case .success(let res):
                print(res)
                let data = res as Data
                print(data)
                do {
                    self.audioPlayer = try AVAudioPlayer(data: data)
                    self.audioPlayer.prepareToPlay()
                    self.audioPlayer.play()
                } catch let err {
                    print(err.localizedDescription)
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
    }
    
    func down(urlString: String, fileName: String, index: Int) {
        // 파일매니저
        let fileManager = FileManager.default
        // 앱 경로
        let appURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // 파일 경로 생성
        let fileURL = appURL.appendingPathComponent("horn").appendingPathComponent("\(fileName).wav")
        // 파일 경로 지정 및 다운로드 옵션 설정 ( 이전 파일 삭제 , 디렉토리 생성 )
        let destination: DownloadRequest.Destination = { _, _ in
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        // 다운로드 시작
        AF.download(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers, to: destination).downloadProgress { (progress) in
        }.response{ response in
            if response.error != nil {
                self.view.makeToast("파일 다운로드 실패")
            }else{
                switch response.result {
                case .success(let url):
                    print(url!)
                    let hornSave = UserDefaults.standard
                    let id = self.hornList[index].hornId
                    hornSave.set(id, forKey: "\(id)id")
                    hornSave.set(self.hornList[index].hornName, forKey: "\(id)hornName")
                    hornSave.set(self.hornList[index].categoryName, forKey: "\(id)category")
                    print("FILENAME: \(id)id")
                    print("id: ", hornSave.string(forKey: "\(id)hornName")!)
                    self.view.makeToast("파일 다운로드 완료")
                    break
                case .failure(let err):
                    print(err.localizedDescription)
                    break
                }
            }
        }
    }
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

class HornBannerCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
}

class HornCell: UITableViewCell {
    
    @IBOutlet weak var hornFlag: UIImageView!
    @IBOutlet weak var hornPos: UILabel!
    @IBOutlet weak var hornCategory: UILabel!
    @IBOutlet weak var hornName: UILabel!
    @IBOutlet weak var hornPlay: UIButton!
    @IBOutlet weak var hornDown: UIButton!
}
