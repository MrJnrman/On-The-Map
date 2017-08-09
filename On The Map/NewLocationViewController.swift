//
//  NewLocationViewController.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/8/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import UIKit

class NewLocationViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    
    @IBAction func findLocationPressed(_ sender: Any) {
        
        guard (locationTextField.text != ""), (websiteTextField.text != "") else {
            showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.MissingInfo, buttonText: AlertViewConstants.Ok)
            return
        }
        
        let newPinVC = self.storyboard?.instantiateViewController(withIdentifier: "NewLocationMapViewController") as! NewLocationMapViewController
        
        newPinVC.location = locationTextField.text
        newPinVC.website = websiteTextField.text
        
        self.navigationController?.pushViewController(newPinVC, animated: true)
    }
    
    func showAlertView(title: String, message: String, buttonText: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: buttonText, style: .destructive, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
