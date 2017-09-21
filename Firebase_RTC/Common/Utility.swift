//
//  Utility.swift
//  Firebase_RTC
//
//  Created by Anshul Saraf on 12/09/17.
//  Copyright © 2017 InfoBeans Technologies Limited. All rights reserved.
//

import UIKit
import JDropDownAlert

class Utility: NSObject {
    //  MARK:-  Class Methods
    class func isValidEmail(_ text:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
    }
    
    class func showAlertWith(title: String, message: String?) {
        let alert = JDropDownAlert()
        alert.alertWith(title, message: message, textColor: AppColors.globalBackgroundColor, backgroundColor: AppColors.blueTextColor)
    }
}
