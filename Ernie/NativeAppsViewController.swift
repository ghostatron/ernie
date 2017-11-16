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
    
    // MARK:- View Lifecycle
    
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
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        // One row per native app.
        return self.nativeApps.count
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        // No out-of-bounds crashes please.
        guard row < self.nativeApps.count else
        {
            return nil
        }
        
        // Instantiate a view for the cell.
        guard let nativeAppCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nativeAppRow"), owner: self) as? NativeAppTableViewCell else
        {
            return nil
        }
        
        // Configure the view and return it.
        nativeAppCell.configureForNativeApp(self.nativeApps[row])
        return nativeAppCell
    }
    
    // MARK:- Event Handlers
    
    @IBAction func registerButtonPressed(_ sender: NSButton)
    {
    }
    
    
    func allNativeApps() -> [NativeApp]?
    {
        let request: NSFetchRequest<NativeApp> = NativeApp.fetchRequest()
        let nativeApps = try? AppDelegate.mainManagedObjectContext().fetch(request)
        return nativeApps
    }
}
