//
//  PaymentVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 04/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
class OrderSummaryCell : UITableViewCell
{
    
    @IBOutlet weak var lbl_Price: UILabel!
    @IBOutlet weak var lbl_count: UILabel!
    @IBOutlet weak var lbl_itemName: UILabel!
    @IBOutlet weak var cell_view: UIView!
    
    @IBOutlet weak var img_Items: UIImageView!
    
    @IBOutlet weak var btn_Addons: UIButton!
    @IBOutlet weak var btn_Note: UIButton!
    
}
class OrderDetails: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var Tableview_Height: NSLayoutConstraint!
    @IBOutlet weak var Tableview_OrderSummryList: UITableView!
    @IBOutlet weak var btn_ProceedtoPayment: UIButton!
    
    @IBOutlet weak var lbl_TotalAmount: UILabel!
    @IBOutlet weak var lbl_OrderTotal: UILabel!
    @IBOutlet weak var lbl_tax: UILabel!
    @IBOutlet weak var lbl_DeliveryCharge: UILabel!
    
    
    @IBOutlet weak var lbl_stringTax: UILabel!
    
    @IBOutlet weak var txt_Promocode: UITextField!
    @IBOutlet weak var btn_Apply: UIButton!
    @IBOutlet weak var lbl_Promocode: UILabel!
    
    @IBOutlet weak var lbl_GetPromoCode: UILabel!
    
    var getsummaryData = [JSON]()
    var summaryData = [String :JSON]()
    //    var addonsArray = [JSON]()
    var isApply = String()
    var promocode = String()
    var DiscountAmount = String()
    
    var discount_pr = String()
    var tax = String()
    var tax_amount = String()
    var TotalAmount = Double()
    var offerAmount = Double()
    var DeliveryCharge = String()
    
    @IBOutlet weak var Pickupview: CardViewMaster!
    @IBOutlet weak var Delivery_view: CardViewMaster!
    @IBOutlet weak var lbl_titleLabel: UILabel!
    @IBOutlet weak var lbl_couponcodeLabel: UILabel!
    @IBOutlet weak var lbl_OrderSummaryLabel: UILabel!
    @IBOutlet weak var lbl_PaymentSummaryLabel: UILabel!
    @IBOutlet weak var btn_SelectPromocodeLabel: UIButton!
    @IBOutlet weak var lbl_OrderTotalLabel: UILabel!
    @IBOutlet weak var lbl_DeliveryChargeLabel: UILabel!
    @IBOutlet weak var lbl_DiscountOfferLabel: UILabel!
    @IBOutlet weak var lbl_TotalAmountLabel: UILabel!
    @IBOutlet weak var lbl_DeliveryAddressLabel: UILabel!
    @IBOutlet weak var text_ViewNotes: UITextView!
    
    @IBOutlet weak var lbl_DeliveryAddress: UILabel!
    @IBOutlet weak var DeliveryAddress_VIew: CornerView!
    @IBOutlet weak var DeliveryView_height: NSLayoutConstraint!
    var isAddressType = String()
    var lat = String()
    var lang = String()
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var Promo = Double()
    var isPromoApply = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isAddressType = "1"
        self.lbl_titleLabel.text = "Order Summary".localiz()
        self.lbl_OrderSummaryLabel.text = "Order Summary".localiz()
        self.lbl_couponcodeLabel.text  = "Couponcode".localiz()
        self.lbl_PaymentSummaryLabel.text = "Payment Summary".localiz()
        self.btn_SelectPromocodeLabel.setTitle("Select Promocode".localiz(), for: .normal)
        self.btn_ProceedtoPayment.setTitle("Proceed to Payment".localiz(), for: .normal)
        self.lbl_OrderTotalLabel.text = "Order Total".localiz()
        self.lbl_DeliveryChargeLabel.text = "Delivery Charge".localiz()
        self.lbl_DiscountOfferLabel.text = "Discount Offer".localiz()
        self.lbl_TotalAmountLabel.text = "Total Amount".localiz()
        self.lbl_DeliveryAddressLabel.text = "Delivery Address".localiz()
        self.getCurrentLocation()
        self.text_ViewNotes.text = "Write Order Notes".localiz()
        self.text_ViewNotes.textColor = UIColor.lightGray
        self.text_ViewNotes.delegate = self
        
        
        cornerRadius(viewName: self.btn_Apply, radius: 6.0)
        cornerRadius(viewName: self.text_ViewNotes, radius: 6.0)
        cornerRadius(viewName: self.btn_ProceedtoPayment, radius: 8.0)
        let urlString = API_URL + "summary"
        let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
        self.Webservice_GetSummary(url: urlString, params:params)
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if text_ViewNotes.textColor == UIColor.lightGray {
            text_ViewNotes.text = nil
            text_ViewNotes.textColor = UIColor.black
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if text_ViewNotes.text.isEmpty {
            text_ViewNotes.text = "Write Order Notes".localiz()
            text_ViewNotes.textColor = UIColor.lightGray
        }
        
    }
    @IBAction func btnTap_Delivery(_ sender: UIButton) {
        self.isAddressType = "1"
        self.DeliveryAddress_VIew.isHidden = false
        self.DeliveryView_height.constant = 110.0
        self.Delivery_view.backgroundColor = ORENGE_COLOR
        self.Pickupview.backgroundColor = UIColor.white
        
          if isPromoApply == "2"
                {
                    let datas = self.summaryData
                    self.lbl_Promocode.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(formatter.string(for:0.00)!)"
                    self.DiscountAmount = "\(0.00)"
                    let tax = datas["tax"]!.stringValue.toDouble
                    let taxrate = (Double(datas["order_total"]!.doubleValue * tax)) / 100
                    print(taxrate)
                    let TaxratePrice = formatter.string(for: taxrate)
                    
                    
                    self.lbl_tax.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TaxratePrice!)"
                    self.tax = "\(datas["tax"]!.stringValue)"
                    self.tax_amount = "\(taxrate)"
                    self.promocode = ""
                    
                    self.DeliveryCharge = formatter.string(for: datas["delivery_charge"]!.stringValue.toDouble)!
                    self.lbl_DeliveryCharge.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(self.DeliveryCharge)"
                    
                    let GrandPrintTotal = "\(datas["order_total"]!.doubleValue + taxrate + datas["delivery_charge"]!.doubleValue)"
                    let TotalPrice = formatter.string(for: GrandPrintTotal.toDouble)
                    self.lbl_TotalAmount.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TotalPrice!)"
                    self.TotalAmount = Double("\(TotalPrice!)".replacingOccurrences(of: ",", with: ""))!
                    let taxstr = "Tax".localiz()
                    self.lbl_stringTax.text = "\(taxstr) (\(datas["tax"]!.stringValue)%)"
                    self.btn_Apply.setTitle("Apply".localiz(), for: .normal)
