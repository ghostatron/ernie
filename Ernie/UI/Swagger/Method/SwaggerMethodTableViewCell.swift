//
//  SwaggerMethodTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/2/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerMethodTableViewCell: NSTableCellView
{
    @IBOutlet weak var methodInfoLabel: NSTextField!
    
    private(set) var method: SwaggerMethod?
    func configureFor(method: SwaggerMethod)
    {
        self.method = method
        self.methodInfoLabel.stringValue = method.swiftSignature()
    }
}
