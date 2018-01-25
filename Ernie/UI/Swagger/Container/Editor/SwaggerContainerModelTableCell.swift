//
//  SwaggerContainerModelCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/24/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

protocol SwaggerContainerModelTableCellDelegate
{
    func deleteButtonPressedForModelInCell(_ modelCell: SwaggerContainerModelTableCell, model: SwaggerObjectModel?)
}

class SwaggerContainerModelTableCell: NSTableCellView
{
    var delegate: SwaggerContainerModelTableCellDelegate?
    private(set) var model: SwaggerObjectModel?
    
    func configureFor(model: SwaggerObjectModel)
    {
        self.model = model
    }
    
    // MARK:- Event Handlers
    
    @IBAction func deleteButtonPressed(_ sender: NSButton)
    {
        self.delegate?.deleteButtonPressedForModelInCell(self, model: self.model)
    }
}
