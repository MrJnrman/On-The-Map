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
    var mapString: String?
    var uniqueKey: String!
    
    
    init() {
        
    }
    
    init(_ results: [String:AnyObject]) {
        self.firstName = results["firstName"] as! String
        self.lastName = results["lastName"] as! String
        self.mediaURL = results["mediaURL"] as! String
        self.latitude = results["latitude"] as! Double
        self.longitude = results["longitude"] as! Double
        self.uniqueKey = results["uniqueKey"] as! String
        self.mapString = results["mapString"] as? String
        
    }
    
    mutating func build(_ results: AnyObject) -> [StudentLocation] {
        
        var studentLocations = [StudentLocation]()
        
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
            
            guard let _ = dictionary["uniqueKey"] as? String else {
                continue
            }
            
            let studentLocation = StudentLocation(dictionary)
            
            
            studentLocations.append(studentLocation)
        }
        
        return studentLocations

    }
    
    func getName() -> String {
        return "\(self.firstName!) \(self.lastName!)"
    }
    
    func buildJSONBody(mediaURL: String, lat: Double, long: Double) -> String{
        var jsonBody = HttpBody.LocationBody
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.uniqueKey, with: Account.shared.userId!)
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.LastName, with: Account.shared.lastName!)
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.FirstName, with: Account.shared.firstName!)
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.MapString, with: "")
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.Latitude, with: "\(lat)")
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.Longitude, with: "\(long)")
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.MediaURL, with: mediaURL)
        
        return jsonBody
    }
}
