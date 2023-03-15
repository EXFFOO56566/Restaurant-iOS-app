

import Foundation
import UIKit

//Mark:- View controller name

let ORENGE_COLOR = Color_RGBA(254, 114, 76, 1)
let BLCK_COLOR = Color_RGBA(31, 33, 36, 1)
let GRAY_COLOR = Color_RGBA(154, 154, 154, 1)

let API_URL = "YOUR_DOMAIN_URL/api/"
let Privacy_URL = "YOUR_DOMAIN_URL/privacy-policy"
let UD_userId = "UD_userId"
let UD_currency = "UD_currency"
let UD_isTutorial = "UD_isTutorial"
let UD_fcmToken = "UD_fcmToken"
let UD_isSkip = "UD_isSkip"
let UD_isSelectLng = "UD_isSelectLng"
let UD_SelectedLat = "UD_SelectedLat"
let UD_SelectedLng = "UD_SelectedLng"
let MESSAGE_ERR_NETWORK = "No internet connection. Try again.."

var formatter = NumberFormatter()
func setDecimalNumber()
{
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    formatter.locale = Locale(identifier: "en_US")
    
}


enum HttpResponseStatusCode: Int {
    case ok = 200
    case badRequest = 400
    case noAuthorization = 401
}
extension Bundle {
    var displayName: String? {
        return infoDictionary?["CFBundleName"] as? String
    }
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
