//
//  RatingsVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 15/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON

class RatingCell: UITableViewCell {
    
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_Descipation: UILabel!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var img_rate: UIImageView!
}
class RatingsVC: UIViewController {
    @IBOutlet weak var Tableview_RatingsList: UITableView!
    @IBOutlet weak var lbl_titleLabel: UILabel!
    var refreshControl = UIRefreshControl()
    var RatingArray = [JSON]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Tableview_RatingsList.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshData(_:)), for: .valueChanged)
        self.lbl_titleLabel.text = "Ratings".localiz()
    }
    @objc private func refreshData(_ sender: Any) {
        self.refreshControl.endRefreshing()
       let urlString = API_URL + "rattinglist"
        self.Webservice_RatingsData(url: urlString, params:[:])
    }
    override func viewWillAppear(_ animated: Bool) {
        let urlString = API_URL + "rattinglist"
        self.Webservice_RatingsData(url: urlString, params:[:])
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
    @IBAction func btnTap_Add(_ sender: UIButton) {
        if UserDefaultManager.getStringFromUserDefaults(key:UD_isSkip) == "1"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let objVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let nav : UINavigationController = UINavigationController(rootViewController: objVC)
            nav.navigationBar.isHidden = true
            UIApplication.shared.windows[0].rootViewController = nav
        }else{
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "WriteReviewVC") as! WriteReviewVC
            VC.modalPresentationStyle = .overFullScreen
            VC.modalTransitionStyle = .crossDissolve
            VC.delegate = self
            self.present(VC,animated: true,completion: nil)
        }
        
    }
}
extension RatingsVC: WriteReviewVCDelegate {
    func refreshData() {
        print("yes")
        let urlString = API_URL + "rattinglist"
        self.Webservice_RatingsData(url: urlString, params:[:])
    }
}
extension RatingsVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.Tableview_RatingsList.bounds.size.width, height: self.Tableview_RatingsList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
        messageLabel.sizeToFit()
        self.Tableview_RatingsList.backgroundView = messageLabel;
        if self.RatingArray.count == 0 {
            messageLabel.text = "NO RATINGS DATA".localiz()
        }
        else {
            messageLabel.text = ""
        }
        return RatingArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.Tableview_RatingsList.dequeueReusableCell(withIdentifier: "RatingCell") as! RatingCell
        let data = self.RatingArray[indexPath.row]
        cell.lbl_name.text = data["name"].stringValue
        cell.lbl_Descipation.text = data["comment"].stringValue
        cell.lbl_date.text = data["created_at"].stringValue
        cell.img_rate.image = UIImage(named: "0\(data["ratting"].stringValue)")
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
//MARK: Webservices
extension RatingsVC {
    func Webservice_RatingsData(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "GET", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].arrayValue
                    self.RatingArray = responseData
                    self.Tableview_RatingsList.delegate = self
                    self.Tableview_RatingsList.dataSource = self
                    self.Tableview_RatingsList.reloadData()
                    
                }
                else  {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    
}
