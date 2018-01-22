//
//  SwaggerMethodTagTableCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/22/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

class SwaggerMethodTagTableCell: NSTableCellView
{
    @IBOutlet weak var tagTextField: NSTextFieldCell!
    
    func configureForTag(_ tag: String)
    {
        self.tagTextField.stringValue = tag
    }
}
