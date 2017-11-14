//
//  RequirementsTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 11/13/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class RequirementsTableViewCell: NSTableCellView
{
    // MARK:- IBOutlet Properties
    
    @IBOutlet private weak var requirementName: NSTextField!
    @IBOutlet private weak var requirementVersion: NSTextField!
    @IBOutlet private weak var requirementDescription: NSTextField!
    @IBOutlet private weak var installButton: NSButton!
    @IBOutlet private weak var updateButton: NSButton!
    @IBOutlet private weak var requirementIcon: NSImageView!
    
    var requirement: EnvironmentRequirementDelegate?
    func configureForRequirement(_ requirement: EnvironmentRequirementDelegate)
    {
        self.requirement = requirement
        self.requirementIcon.image = NSImage(imageLiteralResourceName: requirement.iconName)
        self.requirementName.stringValue = requirement.name
        self.requirementVersion.stringValue = "v. 9999"
        self.requirementDescription.stringValue = requirement.description
    }
    
    // MARK:- Event Handlers
    
    @IBAction func installButtonPressed(_ sender: NSButton)
    {
        print("\(String(describing: self.requirement?.name))")
    }
    
    @IBAction func updateButtonPressed(_ sender: NSButton)
    {
        print("\(String(describing: self.requirement?.description))")
    }
}
