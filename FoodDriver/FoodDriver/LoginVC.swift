//
//  LoginVC.swift
//  FoodDriver
//
//  Created by Mitesh's MAC on 10/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import SwiftyJSON

class LoginVC: UIViewController {
    
    @IBOutlet weak var txt_Email: UITextField!
    @IBOutlet weak var txt_Password: UITextField!
    @IBOutlet weak var btn_Login: UIButton!
    @IBOutlet weak var btn_showPassword: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        cornerRadius(viewName: self.btn_Login, radius:8.0)
        self.btn_showPassword.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
    }
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
    @IBAction func btnTap_ForgotPassword(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnTap_Login(_ sender: UIButton) {
        //        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        //        let objVC = storyBoard.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
        //        let sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
        //        let appNavigation: UINavigationController = UINavigationController(rootViewController: objVC)
        //        appNavigation.setNavigationBarHidden(true, animated: true)
        //        let slideMenuController = SlideMenuController(mainViewController: appNavigation, leftMenuViewController: sideMenuViewController)
        //        slideMenuController.changeLeftViewWidth(UIScreen.main.bounds.width * 0.8)
        //        slideMenuController.removeLeftGestures()
        //        UIApplication.shared.windows[0].rootViewController = slideMenuController
        //
        let urlString = API_URL + "driverlogin"
        let params: NSDictionary = [
            "email":self.txt_Email.text!,
            "password":self.txt_Password.text!,
            "token":UserDefaultManager.getStringFromUserDefaults(key: UD_fcmToken)
        ]
        self.Webservice_Login(url: urlString, params: params)
    }
}
extension LoginVC
{
    func Webservice_Login(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
                //                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let userData = jsonResponse!["data"].dictionaryValue
                    
                    let userId = userData["id"]!.stringValue
                    UserDefaultManager.setStringToUserDefaults(value: userId, key: UD_userId)
                    UserDefaultManager.setStringToUserDefaults(value: userData["name"]!.stringValue, key: UD_Name)
                    
                    if UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "en" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "N/A"
                    {
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let objVC = storyBoard.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
                        let sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
                        let appNavigation: UINavigationController = UINavigationController(rootViewController: objVC)
                        appNavigation.setNavigationBarHidden(true, animated: true)
                        let slideMenuController = SlideMenuController(mainViewController: appNavigation, leftMenuViewController: sideMenuViewController)
                        slideMenuController.changeLeftViewWidth(UIScreen.main.bounds.width * 0.8)
                        UIApplication.shared.windows[0].rootViewController = slideMenuController
                    }
                    else
                    {
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let objVC = storyBoard.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
                        let sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
                        let appNavigation: UINavigationController = UINavigationController(rootViewController: objVC)
                        appNavigation.setNavigationBarHidden(true, animated: true)
                        let slideMenuController = SlideMenuController(mainViewController: appNavigation, rightMenuViewController: sideMenuViewController)
                        slideMenuController.changeRightViewWidth(UIScreen.main.bounds.width * 0.8)
                        UIApplication.shared.windows[0].rootViewController = slideMenuController
                    }
                    
                    
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                    //                    showAlertMessage(titleStr: "", messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
}
