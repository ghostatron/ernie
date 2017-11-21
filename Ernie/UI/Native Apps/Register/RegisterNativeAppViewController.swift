//
//  RegisterNativeAppViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/16/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class RegisterNativeAppViewController: NSViewController
{
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var folderLabel: NSTextField!
    @IBOutlet var descriptionTextView: NSTextView!
    
    var delegate: ModalDialogDelegate?
    
    // MARK:- View Lifecycle
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = "Register Native App"
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
            self.folderLabel.stringValue = dialog.url?.absoluteString ?? ""
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        // Let the delegate know we're canceled and then dismiss.
        self.delegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func saveButtonPressed(_ sender: NSButton)
    {
        // Create a new NativeApp object populated with the data entered on the screen.
        let moc = AppDelegate.mainManagedObjectContext()
        let nativeApp = NSEntityDescription.insertNewObject(forEntityName: "NativeApp", into: moc) as! NativeApp
        nativeApp.appName = self.nameTextField.stringValue
        nativeApp.appDescription = self.descriptionTextView.string
        nativeApp.appFolder = folderLabel.stringValue
        
        // Save, let the delegate know we're dismissing with via the "OK" button.
        try? moc.save()
        self.delegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
}
