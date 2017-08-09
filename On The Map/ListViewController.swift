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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        Account.shared.sessionID = nil
        Account.shared.userId = nil
        dismiss(animated: true, completion: nil)
    }
    
}


extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocation.shared.studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell") as! StudentTableViewCell
        cell.imageView?.image = UIImage(named: "userPin")
        cell.textLabel?.text = StudentLocation.shared.studentLocations[indexPath.row].getName()
        cell.detailTextLabel?.text = StudentLocation.shared.studentLocations[indexPath.row].mediaURL
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        if let toOpen = StudentLocation.shared.studentLocations[indexPath.row].mediaURL {
            app.open(URL(string: toOpen)!)
        }
    }
}
