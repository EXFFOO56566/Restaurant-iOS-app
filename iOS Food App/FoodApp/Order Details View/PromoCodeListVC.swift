//
//  PromoCodeListVC.swift
//  FoodApp
//
//  Created by iMac on 25/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON

class PromoCell: UITableViewCell {
    
    @IBOutlet weak var lbl_OfferCode: UILabel!
    @IBOutlet weak var btn_copy: UIButton!
    @IBOutlet weak var lbl_OfferName: UILabel!
    @IBOutlet weak var lbl_descripation: UILabel!
}
class PromoCodeListVC: UIViewController {
    
    @IBOutlet weak var TableView_PromocodeList: UITableView!
    var PromoCodeData = [JSON]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = API_URL + "promocodelist"
        self.Webservice_GetPromocodelist(url: urlString, params:[:])
    }
    @IBAction func btnTap_close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension PromoCodeListVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.TableView_PromocodeList.bounds.size.width, height: self.TableView_PromocodeList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
        messageLabel.sizeToFit()
        self.TableView_PromocodeList.backgroundView = messageLabel;
        if self.PromoCodeData.count == 0 {
            messageLabel.text = "NO DATA FOUND".localiz()
        }
        else {
            messageLabel.text = ""
        }
        return PromoCodeData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.TableView_PromocodeList.dequeueReusableCell(withIdentifier: "PromoCell") as! PromoCell
        let data = self.PromoCodeData[indexPath.row]
        cornerRadius(viewName: cell.btn_copy, radius: 6)
        cell.lbl_descripation.text = data["description"].stringValue
        cell.lbl_OfferName.text = data["offer_name"].stringValue
        cell.lbl_OfferCode.text = data["offer_code"].stringValue
        
        cell.btn_copy.tag = indexPath.row
        cell.btn_copy.addTarget(self, action: #selector(btn_Copy), for: .touchUpInside)
        return cell
    }
    @objc func btn_Copy(sender:UIButton!) {
        print("Button tapped")
        let data = self.PromoCodeData[sender.tag]
        UIPasteboard.general.string = data["offer_code"].stringValue
        self.dismiss(animated: true, completion: nil)
    }
}
//MARK: Webservices
extension PromoCodeListVC {
    func Webservice_GetPromocodelist(url:String, params:NSDictionary) -> Void {
        
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "GET", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].arrayValue
                    self.PromoCodeData = responseData
                    
                    self.TableView_PromocodeList.delegate = self
                    self.TableView_PromocodeList.dataSource = self
                    self.TableView_PromocodeList.reloadData()
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    
}
