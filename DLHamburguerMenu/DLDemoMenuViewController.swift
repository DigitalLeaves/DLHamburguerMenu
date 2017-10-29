//
//  DLDemoMenuViewController.swift
//  DLHamburguerMenu
//
//  Created by Nacho on 5/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class DLDemoMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // outlets
    @IBOutlet weak var tableView: UITableView!
    
    // data
    let segues = ["option 1", "option 2", "option 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate&DataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segues.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) 
        cell.textLabel?.text = segues[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let nvc = self.mainNavigationController()
        if let hamburguerViewController = self.findHamburguerViewController() {
            hamburguerViewController.hideMenuViewControllerWithCompletion({
                nvc.visibleViewController?.performSegue(withIdentifier: self.segues[(indexPath as NSIndexPath).row], sender: nil)
                hamburguerViewController.contentViewController = nvc
                })
        }
    }
    
    // MARK: - Navigation
    
    func mainNavigationController() -> DLHamburguerNavigationController {
        return self.storyboard?.instantiateViewController(withIdentifier: "DLDemoNavigationViewController") as! DLHamburguerNavigationController
    }
    
}
