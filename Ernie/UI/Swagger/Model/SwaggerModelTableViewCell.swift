//
//  SwaggerModelTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 12/18/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerModelTableViewCell: NSTableCellView
{
    private(set) var model: SwaggerObjectModel?
    @IBOutlet weak var modelInfoLabel: NSTextField!
    
    func configureFor(model: SwaggerObjectModel)
    {
        self.model = model
        self.modelInfoLabel.stringValue = model.modelName
    }
}
