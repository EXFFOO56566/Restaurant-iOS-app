//
//  HomeVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 04/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import LanguageManager_iOS
import SlideMenuControllerSwift
import CoreLocation
import MapKit
class PromotionBannerCell : UICollectionViewCell
{
    @IBOutlet weak var img_Banner: UIImageView!
}
class Categoriescell: UICollectionViewCell
{
    @IBOutlet weak var cell_view: UIView!
    @IBOutlet weak var img_categories: UIImageView!
    @IBOutlet weak var lbl_CategoriesName: UILabel!
}
class GridCell: UICollectionViewCell {
    
    @IBOutlet weak var lbl_Price: UILabel!
    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var img_food: UIImageView!
    @IBOutlet weak var btn_Favorites: UIButton!
}
class ProductCell: UITableViewCell {
    @IBOutlet weak var lbl_itemsPrice: UILabel!
    @IBOutlet weak var lbl_itemsName: UILabel!
    @IBOutlet weak var img_Product: UIImageView!
    @IBOutlet weak var btn_Favorite: UIButton!
}

class HomeVC: UIViewController {
    
    @IBOutlet weak var collectionview_BannerHeight: NSLayoutConstraint!
    @IBOutlet weak var Collectioview_PromotionBanner: UICollectionView!
    @IBOutlet weak var Collectioview_categoriesList: UICollectionView!
    
    @IBOutlet weak var Main_View: UIView!
    @IBOutlet weak var btn_Grid: UIButton!
    var refreshControl = UIRefreshControl()
    var refreshControlGrid = UIRefreshControl()
    
    var isview = String()
    // Grid View
    @IBOutlet var Gridview: UIView!
    @IBOutlet weak var collectioView_GirdList: UICollectionView!
    
    // List View
    @IBOutlet var ListView: UIView!
    @IBOutlet weak var Tableview_ProductList: UITableView!
    
    
    var categoryArray = [JSON]()
    var BannerArray = [JSON]()
    var categoryWiseItemsArray = [[String:String]]()
    
