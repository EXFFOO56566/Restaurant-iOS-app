//
//  OrderDetailsVC.swift
//  FoodDriver
//
//  Created by iMac on 21/07/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import MapKit
class OrderListCell: UITableViewCell {
    
    @IBOutlet weak var lbl_Price: UILabel!
    @IBOutlet weak var lbl_itemsQtyPrice: UILabel!
    @IBOutlet weak var lbl_itemsName: UILabel!
    @IBOutlet weak var img_items: UIImageView!
}
class OrderDetailsVC: UIViewController {
    
    @IBOutlet weak var tbl_height: NSLayoutConstraint!
    @IBOutlet weak var TableView_OrderList: UITableView!
    @IBOutlet weak var img_UserProfile: UIImageView!
    @IBOutlet weak var lbl_UserName: UILabel!
    @IBOutlet weak var lbl_UserAddress: UILabel!
    @IBOutlet weak var btn_Deliverd: UIButton!
    
    
    @IBOutlet weak var btn_DeliverdHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_DeliveryCharge: UILabel!
    @IBOutlet weak var lbl_TotalAmount: UILabel!
    @IBOutlet weak var lbl_OrderTotal: UILabel!
    @IBOutlet weak var lbl_tax: UILabel!
    @IBOutlet weak var lbl_stringTax: UILabel!
    @IBOutlet weak var lbl_Promocode: UILabel!
    @IBOutlet weak var lbl_DiscountAmount: UILabel!
    
    var OrderId = String()
    var OrderStatus = String()
    
    var OrderDetailsData = [JSON]()
    var MobileNumber = String()
    var lat = String()
    var lang = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        if OrderStatus == "4"
        {
            self.btn_Deliverd.isHidden = true
            self.btn_DeliverdHeight.constant = 0.0
        }
        else{
            self.btn_Deliverd.isHidden = false
            self.btn_DeliverdHeight.constant = 50.0
        }
        cornerRadius(viewName: self.img_UserProfile, radius: 6.0)
        cornerRadius(viewName: self.btn_Deliverd, radius: 8.0)
        
        let urlString = API_URL + "driverorderdetails"
        let params: NSDictionary = ["order_id":self.OrderId]
        self.Webservice_GetorderDetails(url: urlString, params:params)
    }
    @IBAction func btnTap_Close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnTap_Deliverd(_ sender: UIButton) {
        let alertVC = UIAlertController(title: Bundle.main.displayName!, message: "Would you please confirm if you have delivered all meals to client", preferredStyle: .alert)
               let yesAction = UIAlertAction(title: "Confirm".localiz(), style: .default) { (action) in
                    let urlString = API_URL + "delivered"
                          let params: NSDictionary = ["order_id":self.OrderId]
                          self.Webservice_Deliveredorder(url: urlString, params:params)
               }
               let noAction = UIAlertAction(title: "Cancel".localiz(), style: .destructive)
               alertVC.addAction(yesAction)
               alertVC.addAction(noAction)
               self.present(alertVC,animated: true,completion: nil)
        
       
    }
    
    @IBAction func btnTap_Call(_ sender: UIButton) {
        callNumber(phoneNumber: self.MobileNumber)
    }
    func callNumber(phoneNumber: String) {
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
                return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func btnTap_ViewInMap(_ sender: UIButton) {
        openMapForPlace()
    }
    func openMapForPlace() {
        
        let latitude: CLLocationDegrees = Double(self.lat)!
        let longitude: CLLocationDegrees = Double(self.lang)!
        
        let regionDistance:CLLocationDistance = 5000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "User Location"
        mapItem.openInMaps(launchOptions: options)
    }
}
extension OrderDetailsVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: self.TableView_OrderList.bounds.size.width, height: self.TableView_OrderList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        //               messageLabel.font = UIFont(name: "Gilroy-Medium", size: 17)!
        messageLabel.sizeToFit()
        self.TableView_OrderList.backgroundView = messageLabel;
        if self.OrderDetailsData.count == 0 {
            messageLabel.text = "No Data Found".uppercased()
        }
        else {
            messageLabel.text = ""
        }
        return OrderDetailsData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.TableView_OrderList.dequeueReusableCell(withIdentifier: "OrderListCell") as! OrderListCell
        cornerRadius(viewName: cell.img_items, radius: 4.0)
        let data = self.OrderDetailsData[indexPath.row]
        cell.lbl_itemsName.text = data["item_name"].stringValue
        let orderTotalPrice = formatter.string(for: data["total_price"].stringValue.toDouble)
        cell.lbl_Price.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(orderTotalPrice!)"
        cell.lbl_itemsQtyPrice.text = "QTY : \(data["qty"].stringValue)"
        let itemImage = data["itemimage"].dictionaryValue
        cell.img_items.sd_setImage(with: URL(string: itemImage["image"]!.stringValue), placeholderImage: UIImage(named: "placeholder_image"))
        return cell
    }
}
//MARK: Webservices
extension OrderDetailsVC {
    func Webservice_GetorderDetails(url:String, params:NSDictionary) -> Void {
        
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
                    self.lbl_UserName.text = jsonResponse!["name"].stringValue.uppercased()
                    self.lbl_UserAddress.text = jsonResponse!["delivery_address"].stringValue
                    self.img_UserProfile.sd_setImage(with: URL(string: jsonResponse!["profile_image"].stringValue), placeholderImage: UIImage(named: "placeholder_image"))
                    self.MobileNumber = jsonResponse!["mobile"].stringValue
                    self.lat = jsonResponse!["lat"].stringValue
                    self.lang = jsonResponse!["lang"].stringValue
                    
                    let summerydata = jsonResponse!["summery"].dictionaryValue
                    let orderTotalPrice = formatter.string(for: summerydata["order_total"]!.stringValue.toDouble)
                    self.lbl_OrderTotal.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(orderTotalPrice!)"
                    if summerydata["discount_amount"]!.stringValue != ""
                    {
                        self.lbl_DiscountAmount.text = "-\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(summerydata["discount_amount"]!.stringValue)"
                        self.lbl_Promocode.text = summerydata["promocode"]!.stringValue
                    }
                    else{
                        self.lbl_DiscountAmount.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(0)"
                        self.lbl_Promocode.text = ""
                    }
                    let tax = summerydata["tax"]!.doubleValue
                    let taxrate = (summerydata["order_total"]!.doubleValue) * (Double(tax)) / 100
                    print(taxrate)
                    let taxratePrice = formatter.string(for: taxrate)
                    self.lbl_tax.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(taxratePrice!)"
                    let GrandPrintTotal = "\(summerydata["order_total"]!.doubleValue + taxrate + summerydata["delivery_charge"]!.doubleValue - summerydata["discount_amount"]!.doubleValue)"
                    let GrandPrice = formatter.string(for: GrandPrintTotal.toDouble)
                    self.lbl_TotalAmount.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(GrandPrice!)"
                    self.lbl_stringTax.text = "Tax (\(summerydata["tax"]!.stringValue)%)"
                    let DeliveryCharge = formatter.string(for: summerydata["delivery_charge"]!.stringValue.toDouble)
                    self.lbl_DeliveryCharge.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(DeliveryCharge!)"
                    
                    
                    
                    
                    self.tbl_height.constant = CGFloat(80 * self.OrderDetailsData.count)
                    self.TableView_OrderList.delegate = self
                    self.TableView_OrderList.dataSource = self
                    self.TableView_OrderList.reloadData()
                    
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    func Webservice_Deliveredorder(url:String, params:NSDictionary) -> Void {
        
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                    self.navigationController?.popViewController(animated: true)
                    
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
}
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
