//
//  AddtoCartVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 04/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import SlideMenuControllerSwift

class CartCell: UITableViewCell {
    
    @IBOutlet weak var lbl_ProductName: UILabel!
    @IBOutlet weak var img_Product: UIImageView!
    
    @IBOutlet weak var btn_Notes: UIButton!
    @IBOutlet weak var btn_Addonse: UIButton!
    
    @IBOutlet weak var btn_Delete: UIButton!
    @IBOutlet weak var lbl_Price: UILabel!
    @IBOutlet weak var lbl_count: UILabel!
    @IBOutlet weak var btn_Minse: UIButton!
    @IBOutlet weak var btn_Pluse: UIButton!
}
class AddtoCartVC: UIViewController {
    
    @IBOutlet weak var btn_Checkout: UIButton!
    @IBOutlet weak var lbl_TitleLabel: UILabel!
    
    @IBOutlet weak var TableView_CartList: UITableView!
    var cartDetailsarray = [[String:Any]]()
    var getCartData = [JSON]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_TitleLabel.text = "Cart".localiz()
        self.btn_Checkout.setTitle("Checkout".localiz(), for: .normal)
        cornerRadius(viewName:btn_Checkout, radius: 8.0)
        let urlString = API_URL + "getcart"
        let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
        self.Webservice_GetCartDetails(url: urlString, params:params)
        
    }
    
    @IBAction func btnTap_Checkout(_ sender: UIButton) {
        let urlString = API_URL + "isopen"
        self.Webservice_OpenClose(url: urlString, params:[:])
        
    }
    @IBAction func btnTap_back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnTap_Home(_ sender: UIButton) {

        if UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "en" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "N/A"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let objVC = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            let sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
            let appNavigation: UINavigationController = UINavigationController(rootViewController: objVC)
            appNavigation.setNavigationBarHidden(true, animated: true)
            let slideMenuController = SlideMenuController(mainViewController: appNavigation, leftMenuViewController: sideMenuViewController)
            slideMenuController.changeLeftViewWidth(UIScreen.main.bounds.width * 0.8)
            slideMenuController.removeLeftGestures()
            UIApplication.shared.windows[0].rootViewController = slideMenuController
        }
        else
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let objVC = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            let sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
            let appNavigation: UINavigationController = UINavigationController(rootViewController: objVC)
            appNavigation.setNavigationBarHidden(true, animated: true)
            let slideMenuController = SlideMenuController(mainViewController: appNavigation, rightMenuViewController: sideMenuViewController)
            slideMenuController.changeRightViewWidth(UIScreen.main.bounds.width * 0.8)
            slideMenuController.removeRightGestures()
            UIApplication.shared.windows[0].rootViewController = slideMenuController
        }
    }
}
extension AddtoCartVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: self.TableView_CartList.bounds.size.width, height: self.TableView_CartList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        //               messageLabel.font = UIFont(name: "Gilroy-Medium", size: 17)!
        messageLabel.sizeToFit()
        self.TableView_CartList.backgroundView = messageLabel;
        if self.cartDetailsarray.count == 0 {
            messageLabel.text = "NO DATA FOUND".localiz()
            self.btn_Checkout.isHidden = true
        }
        else {
            messageLabel.text = ""
            self.btn_Checkout.isHidden = false
        }
        
        return self.cartDetailsarray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.TableView_CartList.dequeueReusableCell(withIdentifier: "CartCell") as! CartCell
        cornerRadius(viewName: cell.img_Product, radius: 6.0)
        cornerRadius(viewName: cell.btn_Addonse, radius:4.0)
        cornerRadius(viewName: cell.btn_Notes, radius:4.0)
        
        let data = cartDetailsarray[indexPath.row]
        cell.lbl_count.text! = data["qty"]! as! String

        cell.lbl_Price.text! = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(data["price"]!)"
        if Int(data["qty"]! as! String)! <= 1
        {
            cell.btn_Minse.isEnabled = false
        }
        else{
            cell.btn_Minse.isEnabled = true
        }
        cell.lbl_ProductName.text! = data["item_name"]! as! String
        let imgUrl =  data["itemimage"]!
        print(data["price_update"]!)
        cell.img_Product.sd_setImage(with: URL(string: imgUrl as! String), placeholderImage: UIImage(named: "placeholder_image"))
        cell.btn_Minse.tag = indexPath.row
        cell.btn_Minse.addTarget(self, action: #selector(btnTapMines), for: .touchUpInside)
        cell.btn_Pluse.tag = indexPath.row
        cell.btn_Pluse.addTarget(self, action: #selector(btnTapPluse), for: .touchUpInside)
        cell.btn_Delete.tag = indexPath.row
        cell.btn_Delete.addTarget(self, action: #selector(btnTapDelete), for: .touchUpInside)
        cell.btn_Addonse.tag = indexPath.row
        cell.btn_Addonse.addTarget(self, action: #selector(btnTapAddonse), for: .touchUpInside)
        cell.btn_Notes.tag = indexPath.row
        cell.btn_Notes.addTarget(self, action: #selector(btnTapNotes), for: .touchUpInside)
        
        let isaddonce = data["addons"]! as! [JSON]
        if isaddonce.count == 0
        {
            cell.btn_Addonse.isEnabled = false
            cell.btn_Addonse.backgroundColor = UIColor.lightGray
        }
        else{
            cell.btn_Addonse.isEnabled = true
        }
        
        let item_notes = data["item_notes"] as! String
        
        if item_notes == ""
        {
            cell.btn_Notes.isEnabled = false
            cell.btn_Notes.backgroundColor = UIColor.lightGray
        }
        else
        {
             cell.btn_Notes.isEnabled = true
            
        }
        
        
        return cell
    }
    
    @objc func btnTapMines(sender:UIButton)
    {
        let data = cartDetailsarray[sender.tag]
        var qty = Int(data["qty"]! as! String )
        qty = qty! - 1
        let urlString = API_URL + "qtyupdate"
        let params: NSDictionary = ["cart_id":data["id"]!,"item_id":data["item_id"]!,"qty":"\(qty!)","user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
        self.Webservice_QtyUpdate(url: urlString, params:params)
    }
    @objc func btnTapPluse(sender:UIButton)
    {
        let data = cartDetailsarray[sender.tag]
        var qty = Int(data["qty"]! as! String)
        qty = qty! + 1
        let urlString = API_URL + "qtyupdate"
        let params: NSDictionary = ["cart_id":data["id"]!,"item_id":data["item_id"]!,"qty":"\(qty!)","user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
        self.Webservice_QtyUpdate(url: urlString, params:params)
    }
    @objc func btnTapDelete(sender:UIButton)
    {
        let alertVC = UIAlertController(title: Bundle.main.displayName!, message: "Are you sure to remove this item from your cart list?".localiz(), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes".localiz(), style: .default) { (action) in
            let data = self.cartDetailsarray[sender.tag]
            let urlString = API_URL + "deletecartitem"
            let params: NSDictionary = ["cart_id":data["id"]!]
            self.Webservice_DeleteCartItem(url: urlString, params:params)
        }
        let noAction = UIAlertAction(title: "No".localiz(), style: .destructive)
        alertVC.addAction(yesAction)
        alertVC.addAction(noAction)
        self.present(alertVC,animated: true,completion: nil)
    }
    @objc func btnTapAddonse(sender:UIButton)
      {
          let data = cartDetailsarray[sender.tag]
          let addonceData = data["addons"]!
          print(addonceData)
          let vc = self.storyboard?.instantiateViewController(identifier: "AddonceListVC") as! AddonceListVC
          vc.SelectedAddons = addonceData as! [JSON]
          self.present(vc, animated: true, completion: nil)
      }
      @objc func btnTapNotes(sender:UIButton)
      {
          let data = cartDetailsarray[sender.tag]
          let VC = self.storyboard?.instantiateViewController(withIdentifier: "NoteVC") as! NoteVC
          VC.modalPresentationStyle = .overFullScreen
          VC.modalTransitionStyle = .crossDissolve
          VC.Note = data["item_notes"] as! String
          self.present(VC,animated: true,completion: nil)
          
      }
}

extension AddtoCartVC
{
        func Webservice_GetCartDetails(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responceData = jsonResponse!["data"].arrayValue
                    self.cartDetailsarray.removeAll()
                    for data in responceData
                    {
                        let itemsimage = data["itemimage"].dictionaryValue
                        print(itemsimage)
                        let ItemPrice = formatter.string(for: data["price"].stringValue.toDouble)
                        let obj = ["id":data["id"].stringValue,"qty":data["qty"].stringValue,"price":ItemPrice!,"price_update":data["price"].stringValue,"item_name":data["item_name"].stringValue,"item_id":data["item_id"].stringValue,"itemimage":itemsimage["image"]!.stringValue,"addons":data["addons"].arrayValue,"item_notes":data["item_notes"].stringValue] as [String : Any]
                        self.cartDetailsarray.append(obj)
                    }
                    self.TableView_CartList.delegate = self
                    self.TableView_CartList.dataSource = self
                    self.TableView_CartList.reloadData()
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    func Webservice_QtyUpdate(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
//                    let responceData = jsonResponse!["data"].arrayValue
                    let urlString = API_URL + "getcart"
                    let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
                    self.Webservice_GetCartDetails(url: urlString, params:params)
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    func Webservice_DeleteCartItem(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
//                    let responceData = jsonResponse!["data"].arrayValue
                    let urlString = API_URL + "getcart"
                    let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
                    self.Webservice_GetCartDetails(url: urlString, params:params)
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
     func Webservice_OpenClose(url:String, params:NSDictionary) -> Void {
            WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "GET", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
                
                if strErrorMessage.count != 0 {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
                }
                else {
                    print(jsonResponse!)
                    let responseCode = jsonResponse!["status"].stringValue
                    if responseCode == "1" {
                        let vc = self.storyboard?.instantiateViewController(identifier: "OrderDetails") as! OrderDetails
                        self.navigationController?.pushViewController(vc, animated:true)
                    }
                    else {
                        showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                    }
                }
            }
        }
}
