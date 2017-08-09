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
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotificaiton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotification()
    }
    
    // Setup subscription to keybord events(show/hide)
    func subscribeToKeyboardNotificaiton(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    // unsubscribe from keyboard events
    func unsubscribeFromKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // offset view by the height of the keyboard
    func keyboardWillShow(_ notification: Notification) {
        
        // check if view has already been repositioned
        // check if top textfield is currently being edited
        if view.frame.origin.y == 0 {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
    }
    
    // return the position of the view to normal
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height / 2
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        login()
    }
    
    func showActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(self.activityIndicator)
        
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func login() {
        
        self.showActivityIndicator()
        
        guard (emailTextField.text != ""), (passwordTextField.text != "") else {
            self.hideActivityIndicator()
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
                        self.hideActivityIndicator()
                        self.showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.Request403, buttonText:AlertViewConstants.TryAgain)
                    }
                    
                    if error!.code == NSURLErrorTimedOut {
                        self.hideActivityIndicator()
                        self.showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.RequestTimedOut, buttonText: AlertViewConstants.Ok)
                    }
                }
            } else {
                if self.getLoginData(results!) {
                    self.getPublicData(Account.shared.userId!) { (firstName, lastName) in
                        performUIUpdatesOnMain {
                            guard (firstName != nil) else {
                                self.hideActivityIndicator()
                                self.showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.Request403, buttonText: AlertViewConstants.TryAgain)
                                return
                            }
                            
                            self.hideActivityIndicator()
                            
                            // add username to Account struct and transition to enxt view
                            Account.shared.firstName = firstName
                            Account.shared.lastName = lastName
                            self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                        }
                    }
                } else {
                    performUIUpdatesOnMain {
                        self.hideActivityIndicator()
                        self.showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.LoginError, buttonText: AlertViewConstants.TryAgain)
                    }
                }
                    
            }
        }
    }
    
    func showAlertView(title: String, message: String, buttonText: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: buttonText, style: .destructive, handler: nil)
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
    
    func getPublicData(_ accountId: String, completionHandler: @escaping (_ firstName: String?,_ lastName: String?) -> Void) {
        
        let method = Methods.UdacityUser.replacingOccurrences(of: "<user_id>", with: accountId)
        
        _ = HttpManager.shared.taskForGETRequest(method, parameters: nil, api: .udacity) { (results,error) in
            guard let user = results?[JSONResponseKeys.User] as? [String:AnyObject] else {
                completionHandler(nil, nil)
                return
            }
            guard let firstName = user[JSONResponseKeys.FirstName] as? String else {
                completionHandler(nil, nil)
                return
            }
            
            guard let lastName = user[JSONResponseKeys.LastName] as? String else {
                completionHandler(nil, nil)
                return
            }
            
            completionHandler(firstName, lastName)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