    var pageIndex = 1
    var lastIndex = 0
    var SelectedCategoryId = String()
    var selectedindex = 0
    var latitued = String()
    var longitude = String()
    @IBOutlet weak var lbl_Cartcount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Tableview_ProductList.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshData(_:)), for: .valueChanged)
        
        self.collectioView_GirdList.refreshControl = self.refreshControlGrid
        self.refreshControlGrid.addTarget(self, action: #selector(self.refreshGridData(_:)), for: .valueChanged)
        
        self.collectionview_BannerHeight.constant = 0.0
        self.Collectioview_PromotionBanner.isHidden = true
        setDecimalNumber()
        cornerRadius(viewName: self.btn_Grid, radius: self.btn_Grid.frame.height / 2)
        cornerRadius(viewName: self.lbl_Cartcount, radius: self.lbl_Cartcount.frame.height / 2)
        self.Gridview.removeFromSuperview()
        addViewDynamically(subview: self.ListView)
        
        
       
        
        
    }
    @objc private func refreshData(_ sender: Any) {
        self.refreshControl.endRefreshing()
        self.pageIndex = 1
        self.lastIndex = 0
        let urlString = API_URL + "category"
        self.Webservice_getCategory(url: urlString, params: [:])
    }
    @objc private func refreshGridData(_ sender: Any) {
           self.refreshControl.endRefreshing()
           self.pageIndex = 1
           self.lastIndex = 0
           let urlString = API_URL + "category"
           self.Webservice_getCategory(url: urlString, params: [:])
       }
    @IBAction func btnTap_menu(_ sender: UIButton) {
        if UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "en" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "" || UserDefaultManager.getStringFromUserDefaults(key: UD_isSelectLng) == "N/A"
        {
            self.slideMenuController()?.openLeft()
        }
        else {
            self.slideMenuController()?.openRight()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaultManager.getStringFromUserDefaults(key: UD_userId) != ""
        {
            let urlString = API_URL + "cartcount"
            let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
            self.Webservice_cartcount(url: urlString, params:params)
        }
        let urlString = API_URL + "category"
        self.Webservice_getCategory(url: urlString, params: [:])
    }
    
    @IBAction func btnTap_MapPin(_ sender: UIButton) {
        let urlString = API_URL + "restaurantslocation"
        self.Webservice_getrestaurantslocation(url: urlString, params: [:])
    }
    @IBAction func btnTap_Search(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnTap_Grid(_ sender: UIButton) {
        if self.isview == "list"
        {
            self.Gridview.removeFromSuperview()
            addViewDynamically(subview: self.ListView)
            self.btn_Grid.setImage(UIImage.init(named: "ic_list"), for: .normal)
            self.isview = "grid"
            
        }
        else{
            self.ListView.removeFromSuperview()
            addViewDynamically(subview: self.Gridview)
            self.btn_Grid.setImage(UIImage.init(named: "ic_Grid"), for: .normal)
            self.isview = "list"
        }
    }
    @IBAction func btnTap_Cart(_ sender: UIButton) {
        if UserDefaultManager.getStringFromUserDefaults(key:UD_isSkip) == "1"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let objVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let nav : UINavigationController = UINavigationController(rootViewController: objVC)
            nav.navigationBar.isHidden = true
            UIApplication.shared.windows[0].rootViewController = nav
        }else{
            let vc = self.storyboard?.instantiateViewController(identifier: "AddtoCartVC") as! AddtoCartVC
            self.navigationController?.pushViewController(vc, animated:true)
        }
        
    }
    
    func openMapForPlace() {
        
        let latitude: CLLocationDegrees = Double(self.latitued)!
        let longitude: CLLocationDegrees = Double(self.longitude)!
        
        let regionDistance:CLLocationDistance = 5000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Restaurant Location"
        mapItem.openInMaps(launchOptions: options)
    }
}
extension HomeVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectioView_GirdList
        {
            let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.collectioView_GirdList.bounds.size.width, height: self.collectioView_GirdList.bounds.size.height))
            let messageLabel = UILabel(frame: rect)
            messageLabel.textColor = UIColor.lightGray
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
            messageLabel.sizeToFit()
            self.collectioView_GirdList.backgroundView = messageLabel;
            if self.categoryWiseItemsArray.count == 0 {
                messageLabel.text = "NO DATA FOUND".localiz()
            }
            else {
                messageLabel.text = ""
            }
            return categoryWiseItemsArray.count
        }
        else if collectionView == self.Collectioview_categoriesList
        {
            let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.Collectioview_categoriesList.bounds.size.width, height: self.Collectioview_categoriesList.bounds.size.height))
            let messageLabel = UILabel(frame: rect)
            messageLabel.textColor = UIColor.lightGray
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
            messageLabel.sizeToFit()
            self.Collectioview_categoriesList.backgroundView = messageLabel;
            if self.categoryArray.count == 0 {
                messageLabel.text = "NO DATA FOUND".localiz()
            }
            else {
                messageLabel.text = ""
            }
            return categoryArray.count
        }
        else{
            return BannerArray.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectioView_GirdList
        {
            let cell = self.collectioView_GirdList.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell
            cornerRadius(viewName: cell.img_food, radius: 6.0)
            cornerRadius(viewName: cell.lbl_Price, radius: 6.0)
            cornerRadius(viewName: cell.btn_Favorites, radius: 6.0)
            let data = self.categoryWiseItemsArray[indexPath.row]
            let imgUrl = data["product_image"]!
            cell.img_food.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "placeholder_image"))
            cell.lbl_Name.text = data["item_name"]!
            let ItemPrice = formatter.string(for: data["item_price"]!.toDouble)
            cell.lbl_Price.text = " \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPrice!) "
            cell.btn_Favorites.tag = indexPath.row
            cell.btn_Favorites.addTarget(self, action:#selector(btnTap_Favorites), for: .touchUpInside)
            if data["isFavorite"]! == "0" {
                cell.btn_Favorites.setImage(UIImage(systemName: "heart"), for: .normal)
            }
            else {
                cell.btn_Favorites.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
            return cell
        }
        else if collectionView == self.Collectioview_categoriesList
        {
            let cell = self.Collectioview_categoriesList.dequeueReusableCell(withReuseIdentifier: "Categoriescell", for: indexPath) as! Categoriescell
            cornerRadius(viewName: cell.img_categories, radius: 6.0)
            let data = self.categoryArray[indexPath.item]
            cell.lbl_CategoriesName.text = data["category_name"].stringValue
            cell.img_categories.sd_setImage(with: URL(string: data["image"].stringValue), placeholderImage: UIImage(named: "placeholder_image"))
            if indexPath.item == selectedindex
            {
                setBorder(viewName: cell.cell_view, borderwidth: 1, borderColor: ORENGE_COLOR.cgColor, cornerRadius: 8.0)
            }
            else{
                setBorder(viewName: cell.cell_view, borderwidth: 1, borderColor: UIColor.clear.cgColor, cornerRadius: 8.0)
            }
            return cell
        }
        else{
            let cell = self.Collectioview_PromotionBanner.dequeueReusableCell(withReuseIdentifier: "PromotionBannerCell", for: indexPath) as! PromotionBannerCell
            cornerRadius(viewName: cell.img_Banner, radius: 6.0)
            let data = self.BannerArray[indexPath.item]
            cell.img_Banner.sd_setImage(with: URL(string: data["image"].stringValue), placeholderImage: UIImage(named: "placeholder_image"))
            
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectioView_GirdList
        {
            return CGSize(width: (UIScreen.main.bounds.width - 30.0) / 2, height: (UIScreen.main.bounds.width - 30.0 ) / 2)
        }
        else if collectionView == self.Collectioview_categoriesList{
            return CGSize(width: 70, height: 70.0)
        }
        else{
            return CGSize(width:(UIScreen.main.bounds.width) / 1.3, height: 120)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectioView_GirdList
        {
            
            let data = self.categoryWiseItemsArray[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(identifier: "ProductDetailsVC") as! ProductDetailsVC
            vc.itemsId = data["id"]!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView == self.Collectioview_categoriesList {
            self.selectedindex = indexPath.item
            self.pageIndex = 1
            self.lastIndex = 0
            let data = self.categoryArray[indexPath.item]
            self.SelectedCategoryId = data["id"].stringValue
            let urlString = API_URL + "item?page=\(self.pageIndex)"
            let params: NSDictionary = ["cat_id":SelectedCategoryId,
                                        "user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
            self.Webservice_getCategorywiseItems(url: urlString, params:params)
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.collectioView_GirdList
        {
            if indexPath.item == self.categoryWiseItemsArray.count - 1 {
                if self.pageIndex != self.lastIndex {
                    self.pageIndex = self.pageIndex + 1
                    if self.categoryArray.count != 0
                    {
                        let urlString = API_URL + "item?page=\(self.pageIndex)"
                        let params: NSDictionary = ["cat_id":SelectedCategoryId,
                                                    "user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
                        self.Webservice_getCategorywiseItems(url: urlString, params:params)
                    }
                }
            }
        }
    }
    @objc func btnTap_Favorites(sender:UIButton!) {
        print("Button tapped")
        if UserDefaultManager.getStringFromUserDefaults(key: UD_isSkip) == "1"
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
extension HomeVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.Tableview_ProductList.bounds.size.width, height: self.Tableview_ProductList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
        messageLabel.sizeToFit()
        self.Tableview_ProductList.backgroundView = messageLabel;
        if self.categoryWiseItemsArray.count == 0 {
            messageLabel.text = "NO DATA FOUND".localiz()
        }
        else {
            messageLabel.text = ""
        }
        return categoryWiseItemsArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.Tableview_ProductList.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductCell
        cornerRadius(viewName: cell.img_Product, radius: 6.0)
        cornerRadius(viewName: cell.btn_Favorite, radius: 6.0)
        cornerRadius(viewName: cell.lbl_itemsPrice, radius: 4.0)
        let data = self.categoryWiseItemsArray[indexPath.row]
        let imgUrl = data["product_image"]!
        
        cell.img_Product.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "placeholder_image"))
        cell.lbl_itemsName.text = data["item_name"]!
        let ItemPrice = formatter.string(for: data["item_price"]!.toDouble)
        cell.lbl_itemsPrice.text = " \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPrice!) "
        cell.btn_Favorite.tag = indexPath.row
        cell.btn_Favorite.addTarget(self, action:#selector(btnTap_Favorite), for: .touchUpInside)
        if data["isFavorite"]! == "0" {
            cell.btn_Favorite.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        else {
            cell.btn_Favorite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.categoryWiseItemsArray[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(identifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.itemsId = data["id"]!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.item == self.categoryWiseItemsArray.count - 1 {
            if self.pageIndex != self.lastIndex {
                self.pageIndex = self.pageIndex + 1
                if self.categoryArray.count != 0
                {
                    let urlString = API_URL + "item?page=\(self.pageIndex)"
                    let params: NSDictionary = ["cat_id":SelectedCategoryId,
                                                "user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
                    self.Webservice_getCategorywiseItems(url: urlString, params:params)
                }
            }
        }
    }
    @objc func btnTap_Favorite(sender:UIButton!) {
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
extension HomeVC
{
    func Webservice_getCategory(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "GET", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let categoryData = jsonResponse!["data"].arrayValue
                    self.categoryArray = categoryData
                    self.Collectioview_categoriesList.delegate = self
                    self.Collectioview_categoriesList.dataSource = self
                    self.Collectioview_categoriesList.reloadData()
                    if self.categoryArray.count != 0
                    {
                        self.SelectedCategoryId = self.categoryArray[0]["id"].stringValue
                        let urlString = API_URL + "item"
                        let params: NSDictionary = ["cat_id":self.SelectedCategoryId,
                                                    "user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
                        self.Webservice_getCategorywiseItems(url: urlString, params:params)
                    }
                    let urlString = API_URL + "banner"
                    self.Webservice_getBanner(url: urlString, params: [:])
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    func Webservice_getBanner(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "GET", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].arrayValue
                    self.BannerArray = responseData
                    self.Collectioview_PromotionBanner.delegate = self
                    self.Collectioview_PromotionBanner.dataSource = self
                    self.Collectioview_PromotionBanner.reloadData()
                    if self.BannerArray.count == 0
                    {
                        self.collectionview_BannerHeight.constant = 0.0
                        self.Collectioview_PromotionBanner.isHidden = true
                    }
                    else{
                        self.collectionview_BannerHeight.constant = 150.0
                        self.Collectioview_PromotionBanner.isHidden = false
                    }
                    
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    func Webservice_getCategorywiseItems(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    
                    let responcedata = jsonResponse!["data"].dictionaryValue
                    //                    let currency = jsonResponse!["currency"].dictionaryValue
                    UserDefaultManager.setStringToUserDefaults(value: jsonResponse!["currency"].stringValue, key: UD_currency)
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
                    self.Tableview_ProductList.delegate = self
                    self.Tableview_ProductList.dataSource = self
                    self.Tableview_ProductList.reloadData()
                    
                    self.collectioView_GirdList.delegate = self
                    self.collectioView_GirdList.dataSource = self
                    self.collectioView_GirdList.reloadData()
                    
                    self.Collectioview_categoriesList.delegate = self
                    self.Collectioview_categoriesList.dataSource = self
                    self.Collectioview_categoriesList.reloadData()
                    
                    if UserDefaultManager.getStringFromUserDefaults(key: UD_userId) != ""
                    {
                        let urlString = API_URL + "cartcount"
                        let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
                        self.Webservice_cartcount(url: urlString, params:params)
                    }
                    
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
                    
                    self.Tableview_ProductList.delegate = self
                    self.Tableview_ProductList.dataSource = self
                    self.Tableview_ProductList.reloadData()
                    
                    self.collectioView_GirdList.delegate = self
                    self.collectioView_GirdList.dataSource = self
                    self.collectioView_GirdList.reloadData()
                    
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    func Webservice_cartcount(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    self.lbl_Cartcount.isHidden = false
                    self.lbl_Cartcount.text = jsonResponse!["cart"].stringValue
                }
                else {
                    self.lbl_Cartcount.isHidden = false
                    self.lbl_Cartcount.text = "0"
                    //                           showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    func Webservice_getrestaurantslocation(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "GET", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["data"].dictionaryValue
                    self.latitued = responseData["lat"]!.stringValue
                    self.longitude = responseData["lang"]!.stringValue
                    self.openMapForPlace()
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
}
extension HomeVC {
    func addViewDynamically(subview : UIView)
    {
        subview.translatesAutoresizingMaskIntoConstraints = false;
        self.Main_View.addSubview(subview)
        self.Main_View.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.Main_View, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
        self.Main_View.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.Main_View, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
        self.Main_View.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.Main_View, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))
        self.Main_View.addConstraint(NSLayoutConstraint(item: subview
            , attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.Main_View, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
        self.Main_View.layoutIfNeeded()
    }
}
extension String {
    var toDouble: Double {
        return Double(self) ?? 0.00
    }
}
