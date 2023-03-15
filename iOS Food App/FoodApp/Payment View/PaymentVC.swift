//
//  PaymentVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 06/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import Razorpay
import SwiftyJSON
import SlideMenuControllerSwift


class PaymentVC: UIViewController,RazorpayPaymentCompletionProtocol {
     var razorpayTestKey = "rzp_test_FJItCDPMYxVIDN"
//    var razorpayTestKey = "rzp_test_hgVVr19y3viG0C"
    var razorpay : RazorpayCheckout!
    var Totalamount = Double()
    var Address = String()
    var Name = String()
    var Email = String()
    var Mobile = String()
    var ProfileImage = String()
    var paymentType = String()
    var promocode = String()
    var DiscountAmount = String()
    var discount_pr = String()
    var tax = String()
    var tax_amount = String()
    var DeliveryCharge = String()
    var Order_Notes = String()
    var lat = String()
    var lang = String()
    var OrderType = String()
    @IBOutlet weak var btn_PayNow: UIButton!
    @IBOutlet weak var lbl_paymentMethodlabel: UILabel!
    @IBOutlet weak var lbl_TitleLabel: UILabel!
    
    @IBOutlet weak var lbl_paybyCash: UILabel!
    @IBOutlet weak var lbl_RazorPay: UILabel!
    
