//
//  SessionID.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/7/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import Foundation

struct SessionID {
    static let shared = SessionID()
    
    var sessionID: String?
}
