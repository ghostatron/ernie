//
//  SwaggerModelsViewController.swift
//  Ernie
//
//  Created by Randy Haid on 12/18/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerModelsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, ModalDialogDelegate
{
    @IBOutlet weak var modelsTableView: NSTableView!
    @IBOutlet weak var propertiesTableView: NSTableView!
    @IBOutlet weak var newButton: NSButton!
    @IBOutlet weak var editButton: NSButton!
    
    private var allModels: [SwaggerObjectModel] = []
    private var selectedModel: SwaggerObjectModel?
    private var selectedModelProperties: [SwaggerModelProperty] = []
    private var launchEditorInEditMode = false
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.buildModelDataSource()
        self.configureViewForSelectedModel()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = "Models"
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?)
    {
        if let editorVC = segue.destinationController as? SwaggerModelEditorViewController
        {
            // We need to know when the editor dialog is completed.
            if self.launchEditorInEditMode
            {
                editorVC.model = self.selectedModel
                editorVC.title = "\(self.selectedModel?.modelName ?? "Model") [Edit]"
            }
            else
            {
                editorVC.title = "Model [New]"
            }
            editorVC.modalDelegate = self
        }
    }
    
    // MARK:- Event Handlers

    @IBAction func newButtonPressed(_ sender: NSButton)
    {
        self.launchEditorInEditMode = false
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toModelEditor"), sender: self)
    }
    
    @IBAction func editButtonPressed(_ sender: NSButton)
    {
        if self.selectedModel != nil
        {
            self.launchEditorInEditMode = true
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toModelEditor"), sender: self)
        }
    }
    
    // MARK:- ModalDialogDelegate
    
    // If the "Edit" or "New" dialog returns with "OK", then we need to refresh the page.
    func dismissedWithOK(dialog: NSViewController)
    {
        // Reload the table.
        self.buildModelDataSource()
        self.modelsTableView.reloadData()
        self.configureViewForSelectedModel()
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
        case self.modelsTableView:
            // One row per model
            return self.allModels.count
            
        case self.propertiesTableView:
            // One row per property for the selected model.
            return self.selectedModelProperties.count
            
        default:
            return 0
        }
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        switch tableView
        {
        case self.modelsTableView:
            
            // No out-of-bounds crashes please.
            guard row < self.allModels.count else
            {
                return nil
            }
            
            // Instantiate a view for the cell.
            guard let modelCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerModelRow"), owner: self) as? SwaggerModelTableViewCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            modelCell.configureFor(model: self.allModels[row])
            return modelCell
            
        case self.propertiesTableView:
            
            // No out-of-bounds crashes please.
            guard row < self.selectedModelProperties.count else
            {
                return nil
            }
            
            // Instantiate a view for the cell.
            guard let propertyCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerPropertyRow"), owner: self) as? SwaggerPropertyTableViewCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            propertyCell.configureForProperty(self.selectedModelProperties[row])
            return propertyCell
            
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
        
        // We only care if the user selects someting in the models table.
        if tableView == self.modelsTableView
        {
            // Figure out which model was just selected.
            if tableView.selectedRow < 0 || tableView.selectedRow >= self.allModels.count
            {
                // No model selected, make sure to wipe out the models data source.
                self.selectedModel = nil
                self.selectedModelProperties = []
                self.editButton.isEnabled = false
            }
            else
            {
                // Update the selected model and update the properties data source.
                self.selectedModel = self.allModels[tableView.selectedRow]
                if let propertiesArray = self.selectedModel?.modelProperties
                {
                    self.selectedModelProperties = propertiesArray.sorted { $0.propertyName < $1.propertyName }
                }
                else
                {
                    self.selectedModelProperties = []
                }
                self.editButton.isEnabled = true
            }

            // Update the UI for that newly selected container.
            self.configureViewForSelectedModel()
        }
    }
    
    // MARK:- Private Methods
    
    private func buildModelDataSource()
    {
        let unsortedModels = SwaggerObjectModel.getAllModels()
        self.allModels = unsortedModels.sorted { $0.modelName < $1.modelName }
    }
    
    private func configureViewForSelectedModel()
    {
        self.editButton.isEnabled = (self.selectedModel != nil)
        self.propertiesTableView.reloadData()
    }
}
