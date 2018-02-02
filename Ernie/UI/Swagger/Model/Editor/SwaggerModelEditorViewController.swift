//
//  SwaggerModelEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 12/19/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerModelEditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, SwaggerPropertyDetailTableViewCellDelegate, SwaggerModelNewPropertyTableCellDelegate, ModalDialogDelegate
{
    var modalDelegate: ModalDialogDelegate?
    var model: SwaggerObjectModel?
    private var sortedProperties: [SwaggerModelProperty] = []
    private var sortedReferences: [SwaggerContainer] = []
    private var launchEditorInEditMode = false
    private var propertyForEditor: SwaggerModelProperty?
    
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
        self.modelNameTextField.stringValue = self.model?.modelName ?? ""
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = self.model?.modelName ?? "New Model"
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?)
    {
        if let editorVC = segue.destinationController as? SwaggerPropertyEditorViewController
        {
            // We need to know when the editor dialog is completed.
            if self.launchEditorInEditMode
            {
                editorVC.property = self.propertyForEditor
                editorVC.title = "\(self.propertyForEditor?.propertyName ?? "Property") [Edit]"
            }
            else
            {
                editorVC.title = "Property [New]"
            }
            editorVC.modalDelegate = self
        }
    }
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
        case self.propertiesTableView:
            // One row per property and 1 more for adding new properties.
            return self.sortedProperties.count + 1

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
            if row < self.sortedProperties.count
            {
                // Instantiate a view for the cell.
                guard let propertyCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerPropertyDetailCell"), owner: self) as? SwaggerPropertyDetailTableViewCell else
                {
                    return nil
                }
                
                // Configure the view and return it.
                propertyCell.buttonDelegate = self
                propertyCell.configureForProperty(self.sortedProperties[row])
                return propertyCell
            }
            else if row == self.sortedProperties.count
            {
                // Instantiate a view for the cell.
                guard let newPropertyCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerNewPropertyCell"), owner: self) as? SwaggerModelNewPropertyTableCell else
                {
                    return nil
                }
                newPropertyCell.delegate = self
                return newPropertyCell
            }
            else
            {
                return nil
            }

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
    
    @IBAction func rowDoubleClicked(_ sender: NSTableView)
    {
        // Out-of-range protection before selecting which property to launch the editor for.
        guard self.propertiesTableView.selectedRow < self.sortedProperties.count else
        {
            return
        }
        
        // Launch the editor for the property that was double-clicked.
        self.launchEditorInEditMode = true
        self.propertyForEditor = self.sortedProperties[self.propertiesTableView.selectedRow]
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toPropertyEditor"), sender: self)
    }
    
    /**
     Dismiss and don't save any changes to the model if the user cancels.
     */
    @IBAction func cancelButtonPressed(_ sender: Any)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    /**
     Save changes to the model and dismiss.
     */
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
        if self.modelNameTextField.stringValue.count > 0
        {
            self.model?.modelName = self.modelNameTextField.stringValue
        }
        self.model?.modelProperties = self.sortedProperties
        self.model?.refreshCoreDataObject(autoSave: true)
        
        // Leave and inform the delegate.
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
    
    // MARK:- Private Methods
    
    private func buildDataSources()
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
    
    /**
     This is triggered when the user taps on the edit button in one of the property detail cells.
     Need to launch the property editor and set up internals so that we can pass along the
     property that is to be edited.
     */
    func editButtonPressed(sender: SwaggerPropertyDetailTableViewCell, property: SwaggerModelProperty?)
    {
        self.launchEditorInEditMode = true
        self.propertyForEditor = property
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toPropertyEditor"), sender: self)
    }
    
    /**
     This is triggered when the user taps on the delete button in one of the property detail cells.
     Need to remove that property from the data source and reload the table.
     */
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
    
    // MARK:- SwaggerModelNewPropertyTableCellDelegate
    
    /**
     This is triggered when the user taps on the new property button in the last property cell.
     Need to launch the property editor for creating a new property.
     */
    func newButtonPressed(sender: SwaggerModelNewPropertyTableCell)
    {
        self.launchEditorInEditMode = false
        self.propertyForEditor = nil
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toPropertyEditor"), sender: self)
    }
    
    // MARK:- ModalDialogDelegate
    
    /**
     This is triggered when the user dismisses the property editor via the ok/save button.
     Need to update the properties data source and reload the table.
     */
    func dismissedWithOK(dialog: NSViewController)
    {
        guard let editorVC = dialog as? SwaggerPropertyEditorViewController, let property = editorVC.property else
        {
            return
        }
        
        // Grab the new property and store it in sortedReferences
        if self.launchEditorInEditMode
        {
            // Since we edited an existing property, no need to re-add it to the data source.
            // We do still want to resort though, b/c the name may have changed.
        }
        else
        {
            self.sortedProperties.append(property)
        }
        self.sortedProperties.sort { $0.propertyName < $1.propertyName }
        self.propertiesTableView.reloadData()
    }
    
    /**
     This is triggered when the user dismisses the property editor via the cancel button.
     */
    func dismissedWithCancel(dialog: NSViewController)
    {
        // Don't care...
    }
}
