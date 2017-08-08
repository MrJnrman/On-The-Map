//
//  StudentLocation.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/8/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import Foundation

struct StudentLocation {
    static var shared = StudentLocation()
    
    var firstName: String!
    var lastName: String!
    var mediaURL: String!
    var latitude: Double!
    var longitude: Double!
    var studentLocations = [StudentLocation]()
    
    init() {
        
    }
    
    init(_ results: [String:AnyObject]) {
        self.firstName = results["firstName"] as! String
        self.lastName = results["lastName"] as! String
        self.mediaURL = results["mediaURL"] as! String
        self.latitude = results["latitude"] as! Double
        self.longitude = results["longitude"] as! Double
        
    }
    
    mutating func build(_ results: AnyObject) -> [StudentLocation] {
        
        for dictionary in results[JSONResponseKeys.Results] as! [[String:AnyObject]] {
            
            guard let _ = dictionary["latitude"] as? Double, let _ = dictionary["longitude"] as? Double else {
                continue
            }
            
            guard let _ = dictionary["firstName"] as? String, let _ = dictionary["lastName"] as? String else {
                continue
            }
            
            guard (dictionary["mediaURL"] as? String) != nil else{
                continue
            }
            
            let studentLocation = StudentLocation(dictionary)
            
            self.studentLocations.append(studentLocation)
        }
        
        return studentLocations

    }
    
    func getName() -> String {
        return "\(self.firstName!) \(self.lastName!)"
    }
}
