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
    
    var requirement: (EnvironmentRequirement & EnvironmentRequirementDelegate)?
    func configureForRequirement(_ requirement: (EnvironmentRequirement & EnvironmentRequirementDelegate))
    {
        self.requirement = requirement
        self.requirementIcon.image = NSImage(imageLiteralResourceName: requirement.iconName)
        self.requirementName.stringValue = requirement.name
        self.requirementDescription.stringValue = requirement.description
        
        self.installButton.isEnabled = false
        self.updateButton.isEnabled = false
        self.requirementVersion.stringValue = "(Checking version...)"
        
        DispatchQueue.global().async {
            
            let version = requirement.currentlyInstalledVersion()
            
            DispatchQueue.main.async {
                if let version = version
                {
                    self.requirementVersion.stringValue = "v. \(version)"
                    self.updateButton.isEnabled = true
                }
                else
                {
                    self.requirementVersion.stringValue = "(Not Installed)"
                    self.installButton.isEnabled = true
                }
            }
        }
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
