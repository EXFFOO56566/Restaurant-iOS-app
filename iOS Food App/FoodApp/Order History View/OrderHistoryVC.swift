//
//  OrderHistoryVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 07/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON

class OrderHistoryCell: UITableViewCell {
    
    @IBOutlet weak var lbl_OrderNoLabel: UILabel!
    @IBOutlet weak var lbl_QtyLabel: UILabel!
    @IBOutlet weak var lbl_orderStatusLabel: UILabel!
    
    @IBOutlet weak var lbl_Date: UILabel!
    @IBOutlet weak var lbl_PaymentType: UILabel!
    @IBOutlet weak var lbl_OrderNumber: UILabel!
    @IBOutlet weak var lbl_itemPrice: UILabel!
    @IBOutlet weak var lbl_itemAddress: UILabel!
    @IBOutlet weak var lbl_itemQty: UILabel!
    @IBOutlet weak var btn_Close: UIButton!
}
class OrderHistoryPickupCell: UITableViewCell {
    
    @IBOutlet weak var lbl_OrderNoLabel: UILabel!
    @IBOutlet weak var lbl_QtyLabel: UILabel!
    @IBOutlet weak var lbl_orderStatusLabel: UILabel!
    
    @IBOutlet weak var lbl_Date: UILabel!
    @IBOutlet weak var lbl_PaymentType: UILabel!
    @IBOutlet weak var lbl_OrderNumber: UILabel!
    @IBOutlet weak var lbl_itemPrice: UILabel!
    @IBOutlet weak var lbl_itemQty: UILabel!
    
    @IBOutlet weak var img_orderplaced: UIImageView!
    @IBOutlet weak var lbl_1: UILabel!
    @IBOutlet weak var lbl_orderplaced: UILabel!
    
    
    @IBOutlet weak var img_orderready: UIImageView!
    @IBOutlet weak var lbl_2: UILabel!
    @IBOutlet weak var lbl_orderready: UILabel!
    
    @IBOutlet weak var img_orderdelivered: UIImageView!
    @IBOutlet weak var lbl_orderdelivered: UILabel!
    
    
    @IBOutlet weak var btn_Close: UIButton!
    
    
}
class OrderHistoryDeliverCell: UITableViewCell {
    
    @IBOutlet weak var lbl_OrderNoLabel: UILabel!
    @IBOutlet weak var lbl_QtyLabel: UILabel!
    @IBOutlet weak var lbl_orderStatusLabel: UILabel!
    
    @IBOutlet weak var lbl_Date: UILabel!
    @IBOutlet weak var lbl_PaymentType: UILabel!
    @IBOutlet weak var lbl_OrderNumber: UILabel!
    @IBOutlet weak var lbl_itemPrice: UILabel!
    
    @IBOutlet weak var lbl_itemQty: UILabel!
    
    
    @IBOutlet weak var img_orderplaced: UIImageView!
    @IBOutlet weak var lbl_1: UILabel!
    @IBOutlet weak var lbl_orderplaced: UILabel!
    
    
    @IBOutlet weak var img_orderready: UIImageView!
    @IBOutlet weak var lbl_2: UILabel!
    @IBOutlet weak var lbl_orderready: UILabel!
    
    @IBOutlet weak var img_orderontheway: UIImageView!
    @IBOutlet weak var lbl_3: UILabel!
    @IBOutlet weak var lbl_orderontheway: UILabel!
    
    
    @IBOutlet weak var img_orderdelivered: UIImageView!
    @IBOutlet weak var lbl_orderdelivered: UILabel!
    
    @IBOutlet weak var btn_Close: UIButton!
}

