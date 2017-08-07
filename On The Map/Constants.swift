//
//  Constants.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/7/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import Foundation

struct Scheme {
    static let ApiScheme = "https"
}

struct ParseConstants {
    static let ParseAppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let ParseRestApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let ApiHost = "parse.udacity.com"
    static let ApiPath = "/parse/classes"
}

struct UdacityConstants {
    static let ApiHost = "www.udacity.com/api"
    static let AuthorizationURL = "www.udacity.com/api/session"
}

struct Methods {
    static let ParseStudentLocation = "/StudentLocation"
    
    static let UdacitySession = "/session"
    static let UdacityUser = "/users/<user_id>"
    
}

struct HTTPMethods {
    static let POST = "POST"
    static let GET = "GET"
}

struct HttpBody {
    static let AuthorizationBody = "{\"udacity\": {\"username\": \"<user-name>\", \"password\": \"<password>\"}}"
}

enum API {
    case udacity
    case parse
}
