//
//  StudentLocationDataSource.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/9/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import Foundation

class StudentDataSource {
    var studentData = [StudentLocation]()
    static let sharedInstance = StudentDataSource()
    private init() {} //This prevents others from using the default '()' initializer for this class.
}
