//
//  SwaggerContainerEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/24/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

class SwaggerContainerEditorViewController: NSViewController
{
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var ownerTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var methodsTableView: NSTableView!
    @IBOutlet weak var modelsTableView: NSTableView!
    
    var modalDelegate: ModalDialogDelegate?
    var container: SwaggerContainer?
    
    // MARK:- Event Handlers
    
    @IBAction func addMethodButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func addModelButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func generateSwaggerButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func saveButtonPressed(_ sender: NSButton)
    {
    }
}
