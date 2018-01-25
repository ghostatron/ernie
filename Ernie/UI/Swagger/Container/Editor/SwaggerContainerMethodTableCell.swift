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
    func swaggerContainerMethodCell(_ cell: SwaggerContainerMethodTableCell, method: SwaggerMethod?, wasSelected: Bool)
}

class SwaggerContainerMethodTableCell: NSTableCellView
{
    var delegate: SwaggerContainerMethodTableCellDelegate?
    private(set) var method: SwaggerMethod?
    @IBOutlet weak var methodCheckBox: NSButton!
    
    // Helps decide how the checkbox button should appear initially.
    var initialCheckState = NSControl.StateValue.off
    var initialCheckStateHasBeenSet = false
    
    // MARK:- View Lifecycle
    
    override func layout()
    {
        super.layout()
        if !self.initialCheckStateHasBeenSet
        {
            self.methodCheckBox.title = self.method?.methodName ?? "<No Method Name>"
            self.methodCheckBox.state = self.initialCheckState
            self.initialCheckStateHasBeenSet = true
        }
    }
    
    func configureFor(method: SwaggerMethod, isSelected: Bool)
    {
        self.method = method
        self.initialCheckState = isSelected ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    // MARK:- Event Handlers
    
    @IBAction func methodCheckBoxToggled(_ sender: NSButton)
    {
        self.delegate?.swaggerContainerMethodCell(self, method: self.method, wasSelected: sender.state == NSControl.StateValue.on)
    }
}
