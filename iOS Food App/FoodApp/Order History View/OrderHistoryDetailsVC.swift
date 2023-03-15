//
//  OrderHistoryDetailsVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 09/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON

class orderDetailscell: UITableViewCell {
    
    @IBOutlet weak var lbl_itemsName: UILabel!
    @IBOutlet weak var img_Items: UIImageView!
    @IBOutlet weak var lbl_Price: UILabel!
    @IBOutlet weak var lbl_Qtycount: UILabel!
    @IBOutlet weak var btn_Note: UIButton!
    @IBOutlet weak var btn_Addons: UIButton!
    
}
class OrderHistoryDetailsVC: UIViewController {
    
    @IBOutlet weak var OrderNote_Height: NSLayoutConstraint!
    @IBOutlet weak var Tableview_OrderSummary: UITableView!
    @IBOutlet weak var tableview_Height: NSLayoutConstraint!
    var OrderId = String()
    @IBOutlet weak var lbl_TotalAmount: UILabel!
    @IBOutlet weak var lbl_OrderTotal: UILabel!
    @IBOutlet weak var lbl_tax: UILabel!
    @IBOutlet weak var lbl_DeliveryCharge: UILabel!
    @IBOutlet weak var lbl_DeliveryAddress: UILabel!
    @IBOutlet weak var lbl_stringTax: UILabel!
    @IBOutlet weak var lbl_Promocode: UILabel!
    @IBOutlet weak var lbl_DiscountAmount: UILabel!
    
    @IBOutlet weak var btn_cancelHeight: NSLayoutConstraint!
    @IBOutlet weak var btn_cancel: UIButton!
    
    @IBOutlet weak var lbl_titleLabel: UILabel!
    @IBOutlet weak var lbl_OrderSummaryLabel: UILabel!
    @IBOutlet weak var lbl_PaymentSummaryLabel: UILabel!
    @IBOutlet weak var lbl_OrderTotalLabel: UILabel!
    @IBOutlet weak var lbl_DeliveryChargeLabel: UILabel!
    @IBOutlet weak var lbl_DiscountOfferLabel: UILabel!
    @IBOutlet weak var lbl_TotalAmountLabel: UILabel!
    @IBOutlet weak var lbl_DeliveryAddressLabel: UILabel!
    @IBOutlet weak var DeliveryAddress_Height: NSLayoutConstraint!
    @IBOutlet weak var lbl_Notes: UILabel!
    @IBOutlet weak var driverinfo_view: CornerView!
    
    @IBOutlet weak var driverTop_Height: NSLayoutConstraint!
    @IBOutlet weak var driverview_Height: NSLayoutConstraint!
    @IBOutlet weak var lbl_driverName: UILabel!
    @IBOutlet weak var img_Driver: UIImageView!
    @IBOutlet weak var btn_Call: UIButton!
    var OrderNumber = String()
    var status = String()
    var OrderDetailsData = [JSON]()
    var taxStr = "Tax".localiz()
    var driver_mobile = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_titleLabel.text = "Order Details"
        self.lbl_OrderSummaryLabel.text = "Order Summary".localiz()
        self.lbl_PaymentSummaryLabel.text = "Payment Summary".localiz()
        self.lbl_OrderTotalLabel.text = "Order Total".localiz()
        self.lbl_DeliveryChargeLabel.text = "Delivery Charge".localiz()
        self.lbl_DiscountOfferLabel.text = "Discount Offer".localiz()
        self.lbl_TotalAmountLabel.text = "Total Amount".localiz()
        self.lbl_DeliveryAddressLabel.text = "Delivery Address".localiz()
        
