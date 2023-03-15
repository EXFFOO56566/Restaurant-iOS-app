//
//  ChangePassswordVC.swift
//  FoodDriver
//
//  Created by iMac on 04/08/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
class ChangePassswordVC: UIViewController {
    
    @IBOutlet weak var btn_Reset: UIButton!
    @IBOutlet weak var txt_confirmPassword: UITextField!
    @IBOutlet weak var txt_NewPassword: UITextField!
    @IBOutlet weak var txt_oldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cornerRadius(viewName: self.btn_Reset, radius: 8.0)
    }
    @IBAction func btnTap_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnTap_Reset(_ sender: UIButton) {
        if self.txt_oldPassword.text! == "" || self.txt_NewPassword.text == "" || self.txt_confirmPassword.text! == "" {
            showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: "Please enter all details")
        }
        else if self.txt_NewPassword.text! != self.txt_confirmPassword.text! {
            showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: "New password & Confirm password must be same")
        }
        else {
            let urlString = API_URL + "driverchangepassword"
            let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId),
                                        "old_password":self.txt_oldPassword.text!,
                                        "new_password":self.txt_NewPassword.text!]
            self.Webservice_ChangePassword(url: urlString, params: params)
        }
    }
    
}
//MARK: Webservices
extension ChangePassswordVC
{
    func Webservice_ChangePassword(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
}
