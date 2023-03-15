//
//  DashboardVC.swift
//  FoodDriver
//
//  Created by iMac on 04/08/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
class OngoingOrderCell: UITableViewCell {
    
    @IBOutlet weak var lbl_status: UILabel!
    @IBOutlet weak var lbl_PaymentType: UILabel!
    @IBOutlet weak var lbl_itemPrice: UILabel!
    @IBOutlet weak var lbl_OrderNumber: UILabel!
    @IBOutlet weak var lbl_itemQty: UILabel!
    
    @IBOutlet weak var lbl_date: UILabel!
}
class DashboardVC: UIViewController {
    
    @IBOutlet weak var TableView_OrderList: UITableView!
    
    @IBOutlet weak var lbl_TotalOnGoingOrder: UILabel!
    @IBOutlet weak var lbl_TotalcompletedOrder: UILabel!
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var lbl_title: UILabel!
    var OrderData = [JSON]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TableView_OrderList.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshData(_:)), for: .valueChanged)
        self.lbl_title.text = "Welcome, \n\(UserDefaultManager.getStringFromUserDefaults(key: UD_Name))."
        setDecimalNumber()
        
    }
    @objc private func refreshData(_ sender: Any) {
        self.refreshControl.endRefreshing()
      let urlString = API_URL + "driverongoingorder"
      let params: NSDictionary = ["driver_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
      self.Webservice_GetOngoinOrder(url: urlString, params:params)
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
        let urlString = API_URL + "driverongoingorder"
        let params: NSDictionary = ["driver_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
        self.Webservice_GetOngoinOrder(url: urlString, params:params)
    }
    
    
}
extension DashboardVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.TableView_OrderList.bounds.size.width, height: self.TableView_OrderList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
        messageLabel.sizeToFit()
        self.TableView_OrderList.backgroundView = messageLabel;
        if self.OrderData.count == 0 {
            messageLabel.text = "NO ORDER DATA"
        }
        else {
            messageLabel.text = ""
        }
        return self.OrderData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.TableView_OrderList.dequeueReusableCell(withIdentifier: "OngoingOrderCell") as! OngoingOrderCell
        let data = self.OrderData[indexPath.row]
        cell.lbl_itemQty.text = data["qty"].stringValue
        cell.lbl_OrderNumber.text = data["order_number"].stringValue
        let ItemTotalPrice = formatter.string(for: data["total_price"].stringValue.toDouble)
        cell.lbl_itemPrice.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemTotalPrice!)"
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
        let data = self.OrderData[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(identifier: "OrderDetailsVC") as! OrderDetailsVC
        vc.OrderId = data["id"].stringValue
        vc.OrderStatus = data["status"].stringValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: Webservices
extension DashboardVC {
    func Webservice_GetOngoinOrder(url:String, params:NSDictionary) -> Void {
        
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].arrayValue
                    UserDefaultManager.setStringToUserDefaults(value: jsonResponse!["currency"].stringValue, key: UD_currency)
                    self.OrderData = responseData
                    self.lbl_TotalOnGoingOrder.text = jsonResponse!["ongoing_order"].stringValue
                    self.lbl_TotalcompletedOrder.text = jsonResponse!["completed_order"].stringValue
                    self.TableView_OrderList.delegate = self
                    self.TableView_OrderList.dataSource = self
                    self.TableView_OrderList.reloadData()
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
extension String {
    var toDouble: Double {
        return Double(self) ?? 0.00
    }
}
