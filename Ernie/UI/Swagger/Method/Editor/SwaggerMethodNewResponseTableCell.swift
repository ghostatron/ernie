//
//  SwaggerMethodNewResponseTableCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/23/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

protocol SwaggerMethodNewResponseTableCellDelegate
{
    func newButtonPressed(sender: SwaggerMethodNewResponseTableCell)
}

class SwaggerMethodNewResponseTableCell: NSTableCellView
{
    var delegate: SwaggerMethodNewResponseTableCellDelegate?
    @IBAction func newResponseButtonPressed(_ sender: NSButton)
    {
        self.delegate?.newButtonPressed(sender: self)
    }
}
