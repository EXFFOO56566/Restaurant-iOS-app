//
//  SettingsVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 11/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import LanguageManager_iOS
import SlideMenuControllerSwift
class SettingsVC: UIViewController {
    @IBOutlet weak var lbl_Version: UILabel!
    @IBOutlet weak var lbl_titleLabel: UILabel!
    @IBOutlet weak var btn_Language: UIButton!
    @IBOutlet weak var btn_privacyPolicy: UIButton!
    @IBOutlet weak var btn_ChangePassword: UIButton!
    @IBOutlet weak var btn_EditProfile: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_titleLabel.text = "Settings".localiz()
        self.btn_EditProfile.setTitle("Edit Profile".localiz(), for: .normal)
        self.btn_ChangePassword.setTitle("Change Password".localiz(), for: .normal)
        self.btn_privacyPolicy.setTitle("Privacy policy".localiz(), for: .normal)
        self.btn_Language.setTitle("Change Layout".localiz(), for: .normal)
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "0"
        self.lbl_Version.text = "Version \(version)(\(build))"
    }
    @IBAction func btnTap_Menu(_ sender: UIButton) {
        if UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "en" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "N/A"
        {
            self.slideMenuController()?.openLeft()
        }
        else {
            self.slideMenuController()?.openRight()
        }
    }
    @IBAction func btnTap_EditProfile(_ sender: UIButton) {
        if UserDefaultManager.getStringFromUserDefaults(key:UD_isSkip) == "1"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let objVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let nav : UINavigationController = UINavigationController(rootViewController: objVC)
            nav.navigationBar.isHidden = true
            UIApplication.shared.windows[0].rootViewController = nav
        }else{
            let vc = self.storyboard?.instantiateViewController(identifier: "EditProfileVC") as! EditProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func btnTap_ChangePassword(_ sender: UIButton) {
        if UserDefaultManager.getStringFromUserDefaults(key:UD_isSkip) == "1"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let objVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let nav : UINavigationController = UINavigationController(rootViewController: objVC)
            nav.navigationBar.isHidden = true
            UIApplication.shared.windows[0].rootViewController = nav
        }
        else{
            let vc = self.storyboard?.instantiateViewController(identifier: "ChangePassswordVC") as! ChangePassswordVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    @IBAction func btnTap_Shareapp(_ sender: UIButton) {
            let text = "App Link"
                  let textShare = [ text ]
                  let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
                  activityViewController.popoverPresentationController?.sourceView = self.view
                  self.present(activityViewController, animated: true, completion: nil)
       }
    @IBAction func btnTap_PrivacyPolicy(_ sender: UIButton) {
        guard let url = URL(string: Privacy_URL) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnTap_Language(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Select Application Layout".localiz(), preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "LTR".localiz(), style: .default) { (action) in
            let selectedLanguage: Languages = .en
            UserDefaultManager.setStringToUserDefaults(value: "en", key: UD_isSelectLng)
            // change the language
            LanguageManager.shared.setLanguage(language: selectedLanguage,
                                               viewControllerFactory: { title -> UIViewController in
                                                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                                let objVC = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                                                let sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
                                                let appNavigation: UINavigationController = UINavigationController(rootViewController: objVC)
                                                appNavigation.setNavigationBarHidden(true, animated: true)
                                                let slideMenuController = SlideMenuController(mainViewController: appNavigation, leftMenuViewController: sideMenuViewController)
                                                slideMenuController.changeLeftViewWidth(UIScreen.main.bounds.width * 0.8)
                                                slideMenuController.removeLeftGestures()
                                                UIApplication.shared.windows[0].rootViewController = slideMenuController
                                                return slideMenuController
            }) { view in
                // do custom animation
                view.transform = CGAffineTransform(scaleX: 2, y: 2)
                view.alpha = 0
            }
        }
        let cameraAction = UIAlertAction(title: "RTL".localiz(), style: .default) { (action) in
            let selectedLanguage: Languages = .ar
            UserDefaultManager.setStringToUserDefaults(value: "ar", key: UD_isSelectLng)
            // change the language
            LanguageManager.shared.setLanguage(language: selectedLanguage,
                                               viewControllerFactory: { title -> UIViewController in
                                                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                                let objVC = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                                                let sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
                                                let appNavigation: UINavigationController = UINavigationController(rootViewController: objVC)
                                                appNavigation.setNavigationBarHidden(true, animated: true)
                                                let slideMenuController = SlideMenuController(mainViewController: appNavigation, rightMenuViewController: sideMenuViewController)
                                                slideMenuController.changeRightViewWidth(UIScreen.main.bounds.width * 0.8)
                                                slideMenuController.removeRightGestures()
                                                UIApplication.shared.windows[0].rootViewController = slideMenuController
                                                return slideMenuController
            }) { view in
                // do custom animation
                view.transform = CGAffineTransform(scaleX: 2, y: 2)
                view.alpha = 0
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
