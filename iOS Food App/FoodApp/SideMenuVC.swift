//
//  SideMenuVC.swift
//  WallPaperApp
//
//  Created by Mitesh's MAC on 23/12/19.
//  Copyright © 2019 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

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
    var menuArray = [String]()
    var menuImgeArray = [String]()
    var homeViewController = UINavigationController()
    var historyViewController = UINavigationController()
    var LoginViewController = UINavigationController()
    var SettingsViewController = UINavigationController()
    var RatingsViewController = UINavigationController()
    var FavoriteViewController = UINavigationController()
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaultManager.getStringFromUserDefaults(key: UD_isSkip) == "1"
        {
            if UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "en" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "N/A"
            {
                menuArray = ["Home","Order History","Favorite List","Ratings","Settings"]
                menuImgeArray = ["ic_Home","ic_OrderHistory","ic_heart","ic_rate","ic_settings"]
            }
            else{
//                menuArray = ["الصفحة الرئيسية","تاريخ الطلب","قائمة المفضلة","التقييمات","الإعدادات"]
//                menuImgeArray = ["ic_Home","ic_OrderHistory","ic_heart","ic_rate","ic_settings"]
                menuArray = ["Home","Order History","Favorite List","Ratings","Settings"]
                menuImgeArray = ["ic_Home","ic_OrderHistory","ic_heart","ic_rate","ic_settings"]
            }
        }
        else{
            
            if UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "en" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "N/A"
            {
                menuArray = ["Home","Order History","Favorite List","Ratings","Settings","Logout"]
                menuImgeArray = ["ic_Home","ic_OrderHistory","ic_heart","ic_rate","ic_settings","ic_logout"]
            }
            else{
//                menuArray = ["الصفحة الرئيسية","تاريخ الطلب","قائمة المفضلة","التقييمات","الإعدادات","تسجيل خروج"]
//                menuImgeArray = ["ic_Home","ic_OrderHistory","ic_heart","ic_rate","ic_settings","ic_logout"]
                menuArray = ["Home","Order History","Favorite List","Ratings","Settings","Logout"]
                menuImgeArray = ["ic_Home","ic_OrderHistory","ic_heart","ic_rate","ic_settings","ic_logout"]
            }
            
            
        }
        cornerRadius(viewName: self.imgProfile, radius: self.imgProfile.frame.height / 2)
        
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.homeViewController = UINavigationController(rootViewController: homeVC)
        self.homeViewController.setNavigationBarHidden(true, animated: true)
        
        let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "OrderHistoryVC") as! OrderHistoryVC
        self.historyViewController = UINavigationController(rootViewController: historyVC)
        self.historyViewController.setNavigationBarHidden(true, animated: true)
        
        let LoginsVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.LoginViewController = UINavigationController(rootViewController: LoginsVC)
        self.LoginViewController.setNavigationBarHidden(true,animated:true)
        
        
        let SettingVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.SettingsViewController = UINavigationController(rootViewController: SettingVC)
        self.SettingsViewController.setNavigationBarHidden(true,animated:true)
        
        let rateVC = self.storyboard?.instantiateViewController(withIdentifier: "RatingsVC") as! RatingsVC
        self.RatingsViewController = UINavigationController(rootViewController: rateVC)
        self.RatingsViewController.setNavigationBarHidden(true,animated:true)
        
        let FavoritesVC = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteListVC") as! FavoriteListVC
        self.FavoriteViewController = UINavigationController(rootViewController: FavoritesVC)
        self.FavoriteViewController.setNavigationBarHidden(true,animated:true)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if UserDefaultManager.getStringFromUserDefaults(key: UD_isSkip) != "1"
        {

            let urlString = API_URL + "getprofile"
            let params: NSDictionary = ["user_id":UserDefaults.standard.value(forKey: UD_userId) as! String]
            self.Webservice_GetProfile(url: urlString, params: params)
        }
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
            if UserDefaultManager.getStringFromUserDefaults(key: UD_isSkip) == "1"
            {
                self.slideMenuController()?.changeMainViewController(self.LoginViewController, close: true)
            }
            else{
              self.slideMenuController()?.changeMainViewController(self.historyViewController, close: true)
            }
            
        }
        if indexPath.row == 2
        {
            if UserDefaultManager.getStringFromUserDefaults(key: UD_isSkip) == "1"
            {
                self.slideMenuController()?.changeMainViewController(self.LoginViewController, close: true)
            }
            else{
                self.slideMenuController()?.changeMainViewController(self.FavoriteViewController, close: true)
            }
            
        }
        if indexPath.row == 3
        {
            self.slideMenuController()?.changeMainViewController(self.RatingsViewController, close: true)
            
        }
        if indexPath.row == 4
        {
            self.slideMenuController()?.changeMainViewController(self.SettingsViewController, close: true)
            
        }
        if indexPath.row == 5
        {
            UserDefaultManager.setStringToUserDefaults(value: "", key: UD_userId)
            self.slideMenuController()?.changeMainViewController(self.LoginViewController, close: true)
            
        }
    }
}
//MARK: Webservices
extension SideMenuVC {
    func Webservice_GetProfile(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
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
