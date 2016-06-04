//
//  ViewController.swift
//  MyFirstXcodeProj
//
//  Created by hanawa-y on 2016/05/31.
//  Copyright © 2016年 hanawa-y. All rights reserved.
//

import UIKit
import Foundation

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
        outputField.text="$ "+textField.text!+"\nfoobar"
        print("hoge")
        
        let manager = NSFileManager.defaultManager()
        do {
            let list = try manager.contentsOfDirectoryAtPath(inputField.text!)
            for path in list {
                print(path)
                do {
                    let list = try manager.contentsOfDirectoryAtPath(inputField.text!+"/"+path)
                    for path in list {
                        print("  "+path)
                    }
                } catch let _ {
                    
                }
            }
            
        } catch let _ {
            
        }
        inputField.text?.withCString {
            my_stat($0)
        }
/*
            let buf = UnsafeMutablePointer<stat>.alloc(1);
            let statusx = stat("/bin/", buf)
            if (statusx != 0) {
                print("posix_spawn: " + String.fromCString(strerror(statusx))!)
             }
 */


        let argv = CStringArray(["/Developer/usr/bin/iprofiler", "--help"])
        //let argv = CStringArray(["/bin/sh", "-c", textField.text!])
        //let argv = CStringArray([textField.text!])
        var pid: pid_t = 0
        var action: posix_spawn_file_actions_t = nil
        var cout_pipe: [Int32] = [0,0]
        var cerr_pipe: [Int32] = [0,0]
        var exit_code: Int32 = 0
        
        pipe(&cout_pipe)
        pipe(&cerr_pipe)
	
        posix_spawn_file_actions_init(&action)
        posix_spawn_file_actions_addclose(&action, cout_pipe[0]);
        posix_spawn_file_actions_addclose(&action, cerr_pipe[0]);
        posix_spawn_file_actions_adddup2(&action, cout_pipe[1], 1);
        posix_spawn_file_actions_adddup2(&action, cerr_pipe[1], 2);
        posix_spawn_file_actions_addclose(&action, cout_pipe[1]);
        posix_spawn_file_actions_addclose(&action, cerr_pipe[1]);
        
        let status = posix_spawnp(&pid, argv.pointers[0], &action, nil, argv.pointers, nil)

        print(String(format:"Child pid: %i", pid))
        if (status != 0) {
            print("posix_spawn: " + String.fromCString(strerror(status))!)
        }
        
        close(cout_pipe[1]);
        close(cerr_pipe[1]);

        let buffer_size = 1024;
        var buffer = [Int8](count: buffer_size+1, repeatedValue: 0)

        var bytes_read = read(cout_pipe[0], &buffer, buffer_size)
        outputField.text="$ "+textField.text!+"\n"
        while (bytes_read > 0) {
            print(String(format:"bytes_read: %i", bytes_read))
            print(String.fromCString(buffer)!)
            outputField.text = outputField.text.stringByAppendingString(String.fromCString(buffer)!);
            bytes_read = read(cout_pipe[0], &buffer, buffer_size)
        }

        waitpid(pid,&exit_code,0);
        print(String(format:"exit code: %i", exit_code))

        posix_spawn_file_actions_destroy(&action);

//        print(String.fromCString(x))
        
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