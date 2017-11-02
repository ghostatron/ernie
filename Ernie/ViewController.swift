//
//  ViewController.swift
//  Ernie
//
//  Created by Randy Haid on 10/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Cocoa

class ViewController: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let nodeTest = NodeJSRequirement()
        let version = nodeTest.currentlyInstalledVersion()
        print(version ?? "oops")
        if nodeTest.isCurrentlyInstalledVersionCompatible()
        {
            print("yay")
        }
        else
        {
            print("uh oh")
        }
    }

    override var representedObject: Any?
    {
        didSet
        {
        // Update the view, if already loaded.
        }
    }
}