//                    self.txt_Promocode.text = ""
//                    self.lbl_GetPromoCode.text = ""
//                    isApply = "remove"
//                    self.isPromoApply = "2"
                }
          else{
            let datas = self.summaryData
            self.offerAmount = Double(self.Promo)
            self.discount_pr = "\(self.Promo)"
            let promorate = (datas["order_total"]!.doubleValue) * (Double(self.Promo)) / 100
            print(promorate)
            let PromoPrice = formatter.string(for: promorate)
            
            self.lbl_Promocode.text = "-\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(PromoPrice!)"
            self.DiscountAmount = "\(PromoPrice!)"
            let tax = datas["tax"]!.stringValue.toDouble
            let taxrate = (datas["order_total"]!.doubleValue) * (Double(tax).rounded(toPlaces: 2)) / 100
            print(taxrate.rounded(toPlaces: 2))
            let TaxratePrice = formatter.string(for: taxrate)
            self.lbl_tax.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TaxratePrice!)"
            self.tax = "\(datas["tax"]!.stringValue)"
            self.tax_amount = "\(taxrate)"
            //                     self.DeliveryCharge = "\(datas["delivery_charge"]!.stringValue)"
            self.DeliveryCharge = formatter.string(for: datas["delivery_charge"]!.stringValue.toDouble)!
            self.lbl_DeliveryCharge.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(self.DeliveryCharge)"
            
            
            
            let GrandPrintTotal = "\((datas["order_total"]!.doubleValue + taxrate + datas["delivery_charge"]!.doubleValue) - promorate)"
            let TotalPrice = formatter.string(for: GrandPrintTotal.toDouble)
            self.lbl_TotalAmount.text = "\((UserDefaultManager.getStringFromUserDefaults(key: UD_currency)))\(TotalPrice!)"
            self.TotalAmount = Double("\(TotalPrice!)".replacingOccurrences(of: ",", with: ""))!
            print(self.TotalAmount)
            let taxstr = "Tax".localiz()
            self.lbl_stringTax.text = "\(taxstr) (\(datas["tax"]!.stringValue)%)"
        }
    }
    
    @IBAction func btnTap_Pickup(_ sender: UIButton) {
        
        self.isAddressType = "2"
        self.DeliveryAddress_VIew.isHidden = true
        self.DeliveryView_height.constant = 0.0
        self.Delivery_view.backgroundColor = UIColor.white
        self.Pickupview.backgroundColor = ORENGE_COLOR
        
        if isPromoApply == "2"
        {
            let datas = self.summaryData
            self.lbl_Promocode.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(formatter.string(for:0.00)!)"
            self.DiscountAmount = "\(0.00)"
            let tax = datas["tax"]!.stringValue.toDouble
            let taxrate = (Double(datas["order_total"]!.doubleValue * tax)) / 100
            print(taxrate)
            let TaxratePrice = formatter.string(for: taxrate)
            print(TaxratePrice)

            self.lbl_tax.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TaxratePrice!)"
            self.tax = "\(tax)"
            self.tax_amount = "\(taxrate)"
            self.promocode = ""

            self.DeliveryCharge = formatter.string(for: 0.00)!
            self.lbl_DeliveryCharge.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(self.DeliveryCharge)"

            let GrandPrintTotal = "\(datas["order_total"]!.doubleValue + taxrate)"
            let TotalPrice = formatter.string(for: GrandPrintTotal.toDouble)
            self.lbl_TotalAmount.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TotalPrice!)"
            self.TotalAmount = Double("\(TotalPrice!)".replacingOccurrences(of: ",", with: ""))!
            let taxstr = "Tax".localiz()
            self.lbl_stringTax.text = "\(taxstr) (\(datas["tax"]!.stringValue)%)"
