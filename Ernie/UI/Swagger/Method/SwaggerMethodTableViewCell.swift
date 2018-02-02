//
//  SwaggerMethodTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/2/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

protocol SwaggerMethodTableViewCellDelegate
{
    func deleteButtonPressedForMethodInCell(_ methodCell: SwaggerMethodTableViewCell, method: SwaggerMethod?)
}

class SwaggerMethodTableViewCell: NSTableCellView
{
    @IBOutlet weak var methodInfoLabel: NSTextField!
    private(set) var method: SwaggerMethod?
    var delegate: SwaggerMethodTableViewCellDelegate?
    
    func configureFor(method: SwaggerMethod)
    {
        self.method = method
        self.methodInfoLabel.stringValue = method.swiftSignature()
    }
    
    @IBAction func deleteButtonPressed(_ sender: NSButton)
    {
        self.delegate?.deleteButtonPressedForMethodInCell(self, method: self.method)
    }
}
