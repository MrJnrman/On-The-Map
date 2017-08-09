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
    let annotation = MKPointAnnotation()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        getStudentLocations()
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
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        Account.shared.sessionID = nil
        Account.shared.userId = nil
        dismiss(animated: true, completion: nil)
    }
    
    func getStudentLocations() {
        
        self.showActivityIndicator()
        
        let parameters = [
            ParameterKeys.Limit: ParameterValues.Limit,
            ParameterKeys.Order: ParameterValues.Descending
        ]
        _ = HttpManager.shared.taskForGETRequest(Methods.ParseStudentLocation, parameters: parameters as [String:AnyObject], api: .parse) { (results,error) in
            performUIUpdatesOnMain {
                self.hideActivityIndicator()
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
        
        let studentLocations = StudentLocation.shared.build(results)
        
        for studentLocation in studentLocations {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentLocation.latitude), longitude: CLLocationDegrees(studentLocation.longitude))
            annotation.title = "\(studentLocation.firstName!) \(studentLocation.lastName!)"
            annotation.subtitle = studentLocation.mediaURL
            
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    @IBAction func dropPin(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: self.mapView)
    
        let locationCoordinates = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        showPinDropAlert() { (websiteURL) in
            
            guard let websiteURL = websiteURL else {
                return
            }
            
            self.postNewLocation(mediaURL: websiteURL, lat: Double(locationCoordinates.latitude), long: Double(locationCoordinates.longitude)) { (success) in
                
                performUIUpdatesOnMain {
                    
                    if success {
                        self.annotation.coordinate = locationCoordinates
                        self.annotation.title = Account.shared.getFullName()
                        self.annotation.subtitle = websiteURL
                        
                        self.mapView.addAnnotation(self.annotation)
                    }
                    
                }
            }
            
            // TODO: Update the parse api with new pin info
            
        }
        
        
    }
    
    func buildJSONBody(mediaURL: String, lat: Double, long: Double) -> String{
        var jsonBody = HttpBody.LocationBody
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.uniqueKey, with: Account.shared.userId!)
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.LastName, with: Account.shared.lastName!)
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.FirstName, with: Account.shared.firstName!)
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.MapString, with: "")
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.Latitude, with: "\(lat)")
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.Longitude, with: "\(long)")
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.MediaURL, with: mediaURL)
        
        return jsonBody
    }
    
    func postNewLocation(mediaURL: String, lat: Double, long: Double, completionHandler: @escaping (_ success: Bool) -> Void ) {
        
        let jsonBody = buildJSONBody(mediaURL: mediaURL, lat: lat, long: long)
        let _ = HttpManager.shared.taskForPOSTRequest(Methods.ParseStudentLocation, parameters: nil, api: .parse, jsonBody: jsonBody) { (results,error) in
            
            if error == nil {
                 completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    func showPinDropAlert(completionHandler: @escaping (_ website: String?) -> Void) {
        let pinAlertController = UIAlertController(title: "Website", message: "Input your personal website.", preferredStyle: .alert)
    
        pinAlertController.addAction(UIAlertAction(title: AlertViewConstants.PinSave, style: .default) { (alert) in
            let websiteTextField = pinAlertController.textFields![0] as UITextField
            
            if websiteTextField.text != "" {
                completionHandler(websiteTextField.text)
            } else {
                completionHandler(nil)
            }
        })
        
        pinAlertController.addAction(UIAlertAction(title: AlertViewConstants.PinCancel, style: .default) { (alert) in
            completionHandler(nil)
        })
        
        pinAlertController.addTextField() { (textField) in
            textField.placeholder = "Website"
            textField.textAlignment = .left
        }
        
        self.present(pinAlertController, animated: true, completion: nil)
    
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("reach")
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .purple
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
