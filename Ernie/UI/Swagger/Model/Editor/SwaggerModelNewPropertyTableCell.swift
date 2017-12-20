//
//  SwaggerModelNewPropertyTableCell.swift
//  Ernie
//
//  Created by Randy Haid on 12/20/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

protocol SwaggerModelNewPropertyTableCellDelegate
{
    func newButtonPressed(sender: SwaggerModelNewPropertyTableCell)
}

class SwaggerModelNewPropertyTableCell: NSTableCellView
{
    var delegate: SwaggerModelNewPropertyTableCellDelegate?
    
    @IBOutlet weak var newButton: NSButton!
    
    @IBAction func newButtonPressed(_ sender: NSButton)
    {
        self.delegate?.newButtonPressed(sender: self)
    }
}