        self.btn_cancel.isHidden = true
        self.btn_cancelHeight.constant = 0.0
        cornerRadius(viewName: self.btn_cancel, radius: 8)
        cornerRadius(viewName: self.img_Driver, radius: self.img_Driver.frame.height / 2)
        cornerRadius(viewName: self.btn_Call, radius: self.btn_Call.frame.height / 2)
        let urlString = API_URL + "getorderdetails"
        let params: NSDictionary = ["order_id":self.OrderId]
        self.Webservice_GetOrderDetails(url: urlString, params:params)
    }
    @IBAction func btnTap_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnTap_Cancel(_ sender: UIButton) {
        let urlString = API_URL + "ordercancel"
        let params: NSDictionary = ["order_id":self.OrderId]
        self.Webservice_CancelOrder(url: urlString, params:params)
    }
    
    @IBAction func btnTap_Call(_ sender: UIButton) {
        callNumber(phoneNumber: self.driver_mobile)
    }
    func callNumber(phoneNumber: String) {
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
               UIApplication.shared.canOpenURL(url) else {
                   return
           }
           UIApplication.shared.open(url, options: [:], completionHandler: nil)
       }
    
}
extension OrderHistoryDetailsVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.OrderDetailsData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.Tableview_OrderSummary.dequeueReusableCell(withIdentifier: "orderDetailscell") as! orderDetailscell
        cornerRadius(viewName: cell.img_Items, radius:4)
        cornerRadius(viewName: cell.btn_Addons, radius:4.0)
        cornerRadius(viewName: cell.btn_Note, radius:4.0)
        let data = self.OrderDetailsData[indexPath.row]
        cell.lbl_itemsName.text = data["item_name"].stringValue
        
        cell.lbl_Qtycount.text = "QTY : \(data["qty"].stringValue)"
        let ItemtotalPrice = formatter.string(for: data["total_price"].stringValue.toDouble)
        cell.lbl_Price.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemtotalPrice!)"
        let itemImage = data["itemimage"].dictionaryValue
        cell.img_Items.sd_setImage(with: URL(string: itemImage["image"]!.stringValue), placeholderImage: UIImage(named: "placeholder_image"))
        cell.btn_Addons.tag = indexPath.row
        cell.btn_Addons.addTarget(self, action: #selector(btnTapAddons), for: .touchUpInside)
        cell.btn_Note.tag = indexPath.row
        cell.btn_Note.addTarget(self, action: #selector(btnTapNote), for: .touchUpInside)
        
        if data["addons"].arrayValue.count == 0
        {
            cell.btn_Addons.isEnabled = false
            cell.btn_Addons.backgroundColor = UIColor.lightGray
        }
        else{
            cell.btn_Addons.isEnabled = true
        }
        
        let item_notes = data["item_notes"].stringValue
        
        if item_notes == ""
        {
            cell.btn_Note.isEnabled = false
            cell.btn_Note.backgroundColor = UIColor.lightGray
        }
        else
        {
            cell.btn_Note.isEnabled = true
            
        }
        return cell
    }
    @objc func btnTapAddons(sender:UIButton)
    {
        let data = OrderDetailsData[sender.tag]
        let addonceData = data["addons"].arrayValue
        print(addonceData)
        let vc = self.storyboard?.instantiateViewController(identifier: "AddonceListVC") as! AddonceListVC
        vc.SelectedAddons = addonceData
        self.present(vc, animated: true, completion: nil)
        
    }
    @objc func btnTapNote(sender:UIButton)
    {
        let data = OrderDetailsData[sender.tag]
        //       let data = cartDetailsarray[sender.tag]
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "NoteVC") as! NoteVC
        VC.modalPresentationStyle = .overFullScreen
        VC.modalTransitionStyle = .crossDissolve
        VC.Note = data["item_notes"].stringValue
        self.present(VC,animated: true,completion: nil)
        
    }
}
//MARK: Webservices
extension OrderHistoryDetailsVC {
    func Webservice_GetOrderDetails(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].arrayValue
                    
