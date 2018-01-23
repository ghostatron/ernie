//
//  SwaggerMethodResponsesViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/3/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerMethodResponsesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSComboBoxDataSource
{
    @IBOutlet weak var responsesTableView: NSTableView!
    @IBOutlet weak var httpCodeTextField: NSTextField!
    @IBOutlet weak var arrayOfCheckBox: NSButton!
    @IBOutlet weak var dataTypeComboBox: NSComboBox!
    @IBOutlet var descriptionTextView: NSTextView!
    @IBOutlet weak var editButton: NSButton!
    
    var modalDelegate: ModalDialogDelegate?
    private var isEditEnabled = false
    
    // Responses variables
    var responses: [SwaggerResponse]?
    private var sortedResponses: [SwaggerResponse] = []
    var selectedResponse: SwaggerResponse?
    
    // Combo box variables
    private var sortedPrimitiveTypes: [String] = []
    private var sortedModels: [SwaggerObjectModel] = []
    private var orderedDataTypeNames: [String] = []
    private var comboBoxesInitialized = false

    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureForResponses()
        self.configureForEditing(false)
        self.buildDataTypeDataSource()
        self.comboBoxesInitialized = true
    }
    
    // MARK:- Private Methods
    
    private func configureForResponses()
    {
        if let responses = self.responses
        {
            self.sortedResponses = responses.sorted { $0.responseHttpCode < $1.responseHttpCode }
        }
        else
        {
            self.sortedResponses = []
        }
        self.responsesTableView.reloadData()
    }
    
    private func configureForSelectedResponse()
    {
        if let selectedResponse = self.selectedResponse
        {
            self.httpCodeTextField.stringValue = selectedResponse.responseHttpCode
            self.descriptionTextView.string = selectedResponse.responseDescription ?? ""
            self.arrayOfCheckBox.state = selectedResponse.responseDataType.arrayDataType == nil ? NSControl.StateValue.off : NSControl.StateValue.on
            
            // Special case for array, we want to select the type of the array rather than use the "Array"
            // primitive type directly.
            if let arrayDataType = selectedResponse.responseDataType.arrayDataType
            {
                self.dataTypeComboBox.stringValue = arrayDataType.primitiveDataType?.rawValue ?? ""
            }
            else
            {
                self.dataTypeComboBox.stringValue = selectedResponse.responseDataType.primitiveDataType?.rawValue ?? ""
            }
        }
        else
        {
            self.httpCodeTextField.stringValue = ""
            self.descriptionTextView.string = ""
            self.arrayOfCheckBox.state = NSControl.StateValue.off
            self.dataTypeComboBox.stringValue = ""
        }
    }
    
    private func configureForEditing(_ isEditing: Bool)
    {
        self.httpCodeTextField.isEnabled = isEditing
        self.arrayOfCheckBox.isEnabled = isEditing
        self.dataTypeComboBox.isEnabled = isEditing
        self.descriptionTextView.isEditable = isEditing
        let editButtonImageName = isEditing ? NSImage.Name.lockUnlockedTemplate : NSImage.Name.lockLockedTemplate
        self.editButton.image = NSImage(named: editButtonImageName)
        self.isEditEnabled = isEditing
    }
    
    private func buildDataTypeDataSource()
    {
        // The data type combo box data source.
        self.orderedDataTypeNames = []
        
        // Add the primitive types first.
        self.sortedPrimitiveTypes = [
            SwaggerDataTypeEnum.Boolean.rawValue,
            SwaggerDataTypeEnum.Integer.rawValue,
            SwaggerDataTypeEnum.String.rawValue
        ]
        for typeName in self.sortedPrimitiveTypes
        {
            self.orderedDataTypeNames.append(typeName)
        }
        
        // Then add the models.
        self.sortedModels = SwaggerObjectModel.getAllModels(sorted: true)
        for model in self.sortedModels
        {
            self.orderedDataTypeNames.append(model.modelName)
        }
    }
    
    // MARK:- Event Handlers
    
    @IBAction func editButtonPressed(_ sender: Any)
    {
        // Can't edit nothing...
        guard let _ = self.selectedResponse else
        {
            return
        }
        
        // If they just turned off edit, then save changes to the selected response.
        if let response = self.selectedResponse, self.isEditEnabled
        {
            // Determine the index to use when looking up the data type.
            var dataTypeIndex = self.dataTypeComboBox.indexOfSelectedItem
            if dataTypeIndex < 0
            {
                dataTypeIndex = self.orderedDataTypeNames.index(of: self.dataTypeComboBox.stringValue) ?? -1
            }
            guard dataTypeIndex > -1 else
            {
                return
            }
            
            // Figure out what data type they have selected.
            var baseDataType: SwaggerDataType!
            if dataTypeIndex < self.sortedPrimitiveTypes.count
            {
                // It's a primitive type
                guard let primitiveType = SwaggerDataTypeEnum(rawValue: self.sortedPrimitiveTypes[dataTypeIndex]) else
                {
                    return
                }
                baseDataType = SwaggerDataType(primitiveType: primitiveType)
            }
            else if dataTypeIndex < self.sortedPrimitiveTypes.count + self.sortedModels.count
            {
                // It's a model
                let modelIndex = dataTypeIndex - self.sortedPrimitiveTypes.count
                guard modelIndex < self.sortedModels.count else
                {
                    return
                }
                baseDataType = SwaggerDataType(withObject: self.sortedModels[modelIndex])
            }
            else
            {
                // Index out of bounds.
                return
            }
            
            // Embed that data type in an array if necessary.
            var dataTypeForResponse: SwaggerDataType = baseDataType
            if self.arrayOfCheckBox.state == NSControl.StateValue.on
            {
                dataTypeForResponse = SwaggerDataType(asArrayOf: baseDataType)
            }
            
            // Finally...update the response object with what is in the editor.
            response.responseHttpCode = self.httpCodeTextField.stringValue
            response.responseDescription = self.descriptionTextView.string
            response.responseDataType = dataTypeForResponse
        }
        
        // Toggle the edit mode.
        self.configureForEditing(!self.isEditEnabled)
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func okButtonPressed(_ sender: NSButton)
    {
        self.responses = self.sortedResponses
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return self.sortedResponses.count
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        return nil
//        switch tableView
//        {
//        case self.miniAppsTableView:
//
//            // No out-of-bounds crashes please.
//            guard row < self.allMiniAppsAlphabetized.count else
//            {
//                return nil
//            }
//
//            // Instantiate a view for the cell.
//            guard let miniAppCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "miniAppRow"), owner: self) as? MiniAppsTableViewCell else
//            {
//                return nil
//            }
//
//            // Configure the view and return it.
//            miniAppCell.configureForMiniApp(self.allMiniAppsAlphabetized[row])
//            return miniAppCell
//
//        case self.containersTableView:
//
//            // No out-of-bounds crashes please.
//            guard row < self.selectedMiniAppContainersAlphabetized.count else
//            {
//                return nil
//            }
//
//            // Instantiate a view for the cell.
//            guard let containerCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "containerMiniAppRow"), owner: self) as? MiniAppsContainerTableViewCell else
//            {
//                return nil
//            }
//
//            // Configure the view and return it.
//            containerCell.configureForContainer(self.selectedMiniAppContainersAlphabetized[row])
//            return containerCell
//
//        default:
//            return nil
//        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        // The notification object should be the table view that just had a selection change.
        guard let tableView = notification.object as? NSTableView else
        {
            return
        }
        
        // Figure out which response was just selected.
        if tableView.selectedRow < 0 || tableView.selectedRow >= self.responses?.count ?? 0
        {
            // No response selected.
            self.selectedResponse = nil
        }
        else
        {
            // Update the selected response.
            self.selectedResponse = self.responses?[tableView.selectedRow]
        }
        
        // Update the UI for that newly selected response.
        self.configureForEditing(false)
        self.configureForSelectedResponse()
    }
    
    // MARK:- NSComboBoxDataSource
    
    func numberOfItems(in comboBox: NSComboBox) -> Int
    {
        guard self.comboBoxesInitialized else
        {
            return 0
        }
        return self.orderedDataTypeNames.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any?
    {
        if index < 0
        {
            return nil
        }
        
        guard index < self.orderedDataTypeNames.count else
        {
            return nil
        }
        return self.orderedDataTypeNames[index]
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int
    {
        return self.orderedDataTypeNames.index(of: string) ?? -1
    }
}