//            self.btn_Apply.setTitle("Apply".localiz(), for: .normal)
//            self.txt_Promocode.text = ""
//            self.lbl_GetPromoCode.text = ""
        }
        else{
            let datas = self.summaryData
            //        self.Promo = responseData["offer_amount"]!.doubleValue
                    self.offerAmount = Double(self.Promo)
                    self.discount_pr = "\(self.Promo)"
                    let promorate = (datas["order_total"]!.doubleValue) * (Double(self.Promo)) / 100
                    print(promorate)
                    let PromoPrice = formatter.string(for: promorate)
                    print(PromoPrice)
                    self.lbl_Promocode.text = "-\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(PromoPrice!)"
                    self.DiscountAmount = "\(PromoPrice!)"
                    let tax = datas["tax"]!.stringValue.toDouble
                    let taxrate = (datas["order_total"]!.doubleValue) * (Double(tax).rounded(toPlaces: 2)) / 100
                    print(taxrate.rounded(toPlaces: 2))
                    let TaxratePrice = formatter.string(for: taxrate)
                    print(TaxratePrice)
                    
                    self.lbl_tax.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TaxratePrice!)"
                    self.tax = "\(datas["tax"]!.stringValue)"
                    self.tax_amount = "\(taxrate)"
                    //                     self.DeliveryCharge = "\(datas["delivery_charge"]!.stringValue)"
                    self.DeliveryCharge = formatter.string(for: 0.00)!
                    self.lbl_DeliveryCharge.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(self.DeliveryCharge)"
                    
                    
                    
                    let GrandPrintTotal = "\((datas["order_total"]!.doubleValue + taxrate - promorate))"
                    let TotalPrice = formatter.string(for: GrandPrintTotal.toDouble)
                    self.lbl_TotalAmount.text = "\((UserDefaultManager.getStringFromUserDefaults(key: UD_currency)))\(TotalPrice!)"
                    self.TotalAmount = Double("\(TotalPrice!)".replacingOccurrences(of: ",", with: ""))!
                    print(self.TotalAmount)
                    let taxstr = "Tax".localiz()
                    self.lbl_stringTax.text = "\(taxstr) (\(datas["tax"]!.stringValue)%)"
        }
    }
    @IBAction func btnTap_SelectPromoCode(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "PromoCodeListVC") as! PromoCodeListVC
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func btnTap_Apply(_ sender: UIButton) {
        if isApply == "apply"
        {
            let datas = self.summaryData
            self.lbl_Promocode.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(formatter.string(for:0.00)!)"
            self.DiscountAmount = "\(0.00)"
            let tax = datas["tax"]!.stringValue.toDouble
            let taxrate = (Double(datas["order_total"]!.doubleValue * tax)) / 100
            print(taxrate)
            let TaxratePrice = formatter.string(for: taxrate)
            print(TaxratePrice)
            
            self.lbl_tax.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TaxratePrice!)"
            self.tax = "\(datas["tax"]!.stringValue)"
            self.tax_amount = "\(taxrate)"
            self.promocode = ""
            if isAddressType == "1"
            {
                self.DeliveryCharge = formatter.string(for: datas["delivery_charge"]!.stringValue.toDouble)!
            }
            else{
                self.DeliveryCharge = "0.00"
            }
//            self.DeliveryCharge = formatter.string(for: datas["delivery_charge"]!.stringValue.toDouble)!
            self.lbl_DeliveryCharge.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(self.DeliveryCharge)"
            
            let GrandPrintTotal = "\(datas["order_total"]!.doubleValue + taxrate + datas["delivery_charge"]!.doubleValue)"
            let TotalPrice = formatter.string(for: GrandPrintTotal.toDouble)
            print(TotalPrice)
            self.lbl_TotalAmount.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TotalPrice!)"
            self.TotalAmount = Double("\(TotalPrice!)".replacingOccurrences(of: ",", with: ""))!
            let taxstr = "Tax".localiz()
            self.lbl_stringTax.text = "\(taxstr) (\(datas["tax"]!.stringValue)%)"
            self.btn_Apply.setTitle("Apply".localiz(), for: .normal)
            self.txt_Promocode.text = ""
            self.lbl_GetPromoCode.text = ""
            isApply = "remove"
            self.isPromoApply = "2"
        }
        else
        {
            if self.txt_Promocode.text != ""
            {
                let urlString = API_URL + "promocode"
                let params: NSDictionary = ["offer_code":self.txt_Promocode.text!]
                self.Webservice_GetPromocode(url: urlString, params:params)
                isApply = "apply"
                self.isPromoApply = "1"
            }
            else{
                showAlertMessage(titleStr: "", messageStr: "Enter Promocode".localiz())
            }
            
        }
    }
    @IBAction func btnTap_Payment(_ sender: Any) {
        if self.isAddressType == "1"
        {
            if self.lbl_DeliveryAddress.text == "Set Your Delivery Address"
            {
                showAlertMessage(titleStr: "", messageStr: "Enter Delivery Address".localiz())
            }
            else{
                if self.text_ViewNotes.text == "Write Order Notes".localiz()
                {
                    self.text_ViewNotes.text! = ""
                }
                let vc = self.storyboard?.instantiateViewController(identifier: "PaymentVC") as! PaymentVC
                vc.Address = self.lbl_DeliveryAddress.text!
                vc.Totalamount = self.TotalAmount
                vc.DiscountAmount = self.DiscountAmount
                vc.promocode = self.promocode
                vc.discount_pr = self.discount_pr
                vc.tax = self.tax
                vc.tax_amount = formatter.string(for: self.tax_amount.toDouble)!
                vc.DeliveryCharge = self.DeliveryCharge.replacingOccurrences(of: ",", with: "")
                vc.Order_Notes = self.text_ViewNotes.text!
                vc.lat = UserDefaultManager.getStringFromUserDefaults(key: UD_SelectedLat)
                vc.lang = UserDefaultManager.getStringFromUserDefaults(key: UD_SelectedLng)
                vc.OrderType = self.isAddressType
                self.navigationController?.pushViewController(vc, animated:true)
            }
        }
        else
        {
            if self.text_ViewNotes.text == "Write Order Notes".localiz()
            {
                self.text_ViewNotes.text! = ""
            }
            
            let vc = self.storyboard?.instantiateViewController(identifier: "PaymentVC") as! PaymentVC
            vc.Address = ""
            vc.Totalamount = self.TotalAmount
            vc.DiscountAmount = self.DiscountAmount
            vc.promocode = self.promocode
            vc.discount_pr = self.discount_pr
            vc.tax = self.tax
            vc.tax_amount = formatter.string(for: self.tax_amount.toDouble)!
            vc.DeliveryCharge = self.DeliveryCharge.replacingOccurrences(of: ",", with: "")
            vc.Order_Notes = self.text_ViewNotes.text!
            vc.lat = ""
            vc.lang = ""
            vc.OrderType = self.isAddressType
            self.navigationController?.pushViewController(vc, animated:true)
        }
    }
    
    
    @IBAction func btnTap_back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTap_LocationAddress(_ sender: UIButton) {
        self.getCurrentLocation()
    }
    
    func getCurrentLocation()
    {
        if isConnectedToNetwork()
        {
            locManager.requestAlwaysAuthorization()
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways)
            {
                currentLocation = locManager.location
                if currentLocation != nil
                {
                    let lattitude = "\(currentLocation.coordinate.latitude)"
                    let longitude = "\(currentLocation.coordinate.longitude)"
                    UserDefaultManager.setStringToUserDefaults(value: lattitude, key: UD_SelectedLat)
                    UserDefaultManager.setStringToUserDefaults(value: longitude, key: UD_SelectedLng)
                    self.lat = lattitude
                    self.lang = longitude
                    self.getAddressFromLatLon(pdblLatitude: lattitude, withLongitude: longitude, isFrom: 0)
                }
                else {
                    UserDefaultManager.setStringToUserDefaults(value:"6.3820209", key: UD_SelectedLat)
                    UserDefaultManager.setStringToUserDefaults(value:"2.4418744", key: UD_SelectedLng)
                    
                    self.getAddressFromLatLon(pdblLatitude: UserDefaultManager.getStringFromUserDefaults(key: UD_SelectedLat), withLongitude: UserDefaultManager.getStringFromUserDefaults(key: UD_SelectedLng), isFrom: 0)
                    
                }
            }
            else {
                
                DispatchQueue.main.async {
                    let alertVC = UIAlertController(title: Bundle.main.displayName!, message: "Allow this app to access your location", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }
                    alertVC.addAction(okAction)
                    self.present(alertVC,animated: true,completion: nil)
                }
                //                UserDefaultManager.setStringToUserDefaults(value:"6.3820209", key: UD_SelectedLat)
                //                UserDefaultManager.setStringToUserDefaults(value:"2.4418744", key: UD_SelectedLng)
                //                self.getAddressFromLatLon(pdblLatitude: UserDefaultManager.getStringFromUserDefaults(key: UD_SelectedLat), withLongitude: UserDefaultManager.getStringFromUserDefaults(key: UD_SelectedLng), isFrom: 0)
            }
        }
    }
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String, isFrom: Int) {
        var strState = ""
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        let lon: Double = Double("\(pdblLongitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    let pm = placemarks![0]
                    var addressString : String = ""
                    if pm.name != nil {
                        addressString = addressString + pm.name! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.subAdministrativeArea != nil {
                        addressString = addressString + pm.subAdministrativeArea! + ", "
                    }
                    if pm.administrativeArea != nil {
                        strState = pm.administrativeArea!
                        addressString = addressString + pm.administrativeArea! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    print(addressString)
                    self.lbl_DeliveryAddress.text = addressString
                    self.lbl_DeliveryAddress.textColor = UIColor.black
                    
                }
                
        })
    }
    
}
extension OrderDetails: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getsummaryData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.Tableview_OrderSummryList.dequeueReusableCell(withIdentifier: "OrderSummaryCell") as! OrderSummaryCell
        cornerRadius(viewName: cell.cell_view, radius: 6.0)
        cornerRadius(viewName: cell.img_Items, radius: 4.0)
        cornerRadius(viewName: cell.btn_Note, radius: 4.0)
        cornerRadius(viewName: cell.btn_Addons, radius: 4.0)
        let data = self.getsummaryData[indexPath.row]
        cell.lbl_itemName.text = data["item_name"].stringValue

        cell.lbl_count.text = "QTY : \(data["qty"].stringValue)"
        let itemTotalPrice = formatter.string(for: data["total_price"].stringValue.toDouble)
        cell.lbl_Price.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(itemTotalPrice!)"
        let itemImage = data["itemimage"].dictionaryValue
        cell.img_Items.sd_setImage(with: URL(string: itemImage["image"]!.stringValue), placeholderImage: UIImage(named: "placeholder_image"))
        if data["addons"].arrayValue.count == 0
        {
            cell.btn_Addons.isEnabled = false
            cell.btn_Addons.backgroundColor = UIColor.lightGray
        }
        else{
            cell.btn_Addons.isEnabled = true
        }
        if data["item_notes"].stringValue == ""
        {
            cell.btn_Note.isEnabled = false
            cell.btn_Note.backgroundColor = UIColor.lightGray
        }
        else{
            cell.btn_Note.isEnabled = true
        }
        cell.btn_Addons.tag = indexPath.row
        cell.btn_Addons.addTarget(self, action: #selector(btnTapAddonse), for: .touchUpInside)
        cell.btn_Note.tag = indexPath.row
        cell.btn_Note.addTarget(self, action: #selector(btnTapNotes), for: .touchUpInside)
        return cell
    }
    @objc func btnTapAddonse(sender:UIButton)
    {
        let data = getsummaryData[sender.tag]
        let addonceData = data["addons"].arrayValue
        print(addonceData)
        let vc = self.storyboard?.instantiateViewController(identifier: "AddonceListVC") as! AddonceListVC
        vc.SelectedAddons = addonceData
        self.present(vc, animated: true, completion: nil)
    }
    @objc func btnTapNotes(sender:UIButton)
    {
        let data = getsummaryData[sender.tag]
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "NoteVC") as! NoteVC
        VC.modalPresentationStyle = .overFullScreen
        VC.modalTransitionStyle = .crossDissolve
        VC.Note = data["item_notes"].stringValue
        self.present(VC,animated: true,completion: nil)
        
    }
}
//MARK: Webservices
extension OrderDetails {
    func Webservice_GetSummary(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].arrayValue
                    let summerydata = jsonResponse!["summery"].dictionaryValue
                    //                    self.addonsArray = jsonResponse!["addons"].arrayValue
                    
