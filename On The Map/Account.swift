//
//  SessionID.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/7/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import Foundation

struct Account {
    static var shared = Account()
    
    var sessionID: String?
    var userId: String?
    var firstName: String?
    var lastName: String?
    
    func getFullName() -> String {
        return "\(firstName!) \(lastName!)"
    }
}
