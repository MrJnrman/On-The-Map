//
//  LoginViewController.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/7/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func loginButtonPressed(_ sender: Any) {
        login()
    }
    
    func login() {
        
        guard (emailTextField.text != ""), (passwordTextField.text != "") else {
            showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.MissingCredentials, buttonText: AlertViewConstants.Ok)
            return
        }
        
        let jsonBody = HttpManager.shared.buildAuthenticationHttpBody(username: emailTextField.text!, password: passwordTextField.text!)
        
        print("HttpBody: \(jsonBody)" )
        
        _ = HttpManager.shared.taskForPOSTRequest(UdacityConstants.SessionPath, parameters: nil, api: API.udacity, jsonBody: jsonBody) { (results,error) in
            
            if error != nil {
                performUIUpdatesOnMain {
                    print(error!.localizedDescription)
                    if error!.localizedDescription == ResponseCodes.BadCredentials {
                        self.showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.Request403, buttonText:AlertViewConstants.TryAgain)
                    }
                }
            } else {
                if self.getLoginData(results!) {
                    self.getPublicData(Account.shared.userId!) { (username) in
                        performUIUpdatesOnMain {
                            guard (username != nil) else {
                                self.showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.Request403, buttonText: AlertViewConstants.TryAgain)
                                return
                            }
                            
                            // add username to Account struct and transition to enxt view
                            Account.shared.username = username
                            self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                        }
                    }
                } else {
                    performUIUpdatesOnMain {
                        self.showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.LoginError, buttonText: AlertViewConstants.TryAgain)
                    }
                }
                    
            }
        }
    }
    
    func showAlertView(title: String, message: String, buttonText: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: title, style: .destructive, handler: nil)
        alertController.addAction(action)

        self.present(alertController, animated: true, completion: nil)
    }
    
    func getLoginData(_ results: AnyObject) -> Bool {
        let success = true
        guard let account = results[JSONResponseKeys.Account] as? [String:AnyObject] else {
            return !success
        }
        
        guard let session = results[JSONResponseKeys.Session] as? [String:AnyObject] else {
            return !success
        }
        
        guard let accountId = account[JSONResponseKeys.AccountKey] as? String else {
            return !success
        }
        
        guard let sessionId = session[JSONResponseKeys.SessionId] as? String else {
            return !success
        }
        
        Account.shared.sessionID = sessionId
        Account.shared.userId = accountId
        
        return success
    }
    
    func getPublicData(_ accountId: String, completionHandler: @escaping (_ username: String?) -> Void) {
        
        let method = Methods.UdacityUser.replacingOccurrences(of: "<user_id>", with: accountId)
        
        _ = HttpManager.shared.taskForGETRequest(method, parameters: nil, api: .udacity) { (results,error) in
//            print(results)
            guard let user = results?[JSONResponseKeys.User] as? [String:AnyObject] else {
                completionHandler(nil)
                return
            }
            guard let firstName = user[JSONResponseKeys.FirstName] as? String else {
                completionHandler(nil)
                return
            }
            
            guard let lastName = user[JSONResponseKeys.LastName] as? String else {
                completionHandler(nil)
                return
            }
            
            completionHandler("\(firstName) \(lastName)")
        }
    }
}

