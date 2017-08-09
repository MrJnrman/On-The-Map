//
//  ListViewController.swift
//  On The Map
//
//  Created by Jamel Reid  on 8/7/17.
//  Copyright © 2017 Jamel Reid . All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
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
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}


extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell") as! StudentTableViewCell
        cell.imageView?.image = UIImage(named: "userPin")
        cell.textLabel?.text = appDelegate.studentLocations[indexPath.row].getName()
        cell.detailTextLabel?.text = appDelegate.studentLocations[indexPath.row].mediaURL
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        if let toOpen = appDelegate.studentLocations[indexPath.row].mediaURL {
            guard let url = URL(string: toOpen) else {
                showAlertView(title: AlertViewConstants.Title, message: AlertViewConstants.InvalidURL, buttonText: AlertViewConstants.Dismiss)
                return
            }
            
            app.open(url)
        }
    }
}