class OrderHistoryVC: UIViewController {
    @IBOutlet weak var Tableview_OrderHistory: UITableView!
    @IBOutlet weak var lbl_titleLabel: UILabel!
    var refreshControl = UIRefreshControl()
    var OrderHistoryData = [JSON]()
    var selected = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selected = ""
        self.Tableview_OrderHistory.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshData(_:)), for: .valueChanged)
        self.lbl_titleLabel.text = "Order History".localiz()
    }
    @objc private func refreshData(_ sender: Any) {
        self.refreshControl.endRefreshing()
        let urlString = API_URL + "orderhistory"
        let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
        self.Webservice_GetHistory(url: urlString, params:params)
    }
    override func viewWillAppear(_ animated: Bool) {
        let urlString = API_URL + "orderhistory"
        let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
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
            messageLabel.text = "NO ORDER HISTORY"
        }
        else {
            messageLabel.text = ""
        }
        return OrderHistoryData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = self.OrderHistoryData[indexPath.row]
        if selected == "\(indexPath.row)"
        {
            if data["order_type"].stringValue == "1"
            {
                return 300
            }
            else{
                return 245
            }
        }
        else{
            return 135
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.OrderHistoryData[indexPath.row]
        if selected == "\(indexPath.row)"
        {
            if data["order_type"].stringValue == "1"
            {
                let cell = self.Tableview_OrderHistory.dequeueReusableCell(withIdentifier: "OrderHistoryDeliverCell") as! OrderHistoryDeliverCell
                cell.lbl_QtyLabel.text = "QTY :".localiz()
                cell.lbl_OrderNoLabel.text = "ORDER ID :".localiz()
                cell.lbl_orderStatusLabel.text = "STATUS :".localiz()
                cell.lbl_itemQty.text = data["qty"].stringValue
                cell.lbl_Date.text = data["date"].stringValue
                let setdate = DateFormater.getBirthDateStringFromDateString(givenDate:data["date"].stringValue)
                cell.lbl_Date.text = setdate
                let status = data["status"].stringValue
                if status == "1"
                {
                    cell.lbl_orderplaced.text = "Order placed"
                    cell.img_orderplaced.image = UIImage(systemName: "checkmark.circle.fill")
                    
                    cell.lbl_orderplaced.textColor = ORENGE_COLOR
                    cell.lbl_orderready.textColor = GRAY_COLOR
                    cell.lbl_orderontheway.textColor = GRAY_COLOR
                    cell.lbl_orderdelivered.textColor = GRAY_COLOR
                    
                    
                    cell.lbl_1.backgroundColor = GRAY_COLOR
                    cell.lbl_2.backgroundColor = GRAY_COLOR
                    cell.lbl_3.backgroundColor = GRAY_COLOR
                    
                    cell.img_orderready.image = UIImage(systemName: "circle")
                    cell.img_orderready.tintColor = GRAY_COLOR
                    
                    cell.img_orderontheway.image = UIImage(systemName: "circle")
                    cell.img_orderontheway.tintColor = GRAY_COLOR
                    
                    cell.img_orderdelivered.image = UIImage(systemName: "circle")
                    cell.img_orderdelivered.tintColor = GRAY_COLOR
                    
                    
                }
                else if status == "2"
                {
                    cell.lbl_orderready.text = "Order ready"
                    cell.lbl_orderplaced.textColor = ORENGE_COLOR
                    cell.lbl_orderready.textColor = ORENGE_COLOR
                    cell.lbl_orderontheway.textColor = GRAY_COLOR
                    cell.lbl_orderdelivered.textColor = GRAY_COLOR
                    
                    cell.lbl_1.backgroundColor = ORENGE_COLOR
                    cell.lbl_2.backgroundColor = GRAY_COLOR
                    cell.lbl_3.backgroundColor = GRAY_COLOR
                    
                    cell.img_orderplaced.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderplaced.tintColor = ORENGE_COLOR
                    
                    cell.img_orderready.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderready.tintColor = ORENGE_COLOR
                    
                    
                    cell.img_orderontheway.image = UIImage(systemName: "circle")
                    cell.img_orderontheway.tintColor = GRAY_COLOR
                    
                    cell.img_orderdelivered.image = UIImage(systemName: "circle")
                    cell.img_orderdelivered.tintColor = GRAY_COLOR
                    
                    
                }
                else if status == "3"
                {
                    cell.lbl_orderontheway.text = "Order on the way"
                    
                    cell.lbl_orderplaced.textColor = ORENGE_COLOR
                    cell.lbl_orderready.textColor = ORENGE_COLOR
                    cell.lbl_orderontheway.textColor = ORENGE_COLOR
                    cell.lbl_orderdelivered.textColor = GRAY_COLOR
                    
                    cell.lbl_1.backgroundColor = ORENGE_COLOR
                    cell.lbl_2.backgroundColor = ORENGE_COLOR
                    cell.lbl_3.backgroundColor = GRAY_COLOR
                    
                    cell.img_orderplaced.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderplaced.tintColor = ORENGE_COLOR
                    
                    cell.img_orderready.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderready.tintColor = ORENGE_COLOR
                    
                    cell.img_orderontheway.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderontheway.tintColor = ORENGE_COLOR
                    
                    cell.img_orderdelivered.image = UIImage(systemName: "circle")
                    cell.img_orderdelivered.tintColor = GRAY_COLOR
                    
                }
                else if status == "4"
                {
                    
                    cell.lbl_orderdelivered.text = "Order delivered"
                    cell.lbl_orderplaced.textColor = ORENGE_COLOR
                    cell.lbl_orderready.textColor = ORENGE_COLOR
                    cell.lbl_orderontheway.textColor = ORENGE_COLOR
                    cell.lbl_orderdelivered.textColor = ORENGE_COLOR
                    
                    
                    cell.lbl_1.backgroundColor = ORENGE_COLOR
                    cell.lbl_2.backgroundColor = ORENGE_COLOR
                    cell.lbl_3.backgroundColor = ORENGE_COLOR
                    
                    cell.img_orderplaced.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderplaced.tintColor = ORENGE_COLOR
                    
                    cell.img_orderready.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderready.tintColor = ORENGE_COLOR
                    
                    cell.img_orderontheway.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderontheway.tintColor = ORENGE_COLOR
                    
                    cell.img_orderdelivered.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderdelivered.tintColor = ORENGE_COLOR
                }
                cell.lbl_OrderNumber.text = data["order_number"].stringValue
                let ItemPrice = formatter.string(for: data["total_price"].stringValue.toDouble)
                cell.lbl_itemPrice.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPrice!)"
                let paymentType = data["payment_type"].stringValue
                if paymentType == "0"
                {
                    cell.lbl_PaymentType.text = "PAY BY CASH".localiz()
                }
                else if paymentType == "1"
                {
                    cell.lbl_PaymentType.text = "RAZORPAY".localiz()
                }
                cell.btn_Close.tag = indexPath.row
                cell.btn_Close.addTarget(self, action: #selector(btnTapclose), for: .touchUpInside)
                return cell
            }
            else if data["order_type"].stringValue == "2"{
                let cell = self.Tableview_OrderHistory.dequeueReusableCell(withIdentifier: "OrderHistoryPickupCell") as! OrderHistoryPickupCell
                cell.lbl_QtyLabel.text = "QTY :".localiz()
                cell.lbl_OrderNoLabel.text = "ORDER ID :".localiz()
                cell.lbl_orderStatusLabel.text = "STATUS :".localiz()
                cell.lbl_itemQty.text = data["qty"].stringValue
                cell.lbl_Date.text = data["date"].stringValue
                let setdate = DateFormater.getBirthDateStringFromDateString(givenDate:data["date"].stringValue)
                cell.lbl_Date.text = setdate
                let status = data["status"].stringValue
                if status == "1"
                {
                    cell.lbl_orderplaced.text = "Order placed"
                    cell.img_orderplaced.image = UIImage(systemName: "checkmark.circle.fill")
                    
                    cell.lbl_orderplaced.textColor = ORENGE_COLOR
                    cell.lbl_orderready.textColor = GRAY_COLOR
                    cell.lbl_orderdelivered.textColor = GRAY_COLOR
                    
                    
                    cell.lbl_1.backgroundColor = GRAY_COLOR
                    cell.lbl_2.backgroundColor = GRAY_COLOR
                    
                    cell.img_orderready.image = UIImage(systemName: "circle")
                    cell.img_orderready.tintColor = GRAY_COLOR
                    
                    
                    cell.img_orderdelivered.image = UIImage(systemName: "circle")
                    cell.img_orderdelivered.tintColor = GRAY_COLOR
                    
                    
                }
                else if status == "2"
                {
                    cell.lbl_orderready.text = "Order ready"
                    cell.lbl_orderplaced.textColor = ORENGE_COLOR
                    cell.lbl_orderready.textColor = ORENGE_COLOR
                    cell.lbl_orderdelivered.textColor = GRAY_COLOR
                    
                    cell.lbl_1.backgroundColor = ORENGE_COLOR
                    cell.lbl_2.backgroundColor = GRAY_COLOR
                    
                    cell.img_orderplaced.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderplaced.tintColor = ORENGE_COLOR
                    
                    cell.img_orderready.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderready.tintColor = ORENGE_COLOR
                    
                    cell.img_orderdelivered.image = UIImage(systemName: "circle")
                    cell.img_orderdelivered.tintColor = GRAY_COLOR
                    
                    
                    
                }
                else if status == "4"
                {
                    
                    cell.lbl_orderdelivered.text = "Order delivered"
                    cell.lbl_orderplaced.textColor = ORENGE_COLOR
                    cell.lbl_orderready.textColor = ORENGE_COLOR
                    cell.lbl_orderdelivered.textColor = ORENGE_COLOR
                    
                    
                    cell.lbl_1.backgroundColor = ORENGE_COLOR
                    cell.lbl_2.backgroundColor = ORENGE_COLOR
                    
                    cell.img_orderplaced.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderplaced.tintColor = ORENGE_COLOR
                    
                    cell.img_orderready.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderready.tintColor = ORENGE_COLOR
                    
                    
                    cell.img_orderdelivered.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.img_orderdelivered.tintColor = ORENGE_COLOR
                }
                cell.lbl_OrderNumber.text = data["order_number"].stringValue
                let ItemPrice = formatter.string(for: data["total_price"].stringValue.toDouble)
                cell.lbl_itemPrice.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPrice!)"
                let paymentType = data["payment_type"].stringValue
                if paymentType == "0"
                {
                    cell.lbl_PaymentType.text = "PAY BY CASH".localiz()
                }
                else if paymentType == "1"
                {
                    cell.lbl_PaymentType.text = "RAZORPAY".localiz()
                }
                cell.btn_Close.tag = indexPath.row
                cell.btn_Close.addTarget(self, action: #selector(btnTapclose), for: .touchUpInside)
                return cell
            }
            
        }
        else{
            let cell = self.Tableview_OrderHistory.dequeueReusableCell(withIdentifier: "OrderHistoryCell") as! OrderHistoryCell
            cell.lbl_QtyLabel.text = "QTY :".localiz()
            cell.lbl_OrderNoLabel.text = "ORDER ID :".localiz()
            cell.lbl_orderStatusLabel.text = "STATUS :".localiz()
            cell.lbl_itemQty.text = data["qty"].stringValue
            cell.lbl_Date.text = data["date"].stringValue
            let setdate = DateFormater.getBirthDateStringFromDateString(givenDate:data["date"].stringValue)
            cell.lbl_Date.text = setdate
            let status = data["status"].stringValue
            if status == "1"
            {
                cell.lbl_itemAddress.text = "Order placed"
            }
            else if status == "2"
            {
                cell.lbl_itemAddress.text = "Order ready"
            }
            else if status == "3"
            {
                cell.lbl_itemAddress.text = "Order on the way"
            }
            else if status == "4"
            {
                cell.lbl_itemAddress.text = "Order delivered"
            }
            cell.lbl_OrderNumber.text = data["order_number"].stringValue
            let ItemPrice = formatter.string(for: data["total_price"].stringValue.toDouble)
            cell.lbl_itemPrice.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPrice!)"
            let paymentType = data["payment_type"].stringValue
            if paymentType == "0"
            {
                cell.lbl_PaymentType.text = "PAY BY CASH".localiz()
            }
            else if paymentType == "1"
            {
                cell.lbl_PaymentType.text = "RAZORPAY".localiz()
            }
            cell.btn_Close.tag = indexPath.row
            cell.btn_Close.addTarget(self, action: #selector(btnTapopen), for: .touchUpInside)
            return cell
        }
        return UITableViewCell()
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.OrderHistoryData[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(identifier: "OrderHistoryDetailsVC") as! OrderHistoryDetailsVC
        vc.OrderId = data["id"].stringValue
        vc.status = data["status"].stringValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func btnTapopen(sender:UIButton)
    {
        self.selected = "\(sender.tag)"
        self.Tableview_OrderHistory.reloadData()
    }
    @objc func btnTapclose(sender:UIButton)
    {
        self.selected = ""
        self.Tableview_OrderHistory.reloadData()
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
                    self.selected = ""
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
