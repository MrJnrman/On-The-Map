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
        let newPinVC = self.storyboard?.instantiateViewController(withIdentifier: "NewLocationMapViewController") as! NewLocationMapViewController
        
        newPinVC.location = locationTextField.text
        newPinVC.website = websiteTextField.text
        
        self.navigationController?.pushViewController(newPinVC, animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
