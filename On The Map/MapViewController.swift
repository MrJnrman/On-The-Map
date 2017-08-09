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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStudentLocations()
        self.navigationController?.navigationBar.isHidden = true
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
        
        _ = HttpManager.shared.taskForDELETRequest(UdacityConstants.SessionPath, api: .udacity) { (success) in
            performUIUpdatesOnMain {
                if success {
                    Account.shared.sessionID = nil
                    Account.shared.userId = nil
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.LogoutError, buttonText: AlertViewConstants.Dismiss)
                }
            }
        }
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
                    let annotations = self.mapView.annotations
                    self.mapView.removeAnnotations(annotations)
                    self.loadMap(results!)
                } else {
                    self.showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.MapError, buttonText: AlertViewConstants.PinCancel)
                }
            }
        }
    }
    
    func loadMap(_ results: AnyObject) {
        
        var annotations = [MKPointAnnotation]()
        
        let studentLocations = StudentLocation.shared.build(results)
        updateAppDelegateList(studentLocations: studentLocations)
        
        for studentLocation in studentLocations {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentLocation.latitude), longitude: CLLocationDegrees(studentLocation.longitude))
            annotation.title = "\(studentLocation.firstName!) \(studentLocation.lastName!)"
            annotation.subtitle = studentLocation.mediaURL
            
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    func updateAppDelegateList(studentLocations: [StudentLocation]) {
        StudentDataSource.sharedInstance.studentData = studentLocations
    }
    
    @IBAction func dropPin(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: self.mapView)
    
        let locationCoordinates = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        showPinDropAlert() { (websiteURL) in
            
            guard let websiteURL = websiteURL else {
                return
            }
            
            let jsonBody = StudentLocation.shared.buildJSONBody(mediaURL: websiteURL, lat: Double(locationCoordinates.latitude), long: Double(locationCoordinates.longitude))

            self.showActivityIndicator()
            HttpManager.shared.postNewLocation(jsonBody) { (success) in
                
                performUIUpdatesOnMain {
                    
                    if success {
                        self.hideActivityIndicator()
                        self.annotation.coordinate = locationCoordinates
                        self.annotation.title = Account.shared.getFullName()
                        self.annotation.subtitle = websiteURL
                        
                        self.mapView.addAnnotation(self.annotation)
                    } else {
                        self.hideActivityIndicator()
                    }
                    
                }
            }
        }
        
        
    }
    
    func postNewLocation(mediaURL: String, lat: Double, long: Double, completionHandler: @escaping (_ success: Bool) -> Void ) {
        self.showActivityIndicator()
        let jsonBody = StudentLocation.shared.buildJSONBody(mediaURL: mediaURL, lat: lat, long: long)
        
        let _ = HttpManager.shared.taskForPOSTRequest(Methods.ParseStudentLocation, parameters: nil, api: .parse, jsonBody: jsonBody) { (results,error) in
            
            if error == nil {
                self.hideActivityIndicator()
                completionHandler(true)
            } else {
                self.hideActivityIndicator()
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
    
    @IBAction func refreshPressed(_ sender: Any) {
        getStudentLocations()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            
            guard let toOpen = view.annotation?.subtitle! else {
                showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.InvalidURL, buttonText: AlertViewConstants.Dismiss)
                return
            }
            
            guard let url = URL(string: toOpen) else {
                showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.InvalidURL, buttonText: AlertViewConstants.Dismiss)
                return
            }
            
            app.open(url)
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
