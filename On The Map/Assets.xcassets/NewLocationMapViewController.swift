//
//  NewLocationMapViewController.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/8/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import UIKit
import MapKit

class NewLocationMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let annotation = MKPointAnnotation()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var location: String!
    var website: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(self.location) { (placemarks, error) -> Void in
            
            if error == nil {
                if placemarks!.count != 0 {
                    self.annotation.coordinate = (placemarks?[0].location?.coordinate)!
                    self.annotation.title = Account.shared.getFullName()
                    self.annotation.subtitle = self.website
                    self.mapView.addAnnotation(self.annotation)
                    self.mapView.selectAnnotation(self.annotation, animated: true)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        let jsonBody = StudentLocation.shared.buildJSONBody(mediaURL: self.annotation.subtitle!, lat: Double(self.annotation.coordinate.latitude), long: Double(self.annotation.coordinate.longitude))
        
        self.showActivityIndicator()
        HttpManager.shared.postNewLocation(jsonBody) { (success) in
            
            performUIUpdatesOnMain {
                
                if success {
                    self.hideActivityIndicator()
                    self.navigationController?.popToRootViewController(animated: true)
                    self.mapView.addAnnotation(self.annotation)
                } else {
                    self.hideActivityIndicator()
                    self.dismiss(animated: true, completion: nil)
                    self.hideActivityIndicator()
                }
                
            }
        }
        
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension NewLocationMapViewController: MKMapViewDelegate {
    
}
