//
//  FavoriteListVC.swift
//  FoodApp
//
//  Created by iMac on 26/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
class FavoriteListVC: UIViewController {
    @IBOutlet weak var Collectioview_FavoriteList: UICollectionView!
    var pageIndex = 1
    var lastIndex = 0
    @IBOutlet weak var lbl_titleLabel: UILabel!
    var FavoriteListArray = [[String:String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_titleLabel.text = "Favorite List".localiz()
    }
    override func viewWillAppear(_ animated: Bool) {
        let urlString = API_URL + "favoritelist"
        let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
        self.Webservice_getFavoriteList(url: urlString, params:params)
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
extension FavoriteListVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.Collectioview_FavoriteList.bounds.size.width, height: self.Collectioview_FavoriteList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
        messageLabel.sizeToFit()
        self.Collectioview_FavoriteList.backgroundView = messageLabel;
        if self.FavoriteListArray.count == 0 {
            messageLabel.text = "NO DATA FOUND".localiz()
        }
        else {
            messageLabel.text = ""
        }
        return FavoriteListArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.Collectioview_FavoriteList.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell
        cornerRadius(viewName: cell.img_food, radius: 6.0)
        cornerRadius(viewName: cell.lbl_Price, radius: 6.0)
        cornerRadius(viewName: cell.btn_Favorites, radius: 6.0)
        let data = self.FavoriteListArray[indexPath.row]
        let imgUrl = data["product_image"]!
        cell.img_food.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "placeholder_image"))
        cell.lbl_Name.text = data["item_name"]!
        cell.lbl_Price.text = " \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(data["item_price"]!) "
        if data["isFavorite"]! == "0" {
            cell.btn_Favorites.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        else {
            cell.btn_Favorites.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        cell.btn_Favorites.tag = indexPath.row
        cell.btn_Favorites.addTarget(self, action:#selector(btnTap_UnFavorites), for: .touchUpInside)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 30.0) / 2, height: (UIScreen.main.bounds.width - 30.0 ) / 2)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = self.FavoriteListArray[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(identifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.itemsId = data["id"]!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == self.FavoriteListArray.count - 1 {
            if self.pageIndex != self.lastIndex {
                self.pageIndex = self.pageIndex + 1
                let urlString = API_URL + "favoritelist?page=\(self.pageIndex)"
                let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
                self.Webservice_getFavoriteList(url: urlString, params:params)
            }
        }
    }
    @objc func btnTap_UnFavorites(sender:UIButton!) {
        let alertVC = UIAlertController(title: Bundle.main.displayName!, message: "Are you sure to remove this item from your favourite list?".localiz(), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes".localiz(), style: .default) { (action) in
            let urlString = API_URL + "removefavorite"
            let params: NSDictionary = ["favorite_id":self.FavoriteListArray[sender.tag]["favorite_id"]!]
            self.Webservice_UnFavoriteItems(url: urlString, params: params, productIndex: sender.tag)
        }
        let noAction = UIAlertAction(title: "No".localiz(), style: .destructive)
        alertVC.addAction(yesAction)
        alertVC.addAction(noAction)
        self.present(alertVC,animated: true,completion: nil)
    }
}
extension FavoriteListVC
{
    func Webservice_getFavoriteList(url:String, params:NSDictionary) -> Void {
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
                        self.FavoriteListArray.removeAll()
                    }
                    let categoryData = responcedata["data"]!.arrayValue
                    for product in categoryData {
                        let productImage = product["itemimage"].dictionaryValue
                        let ItemPrice = formatter.string(for: product["item_price"].stringValue.toDouble)
                        let productObj = ["item_price":ItemPrice!,"id":product["id"].stringValue,"item_name":product["item_name"].stringValue,"product_image":productImage["image"]!.stringValue,"isFavorite":product["is_favorite"].stringValue,"favorite_id":product["favorite_id"].stringValue]
                        self.FavoriteListArray.append(productObj)
                    }
                    
                    self.Collectioview_FavoriteList.delegate = self
                    self.Collectioview_FavoriteList.dataSource = self
                    self.Collectioview_FavoriteList.reloadData()
                    
                }
                else {
                    self.Collectioview_FavoriteList.delegate = self
                    self.Collectioview_FavoriteList.dataSource = self
                    self.Collectioview_FavoriteList.reloadData()
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                    
                }
            }
        }
    }
    func Webservice_UnFavoriteItems(url:String, params:NSDictionary, productIndex:Int) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    self.FavoriteListArray.remove(at: productIndex)
                    self.Collectioview_FavoriteList.delegate = self
                    self.Collectioview_FavoriteList.dataSource = self
                    self.Collectioview_FavoriteList.reloadData()
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
}
