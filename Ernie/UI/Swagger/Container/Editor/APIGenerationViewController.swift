//
//  APIGenerationViewController.swift
//  Ernie
//
//  Created by Randy Haid on 2/21/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

class APIGenerationViewController: NSViewController
{
    @IBOutlet weak var apiNameTextField: NSTextField!
    @IBOutlet weak var npmScopeTextField: NSTextField!
    @IBOutlet weak var npmPackageNameTextField: NSTextField!
    @IBOutlet weak var apiVersionTextField: NSTextField!
    @IBOutlet weak var authorTextField: NSTextField!
    @IBOutlet weak var swaggerFileLocationTextField: NSTextField!
    
    @IBAction func folderButtonPressed(_ sender: NSButton)
    {
        // Display a file browser that only allows the user to select only non-hidden files (no folders).
        let dialog = NSOpenPanel()
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        if dialog.runModal() == NSApplication.ModalResponse.OK
        {
            // Grab the URL selected by the user and update the UI.
            self.swaggerFileLocationTextField.stringValue = dialog.url?.absoluteString ?? ""
        }
    }
    
    @IBAction func generateButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.dismiss(self)
    }
}
