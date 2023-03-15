//
//  ForgotPassword.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 15/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
class ForgotPassword: UIViewController {
    
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var txt_Email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        cornerRadius(viewName: self.btn_submit, radius: 8.0)
    }
    @IBAction func btnTap_Signup(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SignupVC") as! SignupVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnTap_Submit(_ sender: UIButton) {
        let urlString = API_URL + "forgotPassword"
        let params: NSDictionary = ["email":self.txt_Email.text!]
        self.Webservice_ForgotPassword(url: urlString, params: params)
    }
}
//MARK: Webservices
extension ForgotPassword
{
    func Webservice_ForgotPassword(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                let responseCode = jsonResponse!["status"].stringValue
                
                print(jsonResponse!)
                if responseCode == "1" {
                        showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
                }
                else {
                    self.dismiss(animated: true) {
                        showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                    }
                    
                }
            }
        }
    }
}
