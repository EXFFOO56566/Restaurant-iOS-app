//
//  WriteReviewVC.swift
//  FoodApp
//
//  Created by Mitesh's MAC on 15/06/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol WriteReviewVCDelegate {
    func refreshData()
}

class WriteReviewVC: UIViewController {
    
    @IBOutlet weak var text_view: UITextView!
    @IBOutlet weak var btn_Submit: UIButton!
    @IBOutlet weak var view_ratings: FloatRatingView!
    var delegate: WriteReviewVCDelegate!
    var liveStr = String()
    
    
    @IBOutlet weak var lbl_Titlelabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_Titlelabel.text = "Ratings".localiz()
        self.btn_Submit.setTitle("Submit".localiz(), for: .normal)
        
        self.view_ratings.delegate = self
        cornerRadius(viewName: self.btn_Submit, radius: 8)
        cornerRadius(viewName: self.text_view, radius: 6)
        self.text_view.delegate = self
    }
    
    @IBAction func btn_close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnTap_Submit(_ sender: UIButton) {
        if self.text_view.text! == "" || self.text_view.text! == "Enter your review".localiz() {
            showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: "Please enter all details")
        }
        else {
            let urlString = API_URL + "ratting"
            let params: NSDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: UD_userId),
                                        "ratting":self.liveStr,
                                        "comment":self.text_view.text!]
            self.Webservice_WriteReview(url: urlString, params: params)
        }
    }
}
extension WriteReviewVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.text_view.text! == "Enter your review".localiz() {
            self.text_view.text = ""
        }
    }
}
// MARK Rating Views
extension WriteReviewVC: FloatRatingViewDelegate {
    // MARK: FloatRatingViewDelegate
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        liveStr = String(format: "%.f", self.view_ratings.rating)
        print(liveStr)
    }
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        _ = String(format: "%.2f", self.view_ratings.rating)
        //print(updatedStr)
    }
}
//MARK: Webservices
extension WriteReviewVC
{
    func Webservice_WriteReview(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                let responseCode = jsonResponse!["status"].stringValue
                
                print(jsonResponse!)
                if responseCode == "1" {
                    self.dismiss(animated: true) {
                        self.delegate.refreshData()
                    }
                }
                else {
                    self.dismiss(animated: true) {
                       showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["message"].stringValue)
                    }
                    
                }
            }
        }
    }
}
