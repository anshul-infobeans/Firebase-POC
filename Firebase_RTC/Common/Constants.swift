//
//  Constants.swift
//  Firebase_RTC
//
//  Created by Anshul Saraf on 11/09/17.
//  Copyright © 2017 InfoBeans Technologies Limited. All rights reserved.
//

import Foundation
import UIKit

//  MARK:-  Segue Identifiers
let loginSuccessSegueID = "LoginSuccess"

//  MARK:-  Structs
struct AppColors {
    static let globalBackgroundColor = UIColor(red: 255/255, green: 202/255, blue: 40/255, alpha: 1.0)
    static let blueTextColor = UIColor(red: 0/255, green: 64/255, blue: 128/255, alpha: 1.0)
}

struct AlertMessages {
    static let enterEmailIDMessage = "Please enter your email id"
    static let enterEmailIDValidFormatMessage = "Please enter email id in valid format"
    static let enterPasswordMessage = "Please enter your password"
    static let fetchingChannelsMessage = "Fetching available channels..."
    static let noChannelsMessage = "This account has no channels available"
    static let invalidChannelNameMessage = "This channel name is invalid"
    static let channelAddedMessage = "New channel has been added"
}

struct HUDMessages {
    static let connectingMessage = "Connecting, please wait..."
    static let loginSuccessMessage = "Login successful!"
}

struct FirebaseMessages {
    static let userNotFoundMessage = "This email id is not registered with us"
    static let wrongPasswordMessage = "Password is incorrect, please try again"
}
