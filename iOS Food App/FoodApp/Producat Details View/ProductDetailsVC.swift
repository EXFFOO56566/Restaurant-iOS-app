//
//  ProductDetailsVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 04/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import ImageSlideshow
import SwiftyJSON
class AddonseCell: UITableViewCell {
    
    @IBOutlet weak var btn_Close: UIButton!
    @IBOutlet weak var btn_Check: UIButton!
    @IBOutlet weak var lbl_Price: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    
}
class IngredientsCell: UICollectionViewCell {
    
    @IBOutlet weak var cell_view: UIView!
    @IBOutlet weak var img_Ingredients: UIImageView!
}
class ProductDetailsVC: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var text_view: UITextView!
    @IBOutlet weak var Addons_Height: NSLayoutConstraint!
    @IBOutlet weak var TableView_AddonsList: UITableView!
    
    @IBOutlet weak var btn_back: UIButton!
    @IBOutlet weak var btn_Cart: UIButton!
    @IBOutlet weak var CollectionView_IngredientsList: UICollectionView!
    @IBOutlet weak var btn_Addtocart: UIButton!
    @IBOutlet weak var image_Slider: ImageSlideshow!
    
    @IBOutlet weak var lbl_itemsName: UILabel!
    @IBOutlet weak var lbl_CategoriesName: UILabel!
    @IBOutlet weak var lbl_itemsPrice: UILabel!
    @IBOutlet weak var lbl_itemsDescripation: UILabel!
    
    @IBOutlet weak var lbl_itemTime: UILabel!
    
    @IBOutlet weak var lbl_IngredientsLavel: UILabel!
    @IBOutlet weak var lbl_DetailsLabel: UILabel!
    var itemsId = String()
    var itesmingredientsData = [JSON]()
    var productImages = [SDWebImageSource]()
    var addonsArray = [[String:String]]()
    var SelectedAddons = [[String:String]]()
    var FinalTotal = Double()

    @IBOutlet weak var lbl_count: UILabel!
    @IBOutlet weak var btn_Minus: UIButton!
    @IBOutlet weak var btn_Pluse: UIButton!
    @IBOutlet weak var lbl_Cartcount: UILabel!
    @IBOutlet weak var item_UnavailableView: UIView!
    @IBOutlet weak var UnavailableView_Height: NSLayoutConstraint!
    
    let cartStr = "Add To Cart".localiz()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.item_UnavailableView.isHidden = true
        self.lbl_DetailsLabel.text = "Details".localiz()
        self.lbl_IngredientsLavel.text = "Ingredients".localiz()
        self.btn_Addtocart.setTitle(cartStr, for: .normal)
        let urlString = API_URL + "itemdetails"
        let params: NSDictionary = ["item_id":self.itemsId]
        self.Webservice_getitemsDetails(url: urlString, params:params)
        cornerRadius(viewName: self.btn_Cart, radius: 8.0)
        cornerRadius(viewName: self.btn_back, radius: 8.0)
        cornerRadius(viewName: self.btn_Addtocart, radius: 6.0)
        cornerRadius(viewName: self.text_view, radius: 6.0)
        cornerRadius(viewName: self.lbl_Cartcount, radius: self.lbl_Cartcount.frame.height / 2)
        self.productImages.removeAll()
        
        self.text_view.text = "Write Notes".localiz()
        self.text_view.textColor = UIColor.lightGray
        self.text_view.delegate = self
        self.lbl_count.text! = "1"
    }
    override func viewWillAppear(_ animated: Bool) {
        let urlString = API_URL + "cartcount"
        let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
        self.Webservice_cartcount(url: urlString, params:params)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write Notes".localiz()
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func btnTap_back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTap_AddtoCart(_ sender: UIButton) {
        if UserDefaultManager.getStringFromUserDefaults(key: UD_isSkip) == "1"
        {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let objVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let nav : UINavigationController = UINavigationController(rootViewController: objVC)
            nav.navigationBar.isHidden = true
            UIApplication.shared.windows[0].rootViewController = nav
        }
        else{
            if self.text_view.text == "Write Notes".localiz()
            {
                self.text_view.text = ""
            }
            
            var AddoncId = [String]()
            for data in self.SelectedAddons
            {
                AddoncId.append(data["id"]!)
            }
            
            let ItemPriceTotal = formatter.string(for: FinalTotal)
            let urlString = API_URL + "cart"
            let params: NSDictionary = ["item_id":self.itemsId,"qty":self.lbl_count.text!,"price":"\(ItemPriceTotal!)","user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId),"addons_id":AddoncId.joined(separator: ","),"item_notes":self.text_view.text!]
            self.Webservice_AddtoCart(url: urlString, params:params)
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
    @IBAction func btnTap_AddOns(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "AddOnsVC") as! AddOnsVC
        vc.delegate = self
        vc.addonsArray = self.addonsArray
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnTap_Pluse(_ sender: UIButton) {
        let CountPluse  = AFWrapperClass.compareStringValue(currentValue:self.lbl_count.text!, limit: 99, toDo: .Add)
        print(CountPluse)
        self.lbl_count.text = CountPluse
        
        var Prices = [Double]()
        for data in self.SelectedAddons
        {
            Prices.append(Double("\(data["price"]!)")!)
        }
        print(Prices)
        let total = Prices.reduce(0, +)
        let SetTotal = self.lbl_itemsPrice.text!.dropFirst().replacingOccurrences(of: " ", with: "")
        let Total = Double(SetTotal)! + total
        let Qtyvalue = self.lbl_count.text!
        self.FinalTotal = ((Double(Qtyvalue)!) * Double(Total))
        print(FinalTotal)
        let ItemPriceTotal = formatter.string(for: FinalTotal)
        self.btn_Addtocart.setTitle("\(cartStr) \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPriceTotal!)".localiz(), for: .normal)
        
    }
    @IBAction func btnTap_Minus(_ sender: UIButton) {
        let CountMinus  = AFWrapperClass.compareStringValue(currentValue:self.lbl_count.text!, limit: 99, toDo: .Subtract)
        self.lbl_count.text = CountMinus
        
        print(CountMinus)
        
        var Prices = [Double]()
        for data in self.SelectedAddons
        {
            Prices.append(Double("\(data["price"]!)")!)
            
        }
        print(Prices)
        let total = Prices.reduce(0, +)
        let SetTotal = self.lbl_itemsPrice.text!.dropFirst().replacingOccurrences(of: " ", with: "")
        let Total = Double(SetTotal)! + total
        let Qtyvalue = self.lbl_count.text!
        self.FinalTotal = ((Double(Qtyvalue)!) * Double(Total))
        print(FinalTotal)
        let ItemPriceTotal = formatter.string(for: FinalTotal)
        self.btn_Addtocart.setTitle("\(cartStr) \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPriceTotal!)".localiz(), for: .normal)
    }
}

extension ProductDetailsVC {
    func imageSliderData() {
        self.image_Slider.slideshowInterval = 3.0
        self.image_Slider.pageIndicatorPosition = .init(horizontal: .center, vertical: .customBottom(padding: 10.0))
        self.image_Slider.contentScaleMode = UIView.ContentMode.scaleAspectFill
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.image_Slider.pageIndicator = pageControl
        self.image_Slider.setImageInputs(self.productImages)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
        self.image_Slider.addGestureRecognizer(recognizer)
    }
    
    @objc func didTapImage() {
        self.image_Slider.presentFullScreenController(from: self)
    }
}
extension ProductDetailsVC: AddOnsDelegate {
    
    func refreshData(AddonsArray: [[String : String]]) {
        print(AddonsArray)
        self.SelectedAddons.removeAll()
        for data in AddonsArray
        {
            if data["isselected"]! == "1"
            {
                self.SelectedAddons.append(data)
            }
        }
        print(self.SelectedAddons)
        if SelectedAddons.count != 0
        {
            self.Addons_Height.constant = CGFloat(80 * self.SelectedAddons.count)
            self.lbl_count.text = "1"
            let SetTotal = self.lbl_itemsPrice.text!.dropFirst().replacingOccurrences(of: " ", with: "")
            self.FinalTotal = Double(SetTotal)!
            let ItemPriceTotal = formatter.string(for: FinalTotal)
            self.btn_Addtocart.setTitle("\(cartStr) \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPriceTotal!)".localiz(), for: .normal)
        }
        else{
            self.Addons_Height.constant = 80.0
            self.lbl_count.text = "1"
            let SetTotal = self.lbl_itemsPrice.text!.dropFirst().replacingOccurrences(of: " ", with: "")
            self.FinalTotal = Double(SetTotal)!
            let ItemPriceTotal = formatter.string(for: FinalTotal)
            self.btn_Addtocart.setTitle("\(cartStr) \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPriceTotal!)".localiz(), for: .normal)
        }
        
        self.TableView_AddonsList.delegate = self
        self.TableView_AddonsList.dataSource = self
        self.TableView_AddonsList.reloadData()
        
        var Prices = [Double]()
        for data in self.SelectedAddons
        {
            Prices.append(Double("\(data["price"]!)")!)
        }
        print(Prices)
        let total = Prices.reduce(0, +)
        let SetTotal = self.lbl_itemsPrice.text!.dropFirst().replacingOccurrences(of: " ", with: "")
        let Total = Double(SetTotal)! + total
        let Qtyvalue = self.lbl_count.text!
        self.FinalTotal = ((Double(Qtyvalue)!) * Double(Total))
        let ItemPriceTotal = formatter.string(for: FinalTotal)
        self.btn_Addtocart.setTitle("\(cartStr) \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPriceTotal!)".localiz(), for: .normal)
        
    }
    
}
extension ProductDetailsVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.CollectionView_IngredientsList.bounds.size.width, height: self.CollectionView_IngredientsList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
        messageLabel.sizeToFit()
        self.CollectionView_IngredientsList.backgroundView = messageLabel;
        if self.itesmingredientsData.count == 0 {
            messageLabel.text = "NO INGREDIENTS"
        }
        else {
            messageLabel.text = ""
        }
        return itesmingredientsData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.CollectionView_IngredientsList.dequeueReusableCell(withReuseIdentifier: "IngredientsCell", for: indexPath) as! IngredientsCell
        cornerRadius(viewName: cell.cell_view, radius: 8.0)
        let data = self.itesmingredientsData[indexPath.item]
        let imgUrl  = data["ingredients_image"].stringValue
        
        cell.img_Ingredients.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "placeholder_image"))
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 20.0) / 3, height: 100.0)
    }
    
}
extension ProductDetailsVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.TableView_AddonsList.bounds.size.width, height: self.TableView_AddonsList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
        messageLabel.sizeToFit()
        self.TableView_AddonsList.backgroundView = messageLabel;
        if self.SelectedAddons.count == 0 {
            messageLabel.text = "NO ADD-ONS"
        }
        else {
            messageLabel.text = ""
        }
        return SelectedAddons.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.TableView_AddonsList.dequeueReusableCell(withIdentifier: "AddonseCell") as! AddonseCell
        let data = self.SelectedAddons[indexPath.row]
        cell.lbl_Title.text = data["name"]!
        
        let ItemPrice = formatter.string(for: data["price"]!.toDouble)
        if ItemPrice == "0.00" ||  ItemPrice == "0.0" || ItemPrice == "0" || ItemPrice == ""
        {
            cell.lbl_Price.text = "Free"
        }
        else{
           cell.lbl_Price.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPrice!)"
        }
        
        cell.btn_Close.tag = indexPath.row
        cell.btn_Close.addTarget(self, action: #selector(btnTap_Cose), for: .touchUpInside)
        return cell
        
    }
    @objc func btnTap_Cose(sender:UIButton)
    {
        self.SelectedAddons.remove(at: sender.tag)
        if SelectedAddons.count != 0
        {
            self.Addons_Height.constant = CGFloat(80 * self.SelectedAddons.count)
            var Prices = [Double]()
            for data in self.SelectedAddons
            {
                Prices.append(Double("\(data["price"]!)")!)
            }
            print(Prices)
            let total = Prices.reduce(0, +)
            let SetTotal = self.lbl_itemsPrice.text!.dropFirst().replacingOccurrences(of: " ", with: "")
            let Total = Double(SetTotal)! + total
            let Qtyvalue = self.lbl_count.text!
            self.FinalTotal = ((Double(Qtyvalue)!) * Double(Total))
            let ItemPriceTotal = formatter.string(for: FinalTotal)
            self.btn_Addtocart.setTitle("\(cartStr) \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPriceTotal!)".localiz(), for: .normal)
        }
        else
        {
            self.Addons_Height.constant = 80.0
            var Prices = [Double]()
            for data in self.SelectedAddons
            {
                Prices.append(Double("\(data["price"]!)")!)
            }
            print(Prices)
            let total = Prices.reduce(0, +)
            let SetTotal = self.lbl_itemsPrice.text!.dropFirst().replacingOccurrences(of: " ", with: "")
            let Total = Double(SetTotal)! + total
            let Qtyvalue = self.lbl_count.text!
            self.FinalTotal = ((Double(Qtyvalue)!) * Double(Total))
            let ItemPriceTotal = formatter.string(for: FinalTotal)
            self.btn_Addtocart.setTitle("\(cartStr) \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPriceTotal!)".localiz(), for: .normal)
        }
        self.TableView_AddonsList.delegate = self
        self.TableView_AddonsList.dataSource = self
        self.TableView_AddonsList.reloadData()
    }
}
extension ProductDetailsVC
{
    func Webservice_getitemsDetails(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let itemsData = jsonResponse!["data"].dictionaryValue
                    let productImages = itemsData["images"]!.arrayValue
                    self.productImages.removeAll()
                    for image in productImages {
                        print(image["itemimage"].stringValue)
                        let imageSource = SDWebImageSource(url: URL(string: image["itemimage"].stringValue)!, placeholder: UIImage(named: "placeholder_image"))
                        print(imageSource)
                        self.productImages.append(imageSource)
                    }
                    let item_status = itemsData["item_status"]!.stringValue
                    if item_status == "2"
                    {
                        self.item_UnavailableView.isHidden = false
                        self.UnavailableView_Height.constant = 50.0
                    }
                    else{
                        self.item_UnavailableView.isHidden = true
                        
                    }
                    self.imageSliderData()
                    let ItemPrice = formatter.string(for: itemsData["item_price"]!.stringValue.toDouble)
                    self.lbl_itemsPrice.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPrice!)"
                    let SetTotal = self.lbl_itemsPrice.text!.dropFirst().replacingOccurrences(of: " ", with: "")
                    self.FinalTotal = Double(SetTotal)!
                    let ItemPriceTotal = formatter.string(for: self.FinalTotal)
                    self.btn_Addtocart.setTitle("\(self.cartStr) \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPriceTotal!)", for: .normal)
                    self.lbl_itemsDescripation.text = itemsData["item_description"]!.stringValue
                    self.lbl_CategoriesName.text = itemsData["category_name"]!.stringValue
                    self.lbl_itemsName.text = itemsData["item_name"]!.stringValue
                    self.lbl_itemTime.text = itemsData["delivery_time"]!.stringValue
                    self.itesmingredientsData = itemsData["ingredients"]!.arrayValue
                    let datas = itemsData["addons"]!.arrayValue
                    for data in datas
                    {
                        let ItemPrice = formatter.string(for: data["price"].stringValue.toDouble)
                        let obj = ["price":ItemPrice!,"item_id":data["item_id"].stringValue,"name":data["name"].stringValue,"id":data["id"].stringValue,"isselected":"0"]
                        self.addonsArray.append(obj)
                    }
                    print(self.addonsArray)
                    self.CollectionView_IngredientsList.delegate = self
                    self.CollectionView_IngredientsList.dataSource = self
                    self.CollectionView_IngredientsList.reloadData()
                    self.Addons_Height.constant = 80 * 1
                    let urlString = API_URL + "cartcount"
                    let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
                    self.Webservice_cartcount(url: urlString, params:params)
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    func Webservice_AddtoCart(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["status"].stringValue
                if responseCode == "1" {
                    let responceData = jsonResponse!["data"].dictionaryValue
                    
                    //                    let vc = self.storyboard?.instantiateViewController(identifier: "AddtoCartVC") as! AddtoCartVC
                    //                    self.navigationController?.pushViewController(vc, animated:true)
                    self.SelectedAddons.removeAll()
                    self.text_view.text = ""
                    self.TableView_AddonsList.reloadData()
                    self.Addons_Height.constant = 80.0
                    self.lbl_count.text = "1"
                    let SetTotal = self.lbl_itemsPrice.text!.dropFirst().replacingOccurrences(of: " ", with: "")
                    self.FinalTotal = Double(SetTotal)!
                    let ItemPriceTotal = formatter.string(for: self.FinalTotal)
                    self.btn_Addtocart.setTitle("\(self.cartStr) \(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPriceTotal!)", for: .normal)
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                    let urlString = API_URL + "cartcount"
                    let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId)]
                    self.Webservice_cartcount(url: urlString, params:params)
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
                    //                        showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                }
            }
        }
    }
    
}
enum mathFunction {
    /// When Addition is to done
    case Add
    /// When Subtraction is to be Done
    case Subtract
}

class AFWrapperClass : NSObject {
    //MARK: Fucntion used to comapre and update value
    /**
     This function is used to update stepper values
     - parameter currentValue : Current Value in Array
     - parameter limit : Maximum Value that can be used as stepper+1
     - parameter toDo : tells need to perform Add or subtract
     */
    class func compareStringValue(currentValue:String, limit:Int, toDo : mathFunction) -> String {
        var current : Int = Int(currentValue)!
        if (current <= limit) && (current >= 0) {
            if toDo == .Add {
                if current == limit {
                    return String(current)
                }
                else{
                    current += 1
                    return String(current)
                }
            }
            else {
                if current == 1 {
                    return String(current)
                }
                else {
                    current -= 1
                    return String(current)
                }
            }
        }
        else {
            return String(current)
        }
    }
}
