//
//  SignupVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 04/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignupVC: UIViewController {
    @IBOutlet weak var btn_signup: UIButton!
    @IBOutlet weak var txt_MobileNumber: UITextField!
    @IBOutlet weak var txt_Password: UITextField!
    @IBOutlet weak var txt_Email: UITextField!
    @IBOutlet weak var txt_FirstName: UITextField!
    @IBOutlet weak var btn_showPassword: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        cornerRadius(viewName: self.btn_signup, radius: 8.0)
        self.btn_showPassword.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
    }
}
extension SignupVC
{
    
    @IBAction func btnTap_ShowPassword(_ sender: UIButton) {
        if self.btn_showPassword.image(for: .normal) == UIImage(systemName: "eye.slash.fill")
        {
            self.btn_showPassword.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            self.txt_Password.isSecureTextEntry = false
        }
        else{
            self.txt_Password.isSecureTextEntry = true
            self.btn_showPassword.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }
        
    }
    
    
    @IBAction func btnTap_signup(_ sender: UIButton) {
        let urlString = API_URL + "register"
        let params: NSDictionary = ["name":self.txt_FirstName.text!,
                                    "email":self.txt_Email.text!,
                                    "mobile":self.txt_MobileNumber.text!,
                                    "password":self.txt_Password.text!
        ]
        self.Webservice_Register(url: urlString, params: params)
    }
    
    @IBAction func btnTap_Login(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
extension SignupVC
{
    func Webservice_Register(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let userData = jsonResponse!["data"].dictionaryValue
                    
                    let userId = userData["id"]!.stringValue
                    UserDefaultManager.setStringToUserDefaults(value: userId, key: UD_userId)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
}