                    self.OrderDetailsData = responseData
                    let summerydata = jsonResponse!["summery"].dictionaryValue
                    let ItemPrice = formatter.string(for: summerydata["order_total"]!.stringValue.toDouble)
                    self.lbl_OrderTotal.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPrice!)"
                    if summerydata["discount_amount"]!.stringValue != ""
                    {
                        self.lbl_DiscountAmount.text = "-\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(formatter.string(for: summerydata["discount_amount"]!.stringValue.toDouble)!)"
                        self.lbl_Promocode.text = summerydata["promocode"]!.stringValue
                    }
                    else{
                        self.lbl_DiscountAmount.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(0.00)"
                        self.lbl_Promocode.text = ""
                    }
                    let tax = summerydata["tax"]!.doubleValue
                    let taxrate = (summerydata["order_total"]!.doubleValue) * (Double(tax)) / 100
                    print(taxrate)
                    let TaxratePrice = formatter.string(for: taxrate)
                    print(TaxratePrice)
                    self.lbl_tax.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TaxratePrice!)"
                    let order_type = jsonResponse!["order_type"].stringValue
                    var DeliveryPrice = String()
                    if order_type == "2"
                    {
                        DeliveryPrice = formatter.string(for: 0.00)!
                        self.DeliveryAddress_Height.constant = 0.0
                        self.driverTop_Height.constant = 0.0
                        self.driverinfo_view.isHidden = true
                        self.driverview_Height.constant = 0.0
                    }
                    else
                    {
                        DeliveryPrice = formatter.string(for: summerydata["delivery_charge"]!.stringValue.toDouble)!
                        if self.status == "3" || self.status == "4"
                        {
                            self.DeliveryAddress_Height.constant = 70.0
                            self.driverTop_Height.constant = 8.0
                            self.driverinfo_view.isHidden = false
                            self.driverview_Height.constant = 100.0
                        }
                        else
                        {
                            self.DeliveryAddress_Height.constant = 70.0
                            self.driverTop_Height.constant = 0.0
                            self.driverinfo_view.isHidden = true
                            self.driverview_Height.constant = 0.0
                        }
                        
                    }
                     
                    self.lbl_driverName.text = summerydata["driver_name"]!.stringValue
                    self.img_Driver.sd_setImage(with: URL(string: summerydata["driver_profile_image"]!.stringValue), placeholderImage: UIImage(named: "placeholder_image"))
                    self.driver_mobile = summerydata["driver_mobile"]!.stringValue
                    self.lbl_DeliveryCharge.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(DeliveryPrice)"
                    let GrandPrintTotal = "\(summerydata["order_total"]!.doubleValue + Double(TaxratePrice!)! + Double(DeliveryPrice.replacingOccurrences(of: ",", with: ""))! - summerydata["discount_amount"]!.doubleValue)"
                    let TotalPrice = formatter.string(for: GrandPrintTotal.toDouble)
                    print(TotalPrice)
                    self.lbl_TotalAmount.text = "\((UserDefaultManager.getStringFromUserDefaults(key: UD_currency)))\(TotalPrice!)"
                    self.lbl_stringTax.text = "\(self.taxStr) (\(summerydata["tax"]!.stringValue)%)"
                    self.lbl_DeliveryAddress.text = jsonResponse!["address"].stringValue
                    self.OrderNumber = jsonResponse!["order_number"].stringValue
                    
                    
                    if summerydata["order_notes"]!.stringValue == ""
                    {
                        self.OrderNote_Height.constant = 0.0
                    }
                    else{
                        self.OrderNote_Height.constant = 90
                        self.lbl_Notes.text = summerydata["order_notes"]!.stringValue
                    }
                    //                    self.lbl_OrderNotes.text = summerydata["order_notes"]!.stringValue
                    self.tableview_Height.constant = CGFloat(105 * self.OrderDetailsData.count)
                    self.Tableview_OrderSummary.delegate = self
                    self.Tableview_OrderSummary.dataSource = self
                    self.Tableview_OrderSummary.reloadData()
                    
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    func Webservice_CancelOrder(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    //                    let responseData = jsonResponse!["data"].arrayValue
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    
}
