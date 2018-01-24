//
//  SwaggerNewContainerTableCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/24/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

protocol SwaggerNewContainerTableCellDelegate
{
    func newButtonPressed(sender: SwaggerNewContainerTableCell)
}

class SwaggerNewContainerTableCell: NSTableCellView
{
    var delegate: SwaggerNewContainerTableCellDelegate?
}
