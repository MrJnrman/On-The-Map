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
    
    var location: String!
    var website: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(self.location) { (placemarks, error) -> Void in
            if error == nil {
                if placemarks!.count == 0 {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = (placemarks?[0].location?.coordinate)!
                    annotation.title = Account.shared.getFullName()
                    annotation.subtitle = self.website
                    self.mapView.addAnnotation(annotation)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
    }
    
    @IBAction func submitPressed(_ sender: Any) {
    }
}

extension NewLocationMapViewController: MKMapViewDelegate {
    
}
