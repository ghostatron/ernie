//
//  SwaggerContainerMethodTableCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/24/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

protocol SwaggerContainerMethodTableCellDelegate
{
    func deleteButtonPressedForMethodInCell(_ containerCell: SwaggerContainerMethodTableCell, method: SwaggerMethod?)
}

class SwaggerContainerMethodTableCell: NSTableCellView
{
    var delegate: SwaggerContainerMethodTableCellDelegate?
    private(set) var method: SwaggerMethod?
    
    func configureFor(method: SwaggerMethod)
    {
        self.method = method
    }
    
    // MARK:- Event Handlers
    
    @IBAction func deleteButtonPressed(_ sender: NSButton)
    {
        self.delegate?.deleteButtonPressedForMethodInCell(self, method: self.method)
    }
}
