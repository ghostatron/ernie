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
    func swaggerContainerModelCell(_ cell: SwaggerContainerModelTableCell, model: SwaggerObjectModel?, wasSelected: Bool)
}

class SwaggerContainerModelTableCell: NSTableCellView
{
    var delegate: SwaggerContainerModelTableCellDelegate?
    private(set) var model: SwaggerObjectModel?
    @IBOutlet weak var modelNameCheckBox: NSButton!
    
    // Helps decide how the checkbox button should appear initially.
    var initialCheckState = NSControl.StateValue.off
    var initialCheckStateHasBeenSet = false
    
    // MARK:- View Lifecycle
    
    override func layout()
    {
        super.layout()
        if !self.initialCheckStateHasBeenSet
        {
            self.modelNameCheckBox.title = self.model?.modelName ?? "<No Model Name>"
            self.modelNameCheckBox.state = self.initialCheckState
            self.initialCheckStateHasBeenSet = true
        }
    }
    
    func configureFor(model: SwaggerObjectModel, isSelected: Bool)
    {
        self.model = model
        self.initialCheckState = isSelected ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    // MARK:- Event Handlers
    
    @IBAction func modelNameCheckBoxToggled(_ sender: NSButton)
    {
        self.delegate?.swaggerContainerModelCell(self, model: self.model, wasSelected: sender.state == NSControl.StateValue.on)
    }
}
