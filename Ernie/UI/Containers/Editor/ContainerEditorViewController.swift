//
//  ContainerEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/21/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class ContainerEditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, MiniAppSelectionDelegate
{
    enum EditorMode
    {
        case New, Register, Edit
    }
    var mode = EditorMode.New
    
    /// Notified when ContainerEditorViewController is dismissed.
    var modalDelegate: ModalDialogDelegate?
    
    /**
     The data source for ContainerEditorViewController.  If this is provided before
     viewDidLoad, then it will be edited.  Otherwise, a new one will be create when
     the save button is pressed.  If passed as nil, and the user cancels, then it will
     still be nil.
     */
    var container: Container?
    
    /// The mini apps selected in the table view.
    private var selectedMiniApps: NSMutableSet = []
    
    /// The data source for the mini apps selection table.
    private var allAvailableMiniAppsAlphabetized: [MiniApp] = []
    
    // MARK:- IBOutlet Properties

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var containerNameTextField: NSTextField!
    @IBOutlet weak var containerFolderTextField: NSTextField!
    @IBOutlet weak var containerDescriptionTextField: NSTextField!
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let containerToEdit = self.container
        {
            self.containerNameTextField.stringValue = containerToEdit.containerName ?? "<No Name>"
            self.containerFolderTextField.stringValue = containerToEdit.containerFolder ?? "<No Folder>"
            self.containerDescriptionTextField.stringValue = containerToEdit.containerDescription ?? ""
        }
        
        switch self.mode
        {
            case .New:
                self.configureForNewMode()
            
            case .Edit:
                self.configureForEditMode()
            
            case .Register:
                self.configureForRegisterMode()
        }
        
        // Make a copy of the mini-apps set b/c we don't want to mess with the real set until save.
        if let miniAppsArray = self.container?.miniApps?.allObjects as? [MiniApp]
        {
            self.selectedMiniApps = NSMutableSet(array: miniAppsArray)
        }
        
        // Build the list of available mini apps.
        self.generateMiniAppsDataSource()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = self.container?.containerName ?? "New Container"
    }
    
    private func configureForNewMode()
    {
        self.titleLabel.stringValue = "Container Editor (New)"
    }
    
    private func configureForRegisterMode()
    {
        self.titleLabel.stringValue = "Container Editor (Register Existing)"
    }
    
    private func configureForEditMode()
    {
        self.titleLabel.stringValue = "Container Editor (Edit Existing)"
    }
    
    // MARK:- MiniAppSelectionDelegate
    
    func miniAppSelected(_ miniApp: MiniApp)
    {
        self.selectedMiniApps.add(miniApp)
    }
    
    func miniAppDeselected(_ miniApp: MiniApp)
    {
        self.selectedMiniApps.remove(miniApp)
    }
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        // One row per mini app.
        return self.allAvailableMiniAppsAlphabetized.count
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        // No out-of-bounds crashes please.
        guard row < self.allAvailableMiniAppsAlphabetized.count else
        {
            return nil
        }
        
        // Instantiate a view for the cell.
        guard let miniAppCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "selectMiniAppRow"), owner: self) as? MiniAppSelectionTableViewCell else
        {
            return nil
        }
        
        // Configure the view and return it.
        let miniAppForCell = self.allAvailableMiniAppsAlphabetized[row]
        let isSelected = self.selectedMiniApps.contains(miniAppForCell)
        miniAppCell.configureForMiniApp(miniAppForCell, isSelected: isSelected)
        miniAppCell.selectionDelegate = self
        return miniAppCell
    }
    
    // MARK:- Private Methods
    
    /**
     Fetches all MiniApp objects and stores them in self.allAvailableMiniAppsAlphabetized
     alphabetically by miniAppName.
     */
    private func generateMiniAppsDataSource()
    {
        let request: NSFetchRequest<MiniApp> = MiniApp.fetchRequest()
        let alphabeticalSort = NSSortDescriptor(key: "miniAppName", ascending: true)
        request.sortDescriptors = [alphabeticalSort]
        if let allMiniApps = try? AppDelegate.mainManagedObjectContext().fetch(request)
        {
            self.allAvailableMiniAppsAlphabetized = allMiniApps
        }
        else
        {
            self.allAvailableMiniAppsAlphabetized = []
        }
    }
    
    // MARK:- Event Handlers
    
    @IBAction func folderButtonPressed(_ sender: NSButton)
    {
        // Display a file browser that only allows the user to select non-hidden folders (no files).
        let dialog = NSOpenPanel()
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        if dialog.runModal() == NSApplication.ModalResponse.OK
        {
            // Grab the URL selected by the user and update the UI.
            self.containerFolderTextField.stringValue = dialog.url?.absoluteString ?? ""
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: NSButton)
    {
        // Grab the container object to update, or create one if needed.
        let moc = AppDelegate.mainManagedObjectContext()
        var containerToSave: Container!
        if self.container != nil
        {
            containerToSave = self.container!
        }
        else
        {
           containerToSave = NSEntityDescription.insertNewObject(forEntityName: "Container", into: moc) as! Container
        }
        
        // Copy the info from the screen to the container object.
        containerToSave.containerName = self.containerNameTextField.stringValue
        containerToSave.containerFolder = self.containerFolderTextField.stringValue
        containerToSave.containerDescription = self.containerDescriptionTextField.stringValue
        
        // Remove all of this container's old miniApps and then add the ones that are now selected.
        if let previousMiniApps = containerToSave.miniApps
        {
            containerToSave.removeFromMiniApps(previousMiniApps)
        }
        containerToSave.addToMiniApps(self.selectedMiniApps)
        
        try? moc.save()
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
}
