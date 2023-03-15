//
//  ForgotPasswordVC.swift
//  FoodDriver
//
//  Created by iMac on 04/08/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var btn_Submit: UIButton!
    @IBOutlet weak var txt_Email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        cornerRadius(viewName: self.btn_Submit, radius: 8.0)
        
    }
    @IBAction func btnTap_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTap_Submit(_ sender: UIButton) {
        let urlString = API_URL + "driverforgotPassword"
        let params: NSDictionary = ["email":self.txt_Email.text!]
        self.Webservice_ForgotPassword(url: urlString, params: params)
    }
}
//MARK: Webservices
extension ForgotPasswordVC
{
    func Webservice_ForgotPassword(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                let responseCode = jsonResponse!["status"].stringValue
                let responseMessage = jsonResponse!["message"].stringValue
                print(jsonResponse!)
                if responseCode == "1" {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: responseMessage)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: responseMessage)
                }
            }
        }
    }
}
