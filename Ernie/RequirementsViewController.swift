//
//  RequirementsViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/13/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class RequirementsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{
    let allRequirements: [(EnvironmentRequirement & EnvironmentRequirementDelegate)] = [
        AndroidStudioRequirement(),
        ElectrodeRequirement(),
        HomeBrewRequirement(),
        NodeJSRequirement(),
        NPMRequirement(),
        NVMRequirement(),
        XcodeRequirement(),
        YarnRequirement()
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        // One row per requirement.
        return self.allRequirements.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        // No out-of-bounds crashes please.
        guard row < self.allRequirements.count else
        {
            return nil
        }
        
        // Instantiate a view for the cell.
        guard let requirementsCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requirementRow"), owner: self) as? RequirementsTableViewCell else
        {
            return nil
        }
        
        // Configure the view and return it.
        requirementsCell.configureForRequirement(self.allRequirements[row])
        return requirementsCell
    }
}