    @IBOutlet weak var online_view: CardViewMaster!
    @IBOutlet weak var cod_view: CardViewMaster!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_TitleLabel.text = "Payment".localiz()
        self.lbl_paymentMethodlabel.text = "Payment Method".localiz()
        self.lbl_paybyCash.text = "Pay By Cash".localiz()
        self.lbl_RazorPay.text = "Razorpay".localiz()
        self.paymentType = "0"
        cornerRadius(viewName: self.btn_PayNow, radius: 8.0)
        razorpay = RazorpayCheckout.initWithKey(razorpayTestKey, andDelegate: self)
        let urlString = API_URL + "getprofile"
        let params: NSDictionary = ["user_id":UserDefaults.standard.value(forKey: UD_userId) as! String]
        self.Webservice_GetProfile(url: urlString, params: params)
    }
    @IBAction func btnTap_cod(_ sender: Any) {
        self.cod_view.backgroundColor = ORENGE_COLOR
        self.online_view.backgroundColor = UIColor.white
        self.paymentType = "0"
    }
    @IBAction func btnTap_Razorpay(_ sender: UIButton) {
        self.cod_view.backgroundColor = UIColor.white
        self.online_view.backgroundColor = ORENGE_COLOR
        self.paymentType = "1"
    }
    @IBAction func btnTap_PayNow(_ sender: UIButton) {
        if self.paymentType == "0"
        {
            let urlString = API_URL + "order"
            let params: NSDictionary =
                [
                    "user_id":UserDefaults.standard.value(forKey: UD_userId) as! String,
                    "order_total":self.Totalamount,
                    "payment_type":self.paymentType,
                    "address":self.Address,
                    "promocode":self.promocode,
                    "discount_amount":self.DiscountAmount,
                    "discount_pr":self.discount_pr,
                    "tax":self.tax,
                    "tax_amount":self.tax_amount,
                    "delivery_charge":self.DeliveryCharge,
                    "order_notes":self.Order_Notes,
                    "lat":self.lat,
                    "lang":self.lang,
                    "order_type":self.OrderType
            ]
            self.Webservice_order(url: urlString, params: params)
        }
        else if self.paymentType == "1"
        {
            self.showPaymentForm()
        }
    }
    @IBAction func btnTap_back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func showPaymentForm(){
        let options: [String:Any] = [
            "amount" : "\(self.Totalamount * 100)", //mandatory in paise like:- 1000 paise ==  10 rs
            "currency": "USD",
            "description": "purchase description",
            "image": self.ProfileImage,
            "name": self.Name,
            //                "order_id": "order_4xbQrmEoA5WJ0G",
            "prefill": [
                "contact": self.Mobile,
                "email": self.Email
            ],
            "theme": [
                "color": "#FE724C"
            ]
        ]
        razorpay?.open(options)
    }
    
    func onPaymentError(_ code: Int32, description str: String)
    {
        let alertController = UIAlertController(title: "FAILURE", message: str, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func onPaymentSuccess(_ payment_id: String)
    {
        print(payment_id)
        //        let alertController = UIAlertController(title: "SUCCESS", message: "Payment Id \(payment_id)", preferredStyle: UIAlertController.Style.alert)
        //        let cancelAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        //        alertController.addAction(cancelAction)
        //
        //        self.view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        //
        let urlString = API_URL + "order"
        let params: NSDictionary =
            [
                "user_id":UserDefaults.standard.value(forKey: UD_userId) as! String,
                "order_total":self.Totalamount,
                "razorpay_payment_id":"\(payment_id)",
                "payment_type":self.paymentType,
                "address":self.Address,
                "promocode":self.promocode,
                "discount_amount":self.DiscountAmount,
                "discount_pr":self.discount_pr,
                "tax":self.tax,
                "tax_amount":self.tax_amount,
                "delivery_charge":self.DeliveryCharge,
                "order_notes":self.Order_Notes,
                "lat":self.lat,
                "lang":self.lang,
                "order_type":self.OrderType
        ]
        self.Webservice_order(url: urlString, params: params)
    }
}
//MARK: Webservices
extension PaymentVC {
    func Webservice_order(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].arrayValue
                    print(responseData)
                    
                    if UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "en" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "N/A"
                    {
                        let alertVC = UIAlertController(title: Bundle.main.displayName!, message: jsonResponse!["message"].stringValue, preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "Okay".localiz(), style: .default) { (action) in
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let objVC = storyBoard.instantiateViewController(withIdentifier: "OrderHistoryVC") as! OrderHistoryVC
                            let sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
                            let appNavigation: UINavigationController = UINavigationController(rootViewController: objVC)
                            appNavigation.setNavigationBarHidden(true, animated: true)
                            let slideMenuController = SlideMenuController(mainViewController: appNavigation, leftMenuViewController: sideMenuViewController)
                            slideMenuController.changeLeftViewWidth(UIScreen.main.bounds.width * 0.8)
                            slideMenuController.removeLeftGestures()
                            UIApplication.shared.windows[0].rootViewController = slideMenuController
                        }
                        alertVC.addAction(yesAction)
                        self.present(alertVC,animated: true,completion: nil)
                    }
                    else
                    {
                        let alertVC = UIAlertController(title: Bundle.main.displayName!, message: jsonResponse!["message"].stringValue, preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "Okay".localiz(), style: .default) { (action) in
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let objVC = storyBoard.instantiateViewController(withIdentifier: "OrderHistoryVC") as! OrderHistoryVC
                            let sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
                            let appNavigation: UINavigationController = UINavigationController(rootViewController: objVC)
                            appNavigation.setNavigationBarHidden(true, animated: true)
                            let slideMenuController = SlideMenuController(mainViewController: appNavigation, leftMenuViewController: sideMenuViewController)
                            slideMenuController.changeLeftViewWidth(UIScreen.main.bounds.width * 0.8)
                            slideMenuController.removeLeftGestures()
                            UIApplication.shared.windows[0].rootViewController = slideMenuController
                        }
                        alertVC.addAction(yesAction)
                        self.present(alertVC,animated: true,completion: nil)
                    }
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    func Webservice_GetProfile(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: "", messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].dictionaryValue
                    print(responseData)
                    self.ProfileImage = responseData["profile_image"]!.stringValue
                    self.Name = responseData["name"]!.stringValue
                    self.Email = responseData["email"]!.stringValue
                    self.Mobile = responseData["mobile"]!.stringValue
                    
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
}
