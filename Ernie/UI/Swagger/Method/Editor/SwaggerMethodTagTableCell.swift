//
//  SwaggerMethodTagTableCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/22/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

protocol SwaggerMethodTagTableCellDelegate
{
    func deleteButtonPressedForTagInCell(_ tagCell: SwaggerMethodTagTableCell, tag: String)
}

class SwaggerMethodTagTableCell: NSTableCellView
{
    @IBOutlet weak var tagTextField: NSTextFieldCell!
    var delegate: SwaggerMethodTagTableCellDelegate?
    
    func configureForTag(_ tag: String)
    {
        self.tagTextField.stringValue = tag
    }
    
    @IBAction func deleteButtonPressed(_ sender: NSButton)
    {
        self.delegate?.deleteButtonPressedForTagInCell(self, tag: self.tagTextField.stringValue)
    }
}
