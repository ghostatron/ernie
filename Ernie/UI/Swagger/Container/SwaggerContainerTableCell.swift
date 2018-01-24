//
//  SwaggerContainerTableCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/24/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

protocol SwaggerContainerTableCellDelegate
{
    func deleteButtonPressedForContainerInCell(_ containerCell: SwaggerContainerTableCell, container: SwaggerContainer)
}

class SwaggerContainerTableCell: NSTableCellView
{
    private var container: SwaggerContainer?
    var delegate: SwaggerContainerTableCellDelegate?
    
    func configureFor(container: SwaggerContainer)
    {
        self.container = container
    }
}
