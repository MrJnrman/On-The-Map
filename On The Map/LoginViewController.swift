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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        guard (emailTextField.text != nil), (passwordTextField.text != nil) else {
            print("Empty Fields")
            return
        }
        
        let jsonBody = HttpManager.shared.buildAuthenticationHttpBody(username: emailTextField.text!, password: passwordTextField.text!)
        
        print("HttpBody: \(jsonBody)" )
        
        let task = HttpManager.shared.taskForPOSTRequest(UdacityConstants.SessionPath, parameters: nil, api: API.udacity, jsonBody: jsonBody) { (results,error) in
            
            if error != nil {
                print(error)
            } else {
                print("Succeded \(results)")
            }
            
        }
        
//        let task = HttpManager.shared.taskForGETRequest(Methods.ParseStudentLocation, parameters: nil, api: API.parse) { (results,error) in
//            
//                if error != nil {
//                    print(error)
//                } else {
//                    print("Succeded \(results)")
//                }
//                        
//        }

    }
}

