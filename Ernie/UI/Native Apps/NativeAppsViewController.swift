//
//  NativeAppsViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/15/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class NativeAppsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, ModalDialogDelegate, NativeAppTableViewCellDelegate
{
    // The data source for the table which represents all registered native apps.
    private var nativeApps: [NativeApp]!
    
    // If the user clicks on a "Details" button for one of the apps in the table, then this variable
    // lets us know the corresponding native app that the user wants details for.
    private var detailNativeApp: NativeApp?
    
    // MARK:- IBOutlet Properties

    @IBOutlet weak var nativeAppTableView: NSTableView!
    
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
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?)
    {
        if let registerVC = segue.destinationController as? RegisterNativeAppViewController
        {
            // We need to know when the register dialog is completed.
            registerVC.delegate = self
        }
        else if let detailApp = self.detailNativeApp, let detailVC = segue.destinationController as? NativeAppDetailsViewController
        {
            // The details screen needs to know which app we're talking about.
            detailVC.nativeApp = detailApp
        }
    }
    
    // MARK:- NativeAppTableViewCellDelegate
    
    /**
     When the user clicks on the "Details" button for a native app, we need to segue to the details view controller.
     */
    func detailsButtonPressed(nativeApp: NativeApp)
    {
        self.detailNativeApp = nativeApp
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toNativeAppDetails"), sender: self)
    }
    
    // MARK:- ModalDialogDelegate
    
    func dismissedWithOK()
    {
        // Reload the table.
        self.nativeApps = self.allNativeApps() ?? []
        self.nativeAppTableView.reloadData()
    }
    
    func dismissedWithCancel()
    {
        // Don't care
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
        nativeAppCell.delegate = self
        return nativeAppCell
    }
    
    // MARK:- Event Handlers
    
    func allNativeApps() -> [NativeApp]?
    {
        let request: NSFetchRequest<NativeApp> = NativeApp.fetchRequest()
        let nativeApps = try? AppDelegate.mainManagedObjectContext().fetch(request)
        return nativeApps
    }
}
