//
//  SwaggerPropertyTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 12/18/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerPropertyTableViewCell: NSTableCellView
{
    private(set) var property: SwaggerModelProperty?
    @IBOutlet weak var propertyInfoLabel: NSTextField!
    
    func configureForProperty(_ property: SwaggerModelProperty)
    {
        self.property = property
        self.propertyInfoLabel.stringValue = "\(property.propertyIsRequired ? "* " : "")\(property.propertyName)"
    }
}
