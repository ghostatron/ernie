//
//  MiniAppEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class MiniAppEditorViewController: NSViewController
{
    enum EditorMode
    {
        case New, Register, Edit
    }
    var mode = EditorMode.New
    
    /**
     The data source for MiniAppEditorViewController.  If this is provided before
     viewDidLoad, then it will be edited.  Otherwise, a new one will be create when
     the save button is pressed.  If passed as nil, and the user cancels, then it will
     still be nil.
     */
    var miniApp: MiniApp?
    
    /// Notified when ContainerEditorViewController is dismissed.
    var modalDelegate: ModalDialogDelegate?
    
    // MARK:- IBOutlet Properties
    
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var folderButton: NSButton!
    @IBOutlet weak var folderTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let miniAppToEdit = self.miniApp
        {
            self.nameTextField.stringValue = miniAppToEdit.miniAppName ?? "<No Name>"
            self.folderTextField.stringValue = miniAppToEdit.miniAppFolder ?? "<No Folder>"
            self.descriptionTextField.stringValue = miniAppToEdit.miniAppDescription ?? ""
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
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
    }
    
    private func configureForNewMode()
    {
        self.saveButton.title = "Create"
    }
    
    private func configureForRegisterMode()
    {
        self.saveButton.title = "Save"
    }
    
    private func configureForEditMode()
    {
        self.saveButton.title = "Save"
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
            self.folderTextField.stringValue = dialog.url?.absoluteString ?? ""
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    private func saveMiniAppToCoreData()
    {
        // Grab the mini app object to update, or create one if needed.
        let moc = AppDelegate.mainManagedObjectContext()
        var miniAppToSave: MiniApp!
        if self.miniApp != nil
        {
            miniAppToSave = self.miniApp!
        }
        else
        {
            miniAppToSave = NSEntityDescription.insertNewObject(forEntityName: "MiniApp", into: moc) as! MiniApp
        }
        
        // Copy the info from the screen to the container object and save.
        miniAppToSave.miniAppName = self.nameTextField.stringValue
        miniAppToSave.miniAppFolder = self.folderTextField.stringValue
        miniAppToSave.miniAppDescription = self.descriptionTextField.stringValue
        try? moc.save()
    }
    
    @IBAction func saveButtonPressed(_ sender: NSButton)
    {
        if self.miniApp != nil
        {
            // Update the existing mini app (i.e. don't need ERN to create one).
            self.saveMiniAppToCoreData()
            
            // Dismiss and let the delegate know we're done.
            self.modalDelegate?.dismissedWithOK(dialog: self)
            self.dismiss(self)
        }
        else
        {
            // Disable the UI and turn on the progress indicator.
            self.nameTextField.isEnabled = false
            self.folderButton.isEnabled = false
            self.folderTextField.isEnabled = false
            self.descriptionTextField.isEnabled = false
            self.saveButton.isEnabled = false
            self.cancelButton.isEnabled = false
            self.progressIndicator.startAnimation(self)
            
            ErnWrapper.createMiniApp(parentFolderPath: self.folderTextField.stringValue, createFolderIfNeeded: true, appName: self.nameTextField.stringValue, completion: { (response) in
                
                DispatchQueue.main.async {
                    
                    // Save the mini app we just created.
                    self.saveMiniAppToCoreData()
                    
                    // Dismiss and let the delegate know we're done.
                    self.modalDelegate?.dismissedWithOK(dialog: self)
                    self.progressIndicator.stopAnimation(self)
                    self.dismiss(self)
                    
                }
            })
        }
    }
}
