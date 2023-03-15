//
//  SearchVC.swift
//  FoodApp
//
//  Created by iMac on 25/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
class SearchVC: UIViewController {
    @IBOutlet weak var Collectioview_SearchList: UICollectionView!
    var pageIndex = 1
    var lastIndex = 0
    @IBOutlet weak var lbl_titleLabel: UILabel!
    var categoryWiseItemsArray = [[String:String]]()
    var searchTxt = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_titleLabel.text = "Search".localiz()
    }
    @IBAction func btnTap_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func textTap_Search(_ sender: UITextField) {
        self.searchTxt = sender.text!
        print(searchTxt)
        if searchTxt == ""
        {
            categoryWiseItemsArray.removeAll()
            self.Collectioview_SearchList.reloadData()
        }
        else{
            let urlString = API_URL + "searchitem"
            let params: NSDictionary = ["keyword":searchTxt,"user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
            self.Webservice_getSearch(url: urlString, params:params)
        }
    }
}
extension SearchVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.Collectioview_SearchList.bounds.size.width, height: self.Collectioview_SearchList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
        messageLabel.sizeToFit()
        self.Collectioview_SearchList.backgroundView = messageLabel;
        if self.categoryWiseItemsArray.count == 0 {
            messageLabel.text = "NO DATA FOUND".localiz()
        }
        else {
            messageLabel.text = ""
        }
        return categoryWiseItemsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.Collectioview_SearchList.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell
        cornerRadius(viewName: cell.img_food, radius: 6.0)
        cornerRadius(viewName: cell.lbl_Price, radius: 6.0)
        cornerRadius(viewName: cell.btn_Favorites, radius: 6.0)
        let data = self.categoryWiseItemsArray[indexPath.row]
        let imgUrl = data["product_image"]!
        cell.img_food.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "placeholder_image"))
        cell.lbl_Name.text = data["item_name"]!
        let ItemPrice = formatter.string(for: data["item_price"]!.toDouble)
        cell.lbl_Price.text = " \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPrice!) "
        if data["isFavorite"]! == "0" {
            cell.btn_Favorites.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        else {
            cell.btn_Favorites.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        cell.btn_Favorites.tag = indexPath.row
        cell.btn_Favorites.addTarget(self, action:#selector(btnTap_Favorites), for: .touchUpInside)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 30.0) / 2, height: (UIScreen.main.bounds.width - 30.0 ) / 2)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = self.categoryWiseItemsArray[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(identifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.itemsId = data["id"]!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == self.categoryWiseItemsArray.count - 1 {
            if self.pageIndex != self.lastIndex {
                self.pageIndex = self.pageIndex + 1
                let urlString = API_URL + "searchitem?page=\(self.pageIndex)"
                let params: NSDictionary = ["keyword":searchTxt,"user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
                self.Webservice_getSearch(url: urlString, params:params)
            }
        }
    }
    @objc func btnTap_Favorites(sender:UIButton!) {
        print("Button tapped")
        if UserDefaultManager.getStringFromUserDefaults(key:UD_isSkip) == "1"
               {
                   let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                   let objVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                   let nav : UINavigationController = UINavigationController(rootViewController: objVC)
                   nav.navigationBar.isHidden = true
                   UIApplication.shared.windows[0].rootViewController = nav
               }
               else{
                   if self.categoryWiseItemsArray[sender.tag]["isFavorite"]! == "0" {
                       let urlString = API_URL + "addfavorite"
                       let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId),
                                                   "item_id":self.categoryWiseItemsArray[sender.tag]["id"]!]
                       self.Webservice_FavoriteItems(url: urlString, params: params, productIndex: sender.tag)
                   }
               }
        
    }
}
extension SearchVC
{
    func Webservice_getSearch(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responcedata = jsonResponse!["data"].dictionaryValue
                    if self.pageIndex == 1 {
                        self.lastIndex = Int(responcedata["last_page"]!.stringValue)!
                        self.categoryWiseItemsArray.removeAll()
                    }
                    let categoryData = responcedata["data"]!.arrayValue
                    for product in categoryData {
                        let productImage = product["itemimage"].dictionaryValue
                        let productObj = ["item_price":product["item_price"].stringValue,"id":product["id"].stringValue,"item_name":product["item_name"].stringValue,"product_image":productImage["image"]!.stringValue,"isFavorite":product["is_favorite"].stringValue]
                        self.categoryWiseItemsArray.append(productObj)
                    }
                    
                    self.Collectioview_SearchList.delegate = self
                    self.Collectioview_SearchList.dataSource = self
                    self.Collectioview_SearchList.reloadData()
                    
                }
                else {
                    self.Collectioview_SearchList.delegate = self
                    self.Collectioview_SearchList.dataSource = self
                    self.Collectioview_SearchList.reloadData()
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                    
                }
            }
        }
    }
    func Webservice_FavoriteItems(url:String, params:NSDictionary, productIndex:Int) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let productObj = ["item_price":self.categoryWiseItemsArray[productIndex]["item_price"]!,"id":self.categoryWiseItemsArray[productIndex]["id"]!,"item_name":self.categoryWiseItemsArray[productIndex]["item_name"]!,"product_image":self.categoryWiseItemsArray[productIndex]["product_image"]!,"isFavorite":"1"]
                    
                    self.categoryWiseItemsArray.remove(at: productIndex)
                    self.categoryWiseItemsArray.insert(productObj, at: productIndex)
                    
                    self.Collectioview_SearchList.delegate = self
                    self.Collectioview_SearchList.dataSource = self
                    self.Collectioview_SearchList.reloadData()
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
}
