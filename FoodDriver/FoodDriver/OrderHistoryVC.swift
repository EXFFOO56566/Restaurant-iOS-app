//
//  OrderHistoryVC.swift
//  FoodDriver
//
//  Created by Mitesh's MAC on 10/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON

class OrderHistoryVC: UIViewController {
    @IBOutlet weak var Tableview_OrderHistory: UITableView!
    var OrderHistoryData = [JSON]()
    var refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Tableview_OrderHistory.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshData(_:)), for: .valueChanged)
        self.Tableview_OrderHistory.delegate = self
        self.Tableview_OrderHistory.dataSource = self
        self.Tableview_OrderHistory.reloadData()
    }
    @objc private func refreshData(_ sender: Any) {
        self.refreshControl.endRefreshing()
      let urlString = API_URL + "driverorder"
      let params: NSDictionary = ["driver_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
      self.Webservice_GetHistory(url: urlString, params:params)
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
    override func viewWillAppear(_ animated: Bool) {
        let urlString = API_URL + "driverorder"
        let params: NSDictionary = ["driver_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
        self.Webservice_GetHistory(url: urlString, params:params)
    }
}
extension OrderHistoryVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.Tableview_OrderHistory.bounds.size.width, height: self.Tableview_OrderHistory.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
        messageLabel.sizeToFit()
        self.Tableview_OrderHistory.backgroundView = messageLabel;
        if self.OrderHistoryData.count == 0 {
            messageLabel.text = "NO ORDER HISTORY DATA"
        }
        else {
            messageLabel.text = ""
        }
        return OrderHistoryData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.Tableview_OrderHistory.dequeueReusableCell(withIdentifier: "OngoingOrderCell") as! OngoingOrderCell
        let data = self.OrderHistoryData[indexPath.row]
        cell.lbl_itemQty.text = data["qty"].stringValue
        cell.lbl_OrderNumber.text = data["order_number"].stringValue
        let orderTotalPrice = formatter.string(for: data["total_price"].stringValue.toDouble)
        cell.lbl_itemPrice.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(orderTotalPrice!)"
        
        let paymentType = data["payment_type"].stringValue
        if paymentType == "0"
        {
            cell.lbl_PaymentType.text = "PAY BY CASH"
        }
        else if paymentType == "1"
        {
            cell.lbl_PaymentType.text = "RAZORPAY"
        }
        let status = data["status"].stringValue
        if status == "3"
        {
            cell.lbl_status.text = "Order on the way"
        }
        else if status == "4"
        {
            cell.lbl_status.text = "Order delivered"
        }
        let setdate = DateFormater.getBirthDateStringFromDateString(givenDate:data["date"].stringValue)
        cell.lbl_date.text = setdate
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.OrderHistoryData[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(identifier: "OrderDetailsVC") as! OrderDetailsVC
        vc.OrderId = data["id"].stringValue
        vc.OrderStatus = data["status"].stringValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: Webservices
extension OrderHistoryVC {
    func Webservice_GetHistory(url:String, params:NSDictionary) -> Void {
        
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].arrayValue
                    self.OrderHistoryData = responseData
                    
                    self.Tableview_OrderHistory.delegate = self
                    self.Tableview_OrderHistory.dataSource = self
                    self.Tableview_OrderHistory.reloadData()
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
}
