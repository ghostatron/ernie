//
//  NativeAppsViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/15/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class NativeAppsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{
    private var nativeApps: [NativeApp]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.nativeApps = self.allNativeApps() ?? []
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = "Native Apps"
    }
    
    func allNativeApps() -> [NativeApp]?
    {
        let request: NSFetchRequest<NativeApp> = NativeApp.fetchRequest()
        let nativeApps = try? AppDelegate.mainManagedObjectContext().fetch(request)
        return nativeApps
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        // One row per native app.
        return self.nativeApps.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        // No out-of-bounds crashes please.
        guard row < self.nativeApps.count else
        {
            return nil
        }
        
        return nil
        
        // Instantiate a view for the cell.
//        guard let requirementsCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requirementRow"), owner: self) as? RequirementsTableViewCell else
//        {
//            return nil
//        }
//
//        // Configure the view and return it.
//        requirementsCell.configureForRequirement(self.allRequirements[row])
//        return requirementsCell
    }
}
