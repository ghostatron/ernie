//
//  SwaggerMethodTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/2/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerMethodTableViewCell: NSTableCellView
{
    private(set) var method: SwaggerMethod?
    func configureFor(method: SwaggerMethod)
    {
        self.method = method
    }
}
