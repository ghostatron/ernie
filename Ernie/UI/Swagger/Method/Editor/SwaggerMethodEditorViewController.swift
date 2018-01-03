//
//  SwaggerMethodEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/2/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerMethodEditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, ModalDialogDelegate, NSComboBoxDataSource
{
    var modalDelegate: ModalDialogDelegate?
    var method: SwaggerMethod?
    private var sortedArguments: [SwaggerMethodArgument] = []
    private var comboBoxesInitialized = false
    private var sortedMethodTypes: [SwaggerMethodTypeEnum] = [.DELETE, .EVENT, .GET, .POST, .PUT]

    @IBOutlet weak var methodNameTextField: NSTextField!
    @IBOutlet weak var methodDescriptionTextField: NSTextField!
    @IBOutlet weak var methodSummaryTextField: NSTextField!
    @IBOutlet weak var methodTypeComboBox: NSComboBox!
    @IBOutlet weak var productsButton: NSButton!
    @IBOutlet weak var responsesButton: NSButton!
    @IBOutlet weak var argumentsTableView: NSTableView!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.comboBoxesInitialized = true
        self.configureForMethod()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = self.method?.methodName ?? "New Method"
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?)
    {
//        if let editorVC = segue.destinationController as? SwaggerPropertyEditorViewController
//        {
//            // We need to know when the editor dialog is completed.
//            if self.launchEditorInEditMode
//            {
//                editorVC.property = self.propertyForEditor
//            }
//            editorVC.modalDelegate = self
//        }
    }
    
    // MARK:- Private Methods
    
    private func configureForMethod()
    {
        self.methodNameTextField.stringValue = self.method?.methodName ?? ""
        self.methodDescriptionTextField.stringValue = self.method?.methodDescription ?? ""
        self.methodSummaryTextField.stringValue = self.method?.methodSummary ?? ""
        self.sortedArguments = self.method?.methodArguments.sorted { $0.argumentName < $1.argumentName } ?? []
        self.methodTypeComboBox.stringValue = self.method?.methodType.rawValue ?? "GET"
    }
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        // One row per method argument.
        return self.sortedArguments.count
    }
    
    // MARK:- NSComboBoxDataSource
    
    func numberOfItems(in comboBox: NSComboBox) -> Int
    {
        guard self.comboBoxesInitialized else
        {
            return 0
        }
        return self.sortedMethodTypes.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any?
    {
        if index < 0 || index >= self.sortedMethodTypes.count
        {
            return nil
        }
        return self.sortedMethodTypes[index].rawValue
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int
    {
        for (typeIndex, methodType) in self.sortedMethodTypes.enumerated()
        {
            if methodType.rawValue == string
            {
                return typeIndex
            }
        }
        return -1
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        return nil
//        switch tableView
//        {
//        case self.propertiesTableView:
//
//            // No out-of-bounds crashes please.
//            if row < self.sortedProperties.count
//            {
//                // Instantiate a view for the cell.
//                guard let propertyCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerPropertyDetailCell"), owner: self) as? SwaggerPropertyDetailTableViewCell else
//                {
//                    return nil
//                }
//
//                // Configure the view and return it.
//                propertyCell.buttonDelegate = self
//                propertyCell.configureForProperty(self.sortedProperties[row])
//                return propertyCell
//            }
//            else if row == self.sortedProperties.count
//            {
//                // Instantiate a view for the cell.
//                guard let newPropertyCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerNewPropertyCell"), owner: self) as? SwaggerModelNewPropertyTableCell else
//                {
//                    return nil
//                }
//                newPropertyCell.delegate = self
//                return newPropertyCell
//            }
//            else
//            {
//                return nil
//            }
//
//        case self.referencesTableView:
//
//            // No out-of-bounds crashes please.
//            guard row < self.sortedReferences.count else
//            {
//                return nil
//            }
//
//            // Instantiate a view for the cell.
//            guard let referenceCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerModelReferenceCell"), owner: self) as? SwaggerModelReferenceTableViewCell else
//            {
//                return nil
//            }
//
//            // Configure the view and return it.
//            referenceCell.configureForContainer(self.sortedReferences[row])
//            return referenceCell
//
//        default:
//            return nil
//        }
    }
    
    // MARK:- ModalDialogDelegate
    
    /**
     This is triggered when the user dismisses the property editor via the ok/save button.
     Need to update the properties data source and reload the table.
     */
    func dismissedWithOK(dialog: NSViewController)
    {
//        guard let editorVC = dialog as? SwaggerPropertyEditorViewController, let property = editorVC.property else
//        {
//            return
//        }
//
//        // Grab the new property and store it in sortedReferences
//        if self.launchEditorInEditMode
//        {
//            // Since we edited an existing property, no need to re-add it to the data source.
//            // We do still want to resort though, b/c the name may have changed.
//        }
//        else
//        {
//            self.sortedProperties.append(property)
//        }
//        self.sortedProperties.sort { $0.propertyName < $1.propertyName }
//        self.propertiesTableView.reloadData()
    }
    
    /**
     This is triggered when the user dismisses the property editor via the cancel button.
     */
    func dismissedWithCancel(dialog: NSViewController)
    {
        // Don't care...
    }
    
    // MARK:- Event Handlers
    
    @IBAction func productsButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func responsesButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func saveButtonPressed(_ sender: NSButton)
    {
    }
}
