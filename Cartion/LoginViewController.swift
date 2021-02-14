//
//  LoginViewController.swift
//  Cartion
//
//  Created by bellcon on 2020/10/22.
//  Copyright © 2020 belicon. All rights reserved.
//

import UIKit
import FirebaseAuth
import Alamofire
import Toast_Swift

class LoginViewController: UIViewController {
    
    private var auth = Auth.auth()
    
    @IBOutlet weak var loginEmailText: UITextField!
    @IBOutlet weak var loginPasswordText: UITextField!
    
    private let pref = UserDefaults.standard
    
    private var email = ""
    private var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loginEmailText.setLeftPaddingPoints(50)
        loginPasswordText.setLeftPaddingPoints(50)
        
        if auth.currentUser != nil {
            if pref.string(forKey: "token") != nil {
                if pref.string(forKey: "token") != "" {
                    let url = URL(string: "\(User.base_url)token")
                    
                    let param: Parameters = [
                        "refreshToken" : pref.string(forKey: "token")!
                    ]
                    
                    let alamo = AF.request(url!, method: .put, parameters: param, encoding: JSONEncoding.default)
                    
                    alamo.responseJSON() { response in
                        switch response.result {
                        case .success(let res):
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                                let json = try JSONDecoder().decode(LoginAuth.self, from: jsonData)
                                if json.statusCode == 200 {
                                    let token = json.data.token.refreshToken
                                    print(token)
                                    User.token = "Bearer \(token)"
                                    User.email = self.pref.string(forKey: "email")!
                                    self.pref.setValue("Bearer \(token)", forKey: "token")
                                    let vc = self.storyboard!.instantiateViewController(identifier: "main_tab_vc")
                                    vc.modalPresentationStyle = .fullScreen
                                    self.present(vc, animated: true, completion: nil)
                                } else {
                                    self.view.makeToast("로그인 에러")
                                }
                            } catch(let err) {
                                print("Token Err: \(err.localizedDescription)")
                            }
                            break
                        case .failure(let err):
                            print("Token Failed: \(err.localizedDescription)")
                            break
                        }
                    }
                }
            } else {
                if pref.object(forKey: "intro") == nil || pref.bool(forKey: "intro") == true {
                    let introView = self.storyboard?.instantiateViewController(identifier: "intro_video_view") as! IntroVideoController
                    introView.modalPresentationStyle = .fullScreen
                    self.present(introView, animated: true, completion: nil)
                    //                showToast(message: "로그인을 다시 시도해주세요.")
                }
            }
        } else {
            if  pref.object(forKey: "intro") == nil || pref.bool(forKey: "intro") == true {
                let introView = self.storyboard?.instantiateViewController(identifier: "intro_video_view") as! IntroVideoController
                introView.modalPresentationStyle = .fullScreen
                self.present(introView, animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.loginEmailText.resignFirstResponder()
        self.loginPasswordText.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.loginEmailText.resignFirstResponder()
        self.loginPasswordText.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        return true
    }
    
    @IBAction func onLogin(_ sender: Any) {
        email = loginEmailText.text!
        password = loginPasswordText.text!
        
        auth.signIn(withEmail: email, password: password) { (user, err) in
            if user != nil {
                self.postJson()
            } else {
                self.view.makeToast("로그인 에러")
            }
        }
    }
    
    func postJson() {
        let url = URL(string: "\(User.base_url)login")
        
        let param: Parameters = [
            "userId" : email,
            "password" : password
        ]
        
        let alamo = AF.request(url!, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        alamo.responseJSON() { response in
//            print(response.result)
            switch response.result {
            case .success(let res):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(Login.self, from: jsonData)
                    if json.statusCode == 200 {
                        let token = json.data.token.refreshToken
                        User.token = "Bearer \(token)"
                        User.email = self.email
                        print("UserToken: \(User.token)")
                        self.pref.setValue(self.email, forKey: "email")
                        self.pref.setValue(self.password, forKey: "password")
                        self.pref.setValue("Bearer \(token)", forKey: "token")
                        let eula = json.data.eulaYn
                        print(eula)
                        if eula == "Y" {
                            let vc = self.storyboard!.instantiateViewController(identifier: "main_tab_vc")
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        } else {
                            let vc = self.storyboard!.instantiateViewController(identifier: "eula_vc")
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        }
                    } else {
                        self.view.makeToast("로그인 에러")
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
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
