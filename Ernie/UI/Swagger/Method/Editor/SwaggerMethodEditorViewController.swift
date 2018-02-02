//
//  SwaggerMethodEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/2/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerMethodEditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, ModalDialogDelegate, NSComboBoxDataSource, SwaggerModelNewPropertyTableCellDelegate, SwaggerArgumentDetailTableViewCellDelegate
{
    var modalDelegate: ModalDialogDelegate?
    var method: SwaggerMethod?
    private var sortedArguments: [SwaggerMethodArgument] = []
    private var comboBoxesInitialized = false
    private var sortedMethodTypes: [SwaggerMethodTypeEnum] = [.DELETE, .EVENT, .GET, .POST, .PUT]
    private var launchEditorInEditMode = false
    private var argumentForEditor: SwaggerMethodArgument?
    private var productsForEditor: [SwaggerProductEnum] = []
    private var responsesForEditor: [SwaggerResponse] = []
    private var tagsForEditor: [String] = []

    @IBOutlet weak var methodNameTextField: NSTextField!
    @IBOutlet weak var methodDescriptionTextField: NSTextField!
    @IBOutlet weak var methodSummaryTextField: NSTextField!
    @IBOutlet weak var methodTypeComboBox: NSComboBox!
    @IBOutlet weak var productsButton: NSButton!
    @IBOutlet weak var responsesButton: NSButton!
    @IBOutlet weak var tagsButton: NSButton!
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
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?)
    {
        if let editorVC = segue.destinationController as? SwaggerMethodProductsViewController
        {
            editorVC.modalDelegate = self
            editorVC.products = self.productsForEditor
            editorVC.title = "\(self.method?.methodName ?? "") Products"
        }
        else if let editorVC = segue.destinationController as? SwaggerMethodResponsesViewController
        {
            editorVC.modalDelegate = self
            editorVC.responses = self.responsesForEditor
            editorVC.title = "\(self.method?.methodName ?? "") Responses"
        }
        else if let editorVC = segue.destinationController as? SwaggerMethodTagsViewController
        {
            editorVC.modalDelegate = self
            editorVC.configureWithTags(self.tagsForEditor)
            editorVC.title = "\(self.method?.methodName ?? "") Tags"
        }
        else if let editorVC = segue.destinationController as? SwaggerMethodArgumentEditorViewController
        {
            editorVC.modalDelegate = self
            editorVC.argument = self.argumentForEditor
            editorVC.title = "\(self.method?.methodName ?? "") Arguments"
        }
    }
    
    // MARK:- Private Methods
    
    private func configureForMethod()
    {
        self.productsForEditor = self.method?.methodProducts ?? []
        self.responsesForEditor = self.method?.methodResponses ?? []
        self.tagsForEditor = self.method?.methodTags ?? []
        self.methodNameTextField.stringValue = self.method?.methodName ?? ""
        self.methodDescriptionTextField.stringValue = self.method?.methodDescription ?? ""
        self.methodSummaryTextField.stringValue = self.method?.methodSummary ?? ""
        self.sortedArguments = self.method?.methodArguments.sorted { $0.argumentName < $1.argumentName } ?? []
        self.methodTypeComboBox.stringValue = self.method?.methodType.rawValue ?? "GET"
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
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        // One row per method argument + 1 for the "new argument" row.
        return self.sortedArguments.count + 1
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        // No out-of-bounds crashes please.
        if row < self.sortedArguments.count
        {
            // Instantiate a view for the cell.
            guard let argumentCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerMethodArgumentTableViewCell"), owner: self) as? SwaggerMethodArgumentTableViewCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            argumentCell.delegate = self
            argumentCell.configureFor(argument: self.sortedArguments[row])
            return argumentCell
        }
        else if row == self.sortedArguments.count
        {
            // Instantiate a view for the cell.
            guard let newArgumentCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerNewPropertyCell"), owner: self) as? SwaggerModelNewPropertyTableCell else
            {
                return nil
            }
            newArgumentCell.newButton.title = "New Argument"
            newArgumentCell.delegate = self
            return newArgumentCell
        }
        else
        {
            return nil
        }
    }
    
    // MARK:- ModalDialogDelegate
    
    /**
     This is triggered when the user dismisses child editor via the ok/save button.
     Need to update the properties data source and reload the table.
     */
    func dismissedWithOK(dialog: NSViewController)
    {
        // If we're coming back from the arguments editor, then reload the arguments table.
        if let argumentEditor = dialog as? SwaggerMethodArgumentEditorViewController, let argument = argumentEditor.argument
        {
            if !self.launchEditorInEditMode
            {
                self.sortedArguments.append(argument)
                self.sortedArguments.sort(by: { (arg1, arg2) -> Bool in
                    return arg1.argumentName < arg2.argumentName
                })
            }
            self.argumentsTableView.reloadData()
        }
        else if let productsEditor = dialog as? SwaggerMethodProductsViewController
        {
            self.productsForEditor = productsEditor.products
        }
        else if let tagsEditor = dialog as? SwaggerMethodTagsViewController
        {
            self.tagsForEditor = tagsEditor.sortedTags
        }
        else if let responsesEditor = dialog as? SwaggerMethodResponsesViewController
        {
            self.responsesForEditor = responsesEditor.responses ?? []
        }
    }
    
    /**
     This is triggered when the user dismisses the property editor via the cancel button.
     */
    func dismissedWithCancel(dialog: NSViewController)
    {
        // Don't care...
    }
    
    // MARK:- SwaggerArgumentDetailTableViewCellDelegate
    
    /**
     This is triggered when the user taps on the edit button in one of the argument detail cells.
     Need to launch the argument editor and set up internals so that we can pass along the
     property that is to be edited.
     */
    func editButtonPressed(sender: SwaggerMethodArgumentTableViewCell, argument: SwaggerMethodArgument?)
    {
        self.launchEditorInEditMode = true
        self.argumentForEditor = argument
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toArgumentEditor"), sender: self)
    }
    
    /**
     This is triggered when the user taps on the delete button in one of the argument detail cells.
     Need to remove that property from the data source and reload the table.
     */
    func deleteButtonPressed(sender: SwaggerMethodArgumentTableViewCell, argument: SwaggerMethodArgument?)
    {
        // Locate the argument in our data source.
        var indexOfDeletion = 0
        for existingArgument in self.sortedArguments
        {
            if existingArgument === argument
            {
                break
            }
            indexOfDeletion += 1
        }
        
        // Remove the argument from our data source.
        if indexOfDeletion < self.sortedArguments.count
        {
            self.sortedArguments.remove(at: indexOfDeletion)
        }
        
        // Update the UI.
        self.argumentsTableView.reloadData()
    }
    
    // MARK:- SwaggerModelNewPropertyTableCellDelegate
    
    /**
     This is triggered when the user taps on the new argument button in the last property cell.
     Need to launch the argument editor for creating a new argument.
     */
    func newButtonPressed(sender: SwaggerModelNewPropertyTableCell)
    {
        self.launchEditorInEditMode = false
        self.argumentForEditor = nil
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toArgumentEditor"), sender: self)
    }
    
    // MARK:- Event Handlers
    
    @IBAction func rowDoubleClicked(_ sender: NSTableView)
    {
        // Out-of-range protection before selecting which argument to launch the editor for.
        guard self.argumentsTableView.selectedRow < self.sortedArguments.count else
        {
            return
        }
        
        // Launch the editor for the argument that was double-clicked.
        self.launchEditorInEditMode = true
        self.argumentForEditor = self.sortedArguments[self.argumentsTableView.selectedRow]
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toArgumentEditor"), sender: self)
    }
    
    @IBAction func productsButtonPressed(_ sender: NSButton)
    {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toMethodProducts"), sender: self)
    }
    
    @IBAction func responsesButtonPressed(_ sender: NSButton)
    {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toMethodResponses"), sender: self)
    }
    
    @IBAction func tagsButtonPressed(_ sender: NSButton)
    {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toMethodTags"), sender: self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func saveButtonPressed(_ sender: NSButton)
    {
        // Must have a method name.
        guard self.methodNameTextField.stringValue.count > 0 else
        {
            return
        }
        let methodName = self.methodNameTextField.stringValue
        
        // Must have a method type.
        guard let methodType = SwaggerMethodTypeEnum(rawValue: self.methodTypeComboBox.stringValue) else
        {
            return
        }
        
        // Create a new method object if needed.
        if self.method == nil
        {
            self.method = SwaggerMethod(name: methodName, type: methodType)
        }
        
        // Copy the UI info over to the method object.
        self.method?.methodName = methodName
        self.method?.methodType = methodType
        self.method?.methodDescription = self.methodDescriptionTextField.stringValue
        self.method?.methodSummary = self.methodSummaryTextField.stringValue
        self.method?.methodArguments = self.sortedArguments
        self.method?.methodTags = self.tagsForEditor
        self.method?.methodProducts = self.productsForEditor
        self.method?.methodResponses = self.responsesForEditor
        
        // Save the changes to core data.
        self.method?.refreshCoreDataObject(autoSave: true)
        
        // Leave and inform the delegate.
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
}