                    self.lbl_Promocode.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(formatter.string(for:0.00)!)"
                    self.summaryData = summerydata
                    self.getsummaryData = responseData
                    let itemPrice = formatter.string(for: summerydata["order_total"]!.stringValue.toDouble)
                    self.lbl_OrderTotal.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(itemPrice!)"
                    let tax = summerydata["tax"]!.stringValue.toDouble
                    let taxrate = (summerydata["order_total"]!.doubleValue) * (Double(tax)) / 100
                    let TaxratePrice = formatter.string(for: taxrate)
                    self.DiscountAmount = "0.00"
                    self.promocode = ""
                    self.lbl_tax.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TaxratePrice!)"
                    self.tax = "\(summerydata["tax"]!.stringValue)"
                    self.tax_amount = "\(taxrate)"
                    self.DeliveryCharge = formatter.string(for: summerydata["delivery_charge"]!.stringValue.toDouble)!
                    self.lbl_DeliveryCharge.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(self.DeliveryCharge)"
                    
                    let GrandPrintTotal = "\(summerydata["order_total"]!.doubleValue + Double(taxrate) + summerydata["delivery_charge"]!.doubleValue)"
                    let TotalPrice = formatter.string(for: GrandPrintTotal.toDouble)
                    self.lbl_TotalAmount.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TotalPrice!)"
                    self.TotalAmount = Double("\(TotalPrice!)".replacingOccurrences(of: ",", with: ""))!
                    let taxstr = "Tax".localiz()
                    self.lbl_stringTax.text = "\(taxstr) (\(summerydata["tax"]!.stringValue)%)"
                    print(responseData)
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.Tableview_Height.constant = CGFloat(105 * self.getsummaryData.count)
                    }
                    self.Tableview_OrderSummryList.delegate = self
                    self.Tableview_OrderSummryList.dataSource = self
                    self.Tableview_OrderSummryList.reloadData()
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    func Webservice_GetPromocode(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].dictionaryValue
                    self.promocode = responseData["offer_code"]!.stringValue
                    self.lbl_GetPromoCode.text = self.promocode
                    let datas = self.summaryData
                    self.Promo = responseData["offer_amount"]!.doubleValue
                    self.offerAmount = Double(self.Promo)
                    self.discount_pr = "\(self.Promo)"
                    let promorate = (datas["order_total"]!.doubleValue) * (Double(self.Promo)) / 100
                    print(promorate)
                    let PromoPrice = formatter.string(for: promorate)
                    
                    self.lbl_Promocode.text = "-\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(PromoPrice!)"
                    self.DiscountAmount = "\(PromoPrice!)"
                    let tax = datas["tax"]!.stringValue.toDouble
                    let taxrate = (datas["order_total"]!.doubleValue) * (Double(tax).rounded(toPlaces: 2)) / 100
                    print(taxrate.rounded(toPlaces: 2))
                    let TaxratePrice = formatter.string(for: taxrate)
                    
                    if self.isAddressType == "1"
                    {
                        self.DeliveryCharge = formatter.string(for: datas["delivery_charge"]!.stringValue.toDouble)!
                    }
                    else{
                        self.DeliveryCharge = "0.00"
                    }
                    self.lbl_tax.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(TaxratePrice!)"
                    self.tax = "\(tax)"
                    self.tax_amount = "\(taxrate)"
                    //                     self.DeliveryCharge = "\(datas["delivery_charge"]!.stringValue)"
//                    self.DeliveryCharge = formatter.string(for: datas["delivery_charge"]!.stringValue.toDouble)!
                    self.lbl_DeliveryCharge.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(self.DeliveryCharge)"
                    
                    let GrandPrintTotal = "\((datas["order_total"]!.doubleValue + taxrate + datas["delivery_charge"]!.doubleValue) - promorate)"
                    let TotalPrice = formatter.string(for: GrandPrintTotal.toDouble)
                    self.lbl_TotalAmount.text = "\((UserDefaultManager.getStringFromUserDefaults(key: UD_currency)))\(TotalPrice!)"
                    self.TotalAmount = Double("\(TotalPrice!)".replacingOccurrences(of: ",", with: ""))!
                    print(self.TotalAmount)
                    let taxstr = "Tax".localiz()
                    self.lbl_stringTax.text = "\(taxstr) (\(datas["tax"]!.stringValue)%)"
                    self.btn_Apply.setTitle("Remove".localiz(), for: .normal)
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
