//
//  ViewController.swift
//  MyFirstXcodeProj
//
//  Created by hanawa-y on 2016/05/31.
//  Copyright © 2016年 hanawa-y. All rights reserved.
//

import UIKit
import Foundation
import WhoisCmd
import DfCmd

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()

        if let cmdline = textField.text {
            let cmds = cmdline.componentsSeparatedByString(" ")
            if cmds[0] == "whois" {
                let cmd = WhoisCmd(cmds)
                cmd.exec()
                outputField.text = cmd.cout + cmd.cerr + "\n\nreturn_code=\(cmd.retval)"
            } else if cmds[0] == "df" {
                let cmd = DfCmd(cmds)
                cmd.exec()
                outputField.text = cmd.cout + cmd.cerr + "\n\nreturn_code=\(cmd.retval)"
            } else {
                outputField.text = "Command not found: \(cmds[0])"
            }
        }

        return true
    }
    
/*
    @IBAction func tapButton(sender: UIButton) {
        infoField.text = "Tapped!"
        
        let argv = CStringArray(["/bin/sh", "-c", "ls -la /"])

        var pid: pid_t = 0
        let status = posix_spawnp(&pid, argv.pointers[0], nil, nil, argv.pointers, nil)
        print(String(format:"Child pid: %i", pid))
        if (status != 0) {
            print("posix_spawn: " + String.fromCString(strerror(status))!)
        }
    }
*/
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var outputField: UITextView!

}


// Is this really the best way to extend the lifetime of C-style strings? The lifetime
// of those passed to the String.withCString closure are only guaranteed valid during
// that call. Tried cheating this by returning the same C string from the closure but it
// gets dealloc'd almost immediately after the closure returns. This isn't terrible when
// dealing with a small number of constant C strings since you can nest closures. But
// this breaks down when it's dynamic, e.g. creating the char** argv array for an exec
// call.
class CString {
    private let _len: Int
    let buffer: UnsafeMutablePointer<Int8>
    
    init(_ string: String) {
        (_len, buffer) = string.withCString {
            let len = Int(strlen($0) + 1)
            let dst = strcpy(UnsafeMutablePointer<Int8>.alloc(len), $0)
            return (len, dst)
        }
    }
    
    deinit {
        buffer.dealloc(_len)
    }
}

// An array of C-style strings (e.g. char**) for easier interop.
class CStringArray {
    // Have to keep the owning CString's alive so that the pointers
    // in our buffer aren't dealloc'd out from under us.
    private let _strings: [CString]
    var pointers: [UnsafeMutablePointer<Int8>]
    
    init(_ strings: [String]) {
        _strings = strings.map { CString($0) }
        pointers = _strings.map { $0.buffer }
        // NULL-terminate our string pointer buffer since things like
        // exec*() and posix_spawn() require this.
        pointers.append(nil)
    }
}