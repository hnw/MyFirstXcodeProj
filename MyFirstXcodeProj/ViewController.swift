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
        let arguments = ["/bin/sh", "-c", "ls -la /sbin"];
//        let arguments = ["/bin/ls", "bin"];
        var cstr_arr = arguments.map {
            (y)->UnsafeMutablePointer<Int8> in
            y.withCString(
                {(x: UnsafePointer<Int8>) in
                    let len = Int(strlen(x) + 1)
                    let dst = UnsafeMutablePointer<Int8>.alloc(len)
                    strcpy(dst,x);
                    return dst
            })
        }
        cstr_arr.append(nil)
        cstr_arr.withUnsafeBufferPointer {
            let argv = $0.baseAddress
            var pid: pid_t = 0;
            let status = posix_spawn(&pid, $0[0], nil, nil, argv, nil)
            if (status == 0) {
                print(String(format: "Child pid: %i", pid));
            } else {
                let err = String.fromCString(strerror(status))
                print(String(format: "Child pid: %i", pid));
                print("posix_spawn: " + err!);
            }

        }
    }
    
    @IBOutlet weak var infoField: UITextField!
}
