//
//  SwaggerArgumentTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/2/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerArgumentTableViewCell: NSTableCellView
{
    @IBOutlet weak var argumentInfoLabel: NSTextField!
    private(set) var argument: SwaggerMethodArgument?
    
    func configureFor(argument: SwaggerMethodArgument)
    {
        self.argument = argument
        self.argumentInfoLabel.stringValue = argument.swiftSignature()
    }
}
