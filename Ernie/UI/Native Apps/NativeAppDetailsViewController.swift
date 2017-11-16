//
//  NativeAppDetailsViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/16/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class NativeAppDetailsViewController: NSViewController
{
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = "Native App Details"
    }
}
