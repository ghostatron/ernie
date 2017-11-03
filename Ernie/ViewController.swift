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

        let reqTest = ElectrodeRequirement()
        let version = reqTest.currentlyInstalledVersion()
        print("version: \(version ?? "oops")")
        if reqTest.isCurrentlyInstalledVersionCompatible()
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

