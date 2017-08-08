//
//  MapViewController.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/7/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getStudentLocations()
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        Account.shared.sessionID = nil
        Account.shared.userId = nil
        dismiss(animated: true, completion: nil)
    }
    
    func getStudentLocations() {
        let parameters = [
            ParameterKeys.Limit: ParameterValues.Limit,
            ParameterKeys.Order: ParameterValues.Descending
        ]
        _ = HttpManager.shared.taskForGETRequest(Methods.ParseStudentLocation, parameters: parameters as [String:AnyObject], api: .parse) { (results,error) in
            performUIUpdatesOnMain {
                if error == nil {
                    self.loadMap(results!)
                } else {
                    print("error")
                }
            }
        }
    }
    
    func loadMap(_ results: AnyObject) {
        
        var annotations = [MKPointAnnotation]()
        
        
        
        for dictionary in results[JSONResponseKeys.Results] as! [[String:AnyObject]] {
            guard let lat = dictionary["latitude"], let long = dictionary["longitude"] else {
                continue
            }

            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat as! Double), longitude: CLLocationDegrees(long as! Double))
            
            guard let first = dictionary["firstName"] as? String, let last = dictionary["lastName"] as? String else {
                continue
            }
            
            guard let mediaURL = dictionary["mediaURL"] as? String else{
                continue
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .purple
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
