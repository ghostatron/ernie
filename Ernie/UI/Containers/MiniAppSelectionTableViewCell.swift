//
//  MiniAppSelectionTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 11/21/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

protocol MiniAppSelectionDelegate
{
    func miniAppSelected(_ miniApp: MiniApp)
    func miniAppDeselected(_ miniApp: MiniApp)
}

class MiniAppSelectionTableViewCell: NSTableCellView
{
    // The mini app represented by this cell.
    private var cellMiniApp: MiniApp?
    
    // The entity interested in knowing when the check box button in the cell is toggled.
    var selectionDelegate: MiniAppSelectionDelegate?
    
    // MARK:- IBOutlet Properties

    @IBOutlet weak var miniAppCheckbox: NSButton!
    @IBOutlet weak var miniAppDescriptionLabel: NSTextField!
    
    // MARK:- Event Handlers
    
    /**
     Triggered when the check box button is toggled and informs self.selectionDelegate of the change.
     */
    @IBAction func miniAppCheckboxToggled(_ sender: NSButton)
    {
        guard let toggledMiniApp = self.cellMiniApp else
        {
            return
        }
        
        switch sender.state
        {
            case NSControl.StateValue.on:
                self.selectionDelegate?.miniAppSelected(toggledMiniApp)
            
            case NSControl.StateValue.off:
                self.selectionDelegate?.miniAppDeselected(toggledMiniApp)
            
            default:
                return
        }
    }
    
    func configureForMiniApp(_ miniApp: MiniApp, isSelected: Bool)
    {
        self.cellMiniApp = miniApp
        self.miniAppCheckbox.state = (isSelected ? NSControl.StateValue.on : NSControl.StateValue.off)
        self.miniAppCheckbox.stringValue = miniApp.miniAppName ?? "<No Name>"
        self.miniAppDescriptionLabel.stringValue = miniApp.miniAppName ?? "<No Description>"
    }
}
