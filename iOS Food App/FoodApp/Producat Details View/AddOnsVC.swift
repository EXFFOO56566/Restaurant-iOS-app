//
//  AddOnsVC.swift
//  FoodApp
//
//  Created by iMac on 01/08/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit

protocol AddOnsDelegate {
    func refreshData(AddonsArray : [[String:String]])
}

class AddOnsVC: UIViewController {
    
    @IBOutlet weak var TableView_AddonceList: UITableView!
    var delegate: AddOnsDelegate!
    var addonsArray = [[String:String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print(addonsArray)
        self.TableView_AddonceList.reloadData()
    }
    
    @IBAction func btnTap_Close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnTap_Done(_ sender: UIButton) {
        
        self.delegate.refreshData(AddonsArray: self.addonsArray)
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
extension AddOnsVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.TableView_AddonceList.bounds.size.width, height: self.TableView_AddonceList.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "POPPINS-REGULAR", size: 15)!
        messageLabel.sizeToFit()
        self.TableView_AddonceList.backgroundView = messageLabel;
        if self.addonsArray.count == 0 {
            messageLabel.text = "NO DATA FOUND"
        }
        else {
            messageLabel.text = ""
        }
        return addonsArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.TableView_AddonceList.dequeueReusableCell(withIdentifier: "AddonseCell") as! AddonseCell
        let data = addonsArray[indexPath.row]
        if data["price"]! == "0.00" ||  data["price"]! == "0.0" || data["price"]! == "0" || data["price"]! == ""
        {
            cell.lbl_Price.text = "Free"
        }
        else{
           cell.lbl_Price.text = "\(UserDefaultManager.getStringFromUserDefaults(key: UD_currency))\(data["price"]!)"
        }
        
        cell.lbl_Title.text = data["name"]!
        if data["isselected"] == "0"
        {
            cell.btn_Check.setImage(UIImage(systemName: "square"), for: .normal)
        }
        else{
            cell.btn_Check.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        }
        cell.btn_Check.tag = indexPath.row
        cell.btn_Check.addTarget(self, action: #selector(btnTap_Check), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        self.delegate.refreshData()
    }
    @objc func btnTap_Check(sender:UIButton)
    {
        let data = addonsArray[sender.tag]
        if data["isselected"] == "0"
        {
            let obj = ["price":data["price"]!,"item_id":data["item_id"]!,"name":data["name"]!,"id":data["id"]!,"isselected":"1"]
            
            self.addonsArray.remove(at: sender.tag)
            self.addonsArray.insert(obj, at: sender.tag)
            self.TableView_AddonceList.reloadData()
        }
        else{
            let obj = ["price":data["price"]!,"item_id":data["item_id"]!,"name":data["name"]!,"id":data["id"]!,"isselected":"0"]
            self.addonsArray.remove(at: sender.tag)
            self.addonsArray.insert(obj, at: sender.tag)
            self.TableView_AddonceList.reloadData()
        }
        
    }
    
}

