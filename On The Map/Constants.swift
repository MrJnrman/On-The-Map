//
//  Constants.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/7/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import Foundation

struct ResponseCodes {
    static let Ok = "200"
    static let BadCredentials = "403"
}

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
    static let ApiHost = "www.udacity.com"
    static let ApiPath = "/api"
    static let SessionPath = "/session"
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

struct AlertViewConstants {
    static let Title = "Oops!"
    static let TryAgain = "Try Again"
    static let LoginError = "Error Loggin In"
    static let Request403 = "Invalid Credentials"
    static let MissingCredentials = "Missing Credentials"
    static let Ok = "Ok"
    static let PinCancel = "Cancel"
    static let PinSave = "Save"
    static let RequestTimedOut = "Request Timed Out"
}

struct JSONResponseKeys {
    static let Account = "account"
    static let AccountKey = "key"
    static let Session = "session"
    static let SessionId = "id"
    static let Results = "results"
    static let FirstName = "first_name"
    static let LastName = "last_name"
    static let User = "user"
}

struct ParameterKeys {
    static let Limit = "limit"
    static let Order = "order"
}

struct ParameterValues {
    static let Limit = "100"
    static let Ascending = "updatedAt"
    static let Descending = "-updatedAt"
}

enum API {
    case udacity
    case parse
}
