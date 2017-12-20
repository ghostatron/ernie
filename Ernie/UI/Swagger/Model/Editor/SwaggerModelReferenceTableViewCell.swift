//
//  SwaggerPropertyReferenceTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 12/19/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerModelReferenceTableViewCell: NSTableCellView
{
    @IBOutlet weak var containerInfoLabel: NSTextField!
    private(set) var container: SwaggerContainer?
    
    func configureForContainer(_ container: SwaggerContainer)
    {
        self.container = container
        self.containerInfoLabel.stringValue = container.containerTitle ?? "<No Name>"
    }
}
