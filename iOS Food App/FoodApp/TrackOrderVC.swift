//
//  TrackOrderVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 11/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON

class TrackOrderVC: UIViewController {

    @IBOutlet weak var lbl_Line2: UILabel!
    @IBOutlet weak var lbl_OrderReceivedDate: UILabel!
    @IBOutlet weak var lbl_OrderNo: UILabel!
    @IBOutlet weak var lbl_Line1: UILabel!
    var OrderId = String()
    var OrderNumber = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = API_URL + "status"
        let params: NSDictionary = ["order_id":self.OrderId]
        self.Webservice_OrderStatus(url: urlString, params:params)
    }
    @IBAction func btnTap_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK: Webservices
extension TrackOrderVC {
    func Webservice_OrderStatus(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    
                    let responseData = jsonResponse!["order_status"].stringValue
                    self.lbl_OrderNo.text = self.OrderNumber
                    self.lbl_OrderReceivedDate.text = jsonResponse!["created_at"].stringValue
                    if responseData == "1"
                    {
                        self.lbl_Line1.backgroundColor = UIColor.lightGray
                        self.lbl_Line2.backgroundColor = UIColor.lightGray
                    }
                    else if responseData == "2"
                    {
                        self.lbl_Line1.backgroundColor = ORENGE_COLOR
                        self.lbl_Line2.backgroundColor = UIColor.lightGray
                    }
                    else if responseData == "3"{
                        self.lbl_Line1.backgroundColor = ORENGE_COLOR
                        self.lbl_Line2.backgroundColor = ORENGE_COLOR
                    }
                    
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    
}
