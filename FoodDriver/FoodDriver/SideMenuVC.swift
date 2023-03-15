//
//  SideMenuVC.swift
//  FoodDriver
//
//  Created by Mitesh's MAC on 10/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import SlideMenuControllerSwift

class MenuTableCell: UITableViewCell {
    @IBOutlet weak var lbl_menu: UILabel!
    @IBOutlet weak var img_menu: UIImageView!
}
class SideMenuVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var tbl_menu: UITableView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    
    //MARK: Variables
    var menuArray = ["Home","Order History","Settings","Logout"]
    var menuImgeArray = ["ic_Home","ic_OrderHistory","ic_settings","ic_logout"]
    var homeViewController = UINavigationController()
    var OrderhistoryViewController = UINavigationController()
    var LoginViewController = UINavigationController()
    var SettingViewController = UINavigationController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cornerRadius(viewName: self.imgProfile, radius: self.imgProfile.frame.height / 2)
        
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
        self.homeViewController = UINavigationController(rootViewController: homeVC)
        self.homeViewController.setNavigationBarHidden(true, animated: true)
        
        let HistoryVC = self.storyboard?.instantiateViewController(withIdentifier: "OrderHistoryVC") as! OrderHistoryVC
        self.OrderhistoryViewController = UINavigationController(rootViewController: HistoryVC)
        self.OrderhistoryViewController.setNavigationBarHidden(true, animated: true)
        
        let LoginsVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.LoginViewController = UINavigationController(rootViewController: LoginsVC)
        self.LoginViewController.setNavigationBarHidden(true, animated: true)
        
        let SettingsView = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.SettingViewController = UINavigationController(rootViewController: SettingsView)
        self.SettingViewController.setNavigationBarHidden(true, animated: true)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let urlString = API_URL + "getprofile"
        let params: NSDictionary = ["user_id":UserDefaults.standard.value(forKey: UD_userId) as! String]
        self.Webservice_GetProfile(url: urlString, params: params)
    }
    
}

//MARK: Tableview methods
extension SideMenuVC : UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell") as! MenuTableCell
        
        cell.lbl_menu.text = self.menuArray[indexPath.row]
        cell.img_menu.image = UIImage.init(named: self.menuImgeArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            self.slideMenuController()?.changeMainViewController(self.homeViewController, close: true)
        }
        if indexPath.row == 1
        {
            self.slideMenuController()?.changeMainViewController(self.OrderhistoryViewController, close: true)
        }
        if indexPath.row == 2
        {
            self.slideMenuController()?.changeMainViewController(self.SettingViewController, close: true)
        }
        if indexPath.row == 3
        {
            UserDefaultManager.setStringToUserDefaults(value: "", key: UD_userId)
            self.slideMenuController()?.changeMainViewController(self.LoginViewController, close: true)
        }
    }
}
//MARK: Webservices
extension SideMenuVC {
    func Webservice_GetProfile(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:false, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].dictionaryValue
                    print(responseData)
                    self.imgProfile.sd_setImage(with: URL(string: responseData["profile_image"]!.stringValue), placeholderImage: UIImage(named: "placeholder_image"))
                    self.lblUsername.text = responseData["name"]?.stringValue
                }
                else if responseCode == "2"
                {
                     UserDefaultManager.setStringToUserDefaults(value: "", key: UD_userId)
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let objVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    let nav : UINavigationController = UINavigationController(rootViewController: objVC)
                    nav.navigationBar.isHidden = true
                    UIApplication.shared.windows[0].rootViewController = nav
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
}
