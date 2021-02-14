//
//  SignUpViewController.swift
//  Cartion
//
//  Created by bellcon on 2020/11/11.
//  Copyright © 2020 belicon. All rights reserved.
//

import UIKit
import FirebaseAuth
import Alamofire
import Toast_Swift

class SignUpViewController: UIViewController {
    
    private var auth = Auth.auth()

    @IBOutlet weak var signEmail: UITextField!
    @IBOutlet weak var signEmailNoti: UILabel!
    @IBOutlet weak var signPw: UITextField!
    @IBOutlet weak var signPwNoti: UILabel!
    @IBOutlet weak var signPwCheck: UITextField!
    @IBOutlet weak var signPwCheckNoti: UILabel!
    @IBOutlet weak var signPhone: UITextField!
    
    private var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signPw.addTarget(self, action: #selector(self.passwordDidChanged(sender:)), for: .editingChanged)
        signPwCheck.addTarget(self, action: #selector(self.passwordCheckDidChanged(sender:)), for: .editingChanged)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.signEmail.resignFirstResponder()
        self.signPw.resignFirstResponder()
        self.signPwCheck.resignFirstResponder()
        self.signPhone.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.signEmail.resignFirstResponder()
        self.signPw.resignFirstResponder()
        self.signPwCheck.resignFirstResponder()
        self.signPhone.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        return true
    }
    
    @IBAction func onEmailCheck(_ sender: Any) {
        email = signEmail.text!
        
        let url = URL(string: "\(User.base_url)noauth/user/\(email)")
        
        let alamo = AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default)
        
        alamo.responseJSON() { response in
//            print(response.result)
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(SignUpCheck.self, from: jsonData)
                    if json.statusCode == 200 {
                        let isAvailable = json.data.isAvailable
                        if isAvailable == true {
                            self.view.makeToast("사용이 가능합니다.")
                            self.signEmailNoti.text = "사용이 가능합니다. 발송된 이메일을 확인 후 사용이 가능합니다."
                        } else {
                            self.view.makeToast("사용이 불가능합니다.")
                            self.signEmailNoti.text = "사용이 불가능한 이메일 입니다."
                        }
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
    
    @IBAction func onSign(_ sender: Any) {
        if self.signPwNoti.isHidden == false {
            self.view.makeToast("회원가입 정보를 다시 확인해주세요.")
        } else if self.signPwCheckNoti.isHidden == false {
            self.view.makeToast("회원가입 정보를 다시 확인해주세요.")
        } else {
            onSignUp()
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func passwordDidChanged(sender: UITextField) {
        if sender.text!.count < 6 {
            self.signPwNoti.isHidden = false
        } else {
            self.signPwNoti.isHidden = true
        }
    }
    
    @objc private func passwordCheckDidChanged(sender: UITextField) {
        if self.signPw.text! == self.signPwCheck.text! {
            self.signPwCheckNoti.isHidden = true
        } else {
            self.signPwCheckNoti.isHidden = false
        }
    }
}

extension SignUpViewController {
    
    private func onSignUp() {
        let password = signPw.text!
        
        let url = URL(string: "\(User.base_url)join")
        
        let param: Parameters = [
            "userId" : email,
            "password" : password,
            "phoneNumber" : signPhone.text!
        ]
        
        let alamo = AF.request(url!, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        alamo.responseJSON() { response in
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(SignUp.self, from: jsonData)
                    if json.statusCode == 201 || json.statusCode == 200 {
                        self.auth.createUser(withEmail: self.email, password: password) { (user, err) in
                            if user != nil {
                                self.auth.currentUser!.sendEmailVerification { (err) in
                                    if err == nil {
                                        self.dismiss(animated: true, completion: nil)
                                    } else {
                                        self.view.makeToast("이메일 발송에서 오류가 발생하였습니다.")
                                    }
                                }
                            } else {
                                self.view.makeToast("회원가입 도중 오류가 발생하였습니다.")
                            }
                        }
                    }
                } catch(let err) {
                    print("Sign Err: \(err.localizedDescription)")
                }
                break
            case .failure(let err):
                print("Sign Faild: \(err.localizedDescription)")
                break
            }
        }
    }
}
