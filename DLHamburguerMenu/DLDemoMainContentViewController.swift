//
//  DLDemoMainContentViewController.swift
//  DLHamburguerMenu
//
//  Created by Nacho on 5/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class DLDemoMainContentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func menuButtonTouched(_ sender: AnyObject) {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    // MARK: - Button actions
    
    @IBAction func setTopMenu(_ sender: AnyObject) {
        self.findHamburguerViewController()?.menuDirection = .top
    }
    
    @IBAction func setBottomMenu(_ sender: AnyObject) {
        self.findHamburguerViewController()?.menuDirection = .bottom
    }
    
    @IBAction func setLeftMenu(_ sender: AnyObject) {
        self.findHamburguerViewController()?.menuDirection = .left
    }
    
    @IBAction func setRightMenu(_ sender: AnyObject) {
        self.findHamburguerViewController()?.menuDirection = .right
    }
    
}
