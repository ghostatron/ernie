//
//  MiniAppsViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/22/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class MiniAppsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, ModalDialogDelegate
{
    /// The data source for the mini apps table.
    private var allMiniAppsAlphabetized: [MiniApp] = []
    
    /// Tracks which mini app is currently selected in the mini apps table.
    private var selectedMiniApp: MiniApp?
    
    /// The data source for the containers table.
    private var selectedMiniAppContainersAlphabetized: [Container] = []
    
    /// The mode to use when launching the editor.  The user will ultimately choose this via the UI.
    private var editorMode = MiniAppEditorViewController.EditorMode.New
    
    // MARK:- IBOutlet Properties

    @IBOutlet weak var editButton: NSButton!
    @IBOutlet weak var miniAppNameLabel: NSTextField!
    @IBOutlet weak var miniAppFolderLabel: NSTextField!
    @IBOutlet weak var miniAppDescriptionLabel: NSTextField!
    @IBOutlet weak var miniAppsTableView: NSTableView!
    @IBOutlet weak var containersTableView: NSTableView!
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.allMiniAppsAlphabetized = self.allMiniApps() ?? []
        self.configureViewForSelectedMiniApp()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = "Mini Apps"
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?)
    {
        if let editorVC = segue.destinationController as? MiniAppEditorViewController
        {
            // We need to know when the register dialog is completed.
            editorVC.mode = self.editorMode
            editorVC.miniApp = self.selectedMiniApp
            editorVC.modalDelegate = self
            if let miniApp = self.selectedMiniApp
            {
                editorVC.title = "\(miniApp.miniAppName ?? "MiniApp") [Edit]"
            }
            else
            {
                editorVC.title = "MiniApp [New]"
            }
        }
    }
    
    // MARK:- Private Methods
    
    private func allMiniApps() -> [MiniApp]?
    {
        let request: NSFetchRequest<MiniApp> = MiniApp.fetchRequest()
        let alphabeticalSort = NSSortDescriptor(key: "miniAppName", ascending: true)
        request.sortDescriptors = [alphabeticalSort]
        let containers = try? AppDelegate.mainManagedObjectContext().fetch(request)
        return containers
    }
    
    private func configureViewForSelectedMiniApp()
    {
        if let miniApp = self.selectedMiniApp
        {
            self.miniAppNameLabel.isHidden = false
            self.miniAppFolderLabel.isHidden = false
            self.miniAppDescriptionLabel.isHidden = false
            self.containersTableView.isHidden = false
            self.editButton.isEnabled = true
            
            self.miniAppNameLabel.stringValue = miniApp.miniAppName ?? "<No Name>"
            self.miniAppFolderLabel.stringValue = miniApp.miniAppFolder ?? "<No Folder>"
            self.miniAppDescriptionLabel.stringValue = miniApp.miniAppDescription ?? ""
            self.containersTableView.reloadData()
        }
        else
        {
            self.miniAppNameLabel.isHidden = true
            self.miniAppFolderLabel.isHidden = true
            self.miniAppDescriptionLabel.isHidden = false
            self.containersTableView.isHidden = true
            self.editButton.isEnabled = false
            
            self.miniAppDescriptionLabel.stringValue = "Select a container on the left to view it's mini apps."
        }
    }
    
    // MARK:- Event Handlers
    
    @IBAction func addMiniAppButtonPressed(_ sender: NSButton)
    {
        let alert = NSAlert()
        alert.addButton(withTitle: "Create New...")
        alert.addButton(withTitle: "Register Existing...")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = "Create New or Register Existing"
        alert.informativeText = "You can create a NEW mini app and we'll get it started for you, or you can REGISTER an existing one by telling us about it."
        switch alert.runModal()
        {
        case NSApplication.ModalResponse.alertFirstButtonReturn:
            self.editorMode = .New
        case NSApplication.ModalResponse.alertSecondButtonReturn:
            self.editorMode = .Register
        default:
            return
        }
        
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toMiniAppEditor"), sender: self)
    }
    
    @IBAction func editButtonPressed(_ sender: NSButton)
    {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toMiniAppEditor"), sender: self)
    }
    
    // MARK:- ModalDialogDelegate
    
    // If the "Edit" or "Add" dialog returns with "OK", then we need to refresh the page.
    func dismissedWithOK(dialog: NSViewController)
    {
        // Reload the table.
        self.allMiniAppsAlphabetized = self.allMiniApps() ?? []
        self.miniAppsTableView.reloadData()
        self.configureViewForSelectedMiniApp()
    }
    
    func dismissedWithCancel(dialog: NSViewController)
    {
        // Don't care
    }
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case self.miniAppsTableView:
                // One row per mini app.
                return self.allMiniAppsAlphabetized.count
            
            case self.containersTableView:
                // One row per container for the selected mini app.
                return selectedMiniAppContainersAlphabetized.count
            
            default:
                return 0
        }
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        switch tableView
        {
        case self.miniAppsTableView:
            
            // No out-of-bounds crashes please.
            guard row < self.allMiniAppsAlphabetized.count else
            {
                return nil
            }
            
            // Instantiate a view for the cell.
            guard let miniAppCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "miniAppRow"), owner: self) as? MiniAppsTableViewCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            miniAppCell.configureForMiniApp(self.allMiniAppsAlphabetized[row])
            return miniAppCell
            
        case self.containersTableView:
            
            // No out-of-bounds crashes please.
            guard row < self.selectedMiniAppContainersAlphabetized.count else
            {
                return nil
            }
            
            // Instantiate a view for the cell.
            guard let containerCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "containerMiniAppRow"), owner: self) as? MiniAppsContainerTableViewCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            containerCell.configureForContainer(self.selectedMiniAppContainersAlphabetized[row])
            return containerCell
            
        default:
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        // The notification object should be the table view that just had a selection change.
        guard let tableView = notification.object as? NSTableView else
        {
            return
        }
        
        // We only care if the user selects someting in the mini app table.
        if tableView == self.miniAppsTableView
        {
            // Figure out which mini app was just selected.
            if tableView.selectedRow < 0 || tableView.selectedRow >= self.allMiniAppsAlphabetized.count
            {
                // No mini app selected, make sure to wipe out the mini-apps data source.
                self.selectedMiniApp = nil
                self.selectedMiniAppContainersAlphabetized = []
                self.editButton.isEnabled = false
            }
            else
            {
                // Update the selected mini app and update the containers data source.
                self.selectedMiniApp = self.allMiniAppsAlphabetized[tableView.selectedRow]
                if let containersArray = self.selectedMiniApp?.containers?.allObjects as? [Container]
                {
                    self.selectedMiniAppContainersAlphabetized = containersArray.sorted { $0.containerName ?? "" < $1.containerName ?? "" }
                }
                else
                {
                    self.selectedMiniAppContainersAlphabetized = []
                }
                self.editButton.isEnabled = true
            }
            
            // Update the UI for that newly selected container.
            self.configureViewForSelectedMiniApp()
        }
    }
}
