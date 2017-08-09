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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationTextField.delegate = self
        self.websiteTextField.delegate = self
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
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
