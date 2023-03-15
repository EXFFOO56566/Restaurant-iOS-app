//
//  AddonceListVC.swift
//  FoodApp
//
//  Created by iMac on 21/07/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
class AddonceListVC: UIViewController {

    @IBOutlet weak var TableView_AddonsList: UITableView!
    var SelectedAddons = [JSON]()
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.SelectedAddons = [["name": "Sauce", "item_id": "1", "id": "1", "price": "20", "isselected": "1"], ["name": "Salad", "item_id": "1", "price": "0", "id": "2", "isselected": "1"]]
        self.TableView_AddonsList.delegate = self
        self.TableView_AddonsList.dataSource = self
        self.TableView_AddonsList.reloadData()
    }
    
    @IBAction func btnTap_close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension AddonceListVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.TableView_AddonsList.bounds.size.width, height: self.TableView_AddonsList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
        messageLabel.sizeToFit()
        self.TableView_AddonsList.backgroundView = messageLabel;
//        if self.addonsArray.count == 0 {
//            messageLabel.text = "NO DATA FOUND"
//        }
//        else {
//            messageLabel.text = ""
//        }
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
        let data = SelectedAddons[indexPath.row]
        let ItemPriceTotal = formatter.string(for: data["price"].stringValue.toDouble)
        
        if data["price"].stringValue == "0.00" ||  data["price"].stringValue == "0.0" || data["price"].stringValue == "0" || data["price"].stringValue == ""
        {
            cell.lbl_Price.text = "Free"
        }
        else{
            cell.lbl_Price.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(ItemPriceTotal!)"
        }
        cell.lbl_Title.text = data["name"].stringValue
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        self.delegate.refreshData()
    }
   
    
}
