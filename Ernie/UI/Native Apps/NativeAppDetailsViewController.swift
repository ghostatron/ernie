//
//  NativeAppDetailsViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/16/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class NativeAppDetailsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    /**
     The owner of this NativeAppDetailsViewController should assign a NativeApp before presenting.
     This is the NativeApp that will be used to populate the UI elements.
     */
    var nativeApp: NativeApp?

    // MARK:- IBOutlet Properties

    @IBOutlet weak var nativeAppNameLabel: NSTextField!
    @IBOutlet weak var nativeAppFolderLabel: NSTextField!
    @IBOutlet weak var nativeAppDescriptionLabel: NSTextField!
    @IBOutlet weak var containerNameLabel: NSTextField!
    @IBOutlet weak var containerFolderLabel: NSTextField!
    @IBOutlet weak var containerDescriptionLabel: NSTextField!
    @IBOutlet weak var addContainerButton: NSButton!
    @IBOutlet weak var miniAppsTableView: NSTableView!
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        // If we have a native app, then configure ourselves for it.
        if let app = self.nativeApp
        {
            self.configureForNativeApp(app)
        }
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = "Native App Details"
    }
    
    /**
     Updates the UI elements to reflect the given NativeApp.
     */
    private func configureForNativeApp(_ nativeApp: NativeApp)
    {
        self.nativeApp = nativeApp
        
        self.nativeAppNameLabel.stringValue = nativeApp.appName ?? "<No Name>"
        self.nativeAppFolderLabel.stringValue = nativeApp.appFolder ?? "<No Folder>"
        self.nativeAppDescriptionLabel.stringValue = nativeApp.appDescription ?? ""
        
        if let container = nativeApp.container
        {
            self.containerNameLabel.isHidden = false
            self.containerNameLabel.stringValue = container.containerName ?? "<No Name>"
            self.containerFolderLabel.isHidden = false
            self.containerFolderLabel.stringValue = container.containerFolder ?? "<No Folder>"
            self.containerDescriptionLabel.isHidden = false
            self.containerDescriptionLabel.stringValue = container.containerDescription ?? ""
            
            self.addContainerButton.isHidden = true
        }
        else
        {
            self.containerNameLabel.isHidden = true
            self.containerFolderLabel.isHidden = true
            self.containerDescriptionLabel.isHidden = true
            self.addContainerButton.isHidden = false
        }
    }
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        // One row per native app.
        return self.nativeApp?.container?.miniApps?.count ?? 0
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        guard let nativeApp = self.nativeApp else
        {
            return nil
        }
        
        // No out-of-bounds crashes please.
        guard row < (nativeApp.container?.miniApps?.count ?? 0) else
        {
            return nil
        }
        
        // Instantiate a view for the cell.
        guard let miniAppCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nativeAppRow"), owner: self) as? NativeAppTableViewCell else
        {
            return nil
        }
        
        // Configure the view and return it.
        //nativeAppCell.configureForNativeApp(self.nativeApps[row])
        return miniAppCell
    }
}
