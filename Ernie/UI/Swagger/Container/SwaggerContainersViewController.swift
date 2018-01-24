//
//  SwaggerContainersViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/23/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

class SwaggerContainersViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, SwaggerContainerTableCellDelegate, SwaggerNewContainerTableCellDelegate, ModalDialogDelegate
{
    @IBOutlet weak var containersTableView: NSTableView!
    @IBOutlet weak var methodListLabel: NSTextField!
    @IBOutlet weak var modelListLabel: NSTextField!
    @IBOutlet weak var editButton: NSButton!
    
    private var sortedContainers: [SwaggerContainer] = []
    private var selectedContainer: SwaggerContainer?
    private var launchEditorInEditMode = false
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.buildContainersDataSource()
        self.editButton.isEnabled = false
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?)
    {
        if let editorVC = segue.destinationController as? SwaggerContainerEditorViewController
        {
            // We need to know when the editor dialog is completed.
            if self.launchEditorInEditMode
            {
                editorVC.container = self.selectedContainer
            }
            editorVC.modalDelegate = self
        }
    }
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        // One row per container plus one for the "New Container" cell.
        return self.sortedContainers.count + 1
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        // No out-of-bounds crashes please.
        guard row <= self.sortedContainers.count else
        {
            return nil
        }
        
        // Instantiate a view for the cell.
        if row < self.sortedContainers.count
        {
            guard let containerCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerContainerTableCell"), owner: self) as? SwaggerContainerTableCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            containerCell.delegate = self
            containerCell.configureFor(container: self.sortedContainers[row])
            return containerCell
        }
        else
        {
            guard let newContainerCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerNewContainerTableCell"), owner: self) as? SwaggerNewContainerTableCell else
            {
                return nil
            }
            newContainerCell.delegate = self
            return newContainerCell
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        // The notification object should be the table view that just had a selection change.
        guard let tableView = notification.object as? NSTableView else
        {
            return
        }
        
        // Figure out which continer was just selected.
        if tableView.selectedRow < 0 || tableView.selectedRow >= self.sortedContainers.count
        {
            // No container selected, make sure to wipe out the arguments data source.
            self.selectedContainer = nil
            self.editButton.isEnabled = false
        }
        else
        {
            // Update the selected container.
            self.selectedContainer = self.sortedContainers[tableView.selectedRow]
            self.editButton.isEnabled = true
        }
        
        // Update the UI for that newly selected container.
        self.configureViewForSelectedContainer()
    }
    
    // MARK:- ModalDialogDelegate
    
    // If the "Edit" or "New" dialog returns with "OK", then we need to refresh the page.
    func dismissedWithOK(dialog: NSViewController)
    {
        // Reload the table.
        self.buildContainersDataSource()
        self.containersTableView.reloadData()
        self.configureViewForSelectedContainer()
    }
    
    func dismissedWithCancel(dialog: NSViewController)
    {
        // Don't care
    }
    
    // MARK:- SwaggerContainerTableCellDelegate
    
    func deleteButtonPressedForContainerInCell(_ containerCell: SwaggerContainerTableCell, container: SwaggerContainer?)
    {
        guard let container = container else
        {
            return
        }
        
        // Locate the container in our data source.
        var indexOfDeletion = 0
        for existingContainer in self.sortedContainers
        {
            if existingContainer === container
            {
                break
            }
            indexOfDeletion += 1
        }
        
        // Remove the container from our data source.
        if indexOfDeletion < self.sortedContainers.count
        {
            self.sortedContainers.remove(at: indexOfDeletion)
        }
        
        // Update the UI.
        self.containersTableView.reloadData()
    }
    
    // MARK:- SwaggerNewContainerTableCellDelegate
    
    func newButtonPressed(sender: SwaggerNewContainerTableCell)
    {
        self.selectedContainer = nil
        self.launchEditorInEditMode = false
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toContainerEditor"), sender: self)
    }
    
    
    // MARK:- Event Handlers
    
    @IBAction func doneButtonPressed(_ sender: NSButton)
    {
        self.dismissViewController(self)
    }
    
    @IBAction func editButtonPressed(_ sender: NSButton)
    {
        guard let _ = self.selectedContainer else
        {
            return
        }
        
        self.launchEditorInEditMode = true
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toContainerEditor"), sender: self)
    }
    
    // MARK:- Private Methods

    private func buildContainersDataSource()
    {
        let unsortedContainers = SwaggerContainer.getAllContainers()
        self.sortedContainers = unsortedContainers.sorted { $0.containerTitle ?? "" < $1.containerTitle ?? "" }
    }
    
    private func configureViewForSelectedContainer()
    {
        if let selectedContainer = self.selectedContainer
        {
            var methodNames: [String] = []
            for method in selectedContainer.containerMethods
            {
                methodNames.append(method.methodName)
            }
            self.methodListLabel.stringValue = methodNames.joined(separator: ", ")
            
            var modelNames: [String] = []
            for model in selectedContainer.containerModels
            {
                modelNames.append(model.modelName)
            }
            self.modelListLabel.stringValue = modelNames.joined(separator: ", ")
        }
        else
        {
            self.methodListLabel.stringValue = ""
            self.modelListLabel.stringValue = ""
        }
    }
}