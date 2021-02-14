//
//  CouponDialogController.swift
//  Cartion
//
//  Created by bellcon on 2021/01/30.
//  Copyright © 2021 belicon. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

class CouponDialogController: UIViewController {

    @IBOutlet weak var couponText: UITextField!
    
    private var headers: HTTPHeaders = ["Content-Type": "application/json", "Authorization" : User.token]
    private var userId = User.email
    
    // api/user/:userId/coupon/:couponValue
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onConfirm(_ sender: Any) {
        if couponText.text! == "카션" {
            putCoupon()
        } else {
            self.view.makeToast("카션을 입력하시고 쿠폰을 등록해주세요.")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.couponText.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.couponText.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        return true
    }
    
}

extension CouponDialogController {
    
    private func putCoupon() {
        
        let urlString = "\(User.base_url)api/user/\(userId)/coupon/카션"
        let encoding = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encoding!)
        
        let alamo = AF.request(url!, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(SignUp.self, from: jsonData)
                    if json.statusCode == 200 {
                        self.dismiss(animated: true, completion: nil)
                        self.view.makeToast("쿠폰이 사용되었습니다.")
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
