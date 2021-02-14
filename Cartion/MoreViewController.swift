//
//  MoreViewController.swift
//  Cartion
//
//  Created by bellcon on 2020/12/29.
//  Copyright © 2020 belicon. All rights reserved.
//

import UIKit
import Alamofire

class MoreViewController: UIViewController {

    @IBOutlet weak var moreBannerCollection: UICollectionView!
    
    private var banners = Array<String>()
    private var bannerPos = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getBanner()
        bannerTimer()
    }
    
    private func getBanner() {
        let url = URL(string: "\(User.base_url)api/banners")
        let headers: HTTPHeaders = ["Authorization" : User.token]
        
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
                            self.moreBannerCollection.reloadData()
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
}

extension MoreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if banners.count == 0 {
            return 0
        }
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "more_banner_cell", for: indexPath) as! MoreBannerCell
        let url = URL(string: banners[indexPath.row])
        DispatchQueue.main.async {
            let data = try? Data(contentsOf: url!)
            cell.imgView.image = UIImage(data: data!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: moreBannerCollection.frame.size.width  , height:  moreBannerCollection.frame.height)
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
            moreBannerCollection.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: true)
            bannerPos = 0
            return
        }
        // 다음 페이지로 전환
        bannerPos += 1
        moreBannerCollection.scrollToItem(at: NSIndexPath(item: bannerPos, section: 0) as IndexPath, at: .right, animated: true)
    }
}

class MoreBannerCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
}
