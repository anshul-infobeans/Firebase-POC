//
//  Channel.swift
//  Firebase_RTC
//
//  Created by Anshul Saraf on 13/09/17.
//  Copyright © 2017 InfoBeans Technologies Limited. All rights reserved.
//

import UIKit

class Channel: NSObject {
    //  MARK:-  Properties
    var id: String?
    var name: String?
    
    //  MARK:-  Class Methods
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
