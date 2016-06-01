//
//  ViewController.swift
//  MyFirstXcodeProj
//
//  Created by hanawa-y on 2016/05/31.
//  Copyright © 2016年 hanawa-y. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapButton(sender: UIButton) {
        infoField.text = "Tapped!"
        exec_ls()
    }

    @IBOutlet weak var infoField: UITextField!
}
