//
//  SwaggerModelEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 12/19/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerModelEditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, SwaggerPropertyDetailTableViewCellDelegate
{
    var modalDelegate: ModalDialogDelegate?
    var model: SwaggerObjectModel?
    private var sortedProperties: [SwaggerModelProperty] = []
    private var sortedReferences: [SwaggerContainer] = []
    
    @IBOutlet weak var referencesTableView: NSTableView!
    @IBOutlet weak var propertiesTableView: NSTableView!
    @IBOutlet weak var modelNameTextField: NSTextField!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.buildDataSources()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = self.model?.modelName ?? "New Model"
    }
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
        case self.propertiesTableView:
            // One row per property
            return self.sortedProperties.count

        case self.referencesTableView:
            // One row per container that references this model.
            return self.sortedReferences.count

        default:
            return 0
        }
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        switch tableView
        {
        case self.propertiesTableView:

            // No out-of-bounds crashes please.
            guard row < self.sortedProperties.count else
            {
                return nil
            }

            // Instantiate a view for the cell.
            guard let propertyCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerPropertyDetailCell"), owner: self) as? SwaggerPropertyDetailTableViewCell else
            {
                return nil
            }

            // Configure the view and return it.
            propertyCell.configureForProperty(self.sortedProperties[row])
            return propertyCell

        case self.referencesTableView:

            // No out-of-bounds crashes please.
            guard row < self.sortedReferences.count else
            {
                return nil
            }

            // Instantiate a view for the cell.
            guard let referenceCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerModelReferenceCell"), owner: self) as? SwaggerModelReferenceTableViewCell else
            {
                return nil
            }

            // Configure the view and return it.
            referenceCell.configureForContainer(self.sortedReferences[row])
            return referenceCell

        default:
            return nil
        }
    }
    
    // MARK:- Event Handlers
    
    @IBAction func cancelButtonPressed(_ sender: Any)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func saveButtonPressed(_ sender: NSButton)
    {
        guard self.modelNameTextField.stringValue.count > 0 else
        {
            return
        }
        
        // Save the changes that were made.
        if self.model == nil
        {
            self.model = SwaggerObjectModel(name: self.modelNameTextField.stringValue)
        }
        self.model?.modelName = self.modelNameTextField.stringValue
        self.model?.modelProperties = self.sortedProperties
        self.model?.refreshCoreDataObject(autoSave: true)
        
        // Leave and inform the delegate.
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
    
    // MARK:- Private Methods
    
    func buildDataSources()
    {
        if let model = self.model
        {
            self.sortedProperties = model.modelProperties.sorted  { $0.propertyName < $1.propertyName }
            var unsortedContainers: [SwaggerContainer] = []
            for swContainer in model.avatarOf?.modelContainers?.allObjects as? [SWContainer] ?? []
            {
                if let container = SwaggerContainer(avatarOf: swContainer)
                {
                    unsortedContainers.append(container)
                }
            }
            self.sortedReferences = unsortedContainers.sorted  { $0.containerTitle ?? "" < $1.containerTitle ?? "" }
        }
    }
    
    // MARK:- SwaggerPropertyDetailTableViewCellDelegate
    
    func editButtonPressed(sender: SwaggerPropertyDetailTableViewCell, property: SwaggerModelProperty?)
    {
        // Update the UI.
        self.propertiesTableView.reloadData()
    }
    
    func deleteButtonPressed(sender: SwaggerPropertyDetailTableViewCell, property: SwaggerModelProperty?)
    {
        // Locate the property in our data source.
        var indexOfDeletion = 0
        for existingProperty in self.sortedProperties
        {
            if existingProperty === property
            {
                break
            }
            indexOfDeletion += 1
        }
        
        // Remove the property from our data source.
        if indexOfDeletion < self.sortedProperties.count
        {
            self.sortedProperties.remove(at: indexOfDeletion)
        }
        
        // Update the UI.
        self.propertiesTableView.reloadData()
    }
}
