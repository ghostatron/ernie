//
//  SwaggerContainerEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/24/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

class SwaggerContainerEditorViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, SwaggerContainerMethodTableCellDelegate, SwaggerContainerModelTableCellDelegate
{
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var ownerTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var methodsTableView: NSTableView!
    @IBOutlet weak var modelsTableView: NSTableView!
    
    var modalDelegate: ModalDialogDelegate?
    var container: SwaggerContainer?
    private var sortedMethods: [SwaggerMethod] = []
    private var selectedMethodsLookupByName: [String : Bool] = [:]
    private var sortedModels: [SwaggerObjectModel] = []
    private var selectedModelsLookupByName: [String : Bool] = [:]
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureForContainer()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?)
    {
        if let editorVC = segue.destinationController as? SwaggerBodyViewController
        {
            editorVC.configureForContainer(self.container)
        }
    }
    
    // MARK:- Private Methods
    
    private func configureForContainer()
    {
        // Round up all the available methods and models and initially flag them as not selected.
        self.sortedMethods = SwaggerMethod.getAllMethods().sorted  { $0.methodName < $1.methodName }
        for method in self.sortedMethods
        {
            self.selectedMethodsLookupByName[method.methodName] = false
        }
        self.sortedModels = SwaggerObjectModel.getAllModels(sorted: true)
        for model in self.sortedModels
        {
            self.selectedModelsLookupByName[model.modelName] = false
        }
        
        // Populate the UI based on our container situation.
        if let container = self.container
        {
            self.nameTextField.stringValue = container.containerTitle ?? ""
            self.ownerTextField.stringValue = container.containerOwner ?? ""
            self.descriptionTextField.stringValue = container.containerDescription ?? ""
            
            // Update our lookups for any methods and models that are already in this container.
            for method in container.containerMethods
            {
                self.selectedMethodsLookupByName[method.methodName] = true
            }
            for model in container.containerModels
            {
                self.selectedModelsLookupByName[model.modelName] = true
            }
        }
        else
        {
            self.nameTextField.stringValue = ""
            self.ownerTextField.stringValue = ""
            self.descriptionTextField.stringValue = ""
        }
    }
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
        case self.methodsTableView:
            // One row per method
            return self.sortedMethods.count
            
        case self.modelsTableView:
            // One row per model.
            return self.sortedModels.count
            
        default:
            return 0
        }
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        switch tableView
        {
        case self.methodsTableView:
            // No out-of-bounds crashes please.
            guard row <= self.sortedMethods.count else
            {
                return nil
            }
            
            // Instantiate a view for the cell.
            guard let methodCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerContainerMethodTableCell"), owner: self) as? SwaggerContainerMethodTableCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            methodCell.delegate = self
            let methodForCell = self.sortedMethods[row]
            methodCell.configureFor(method: methodForCell, isSelected: self.selectedMethodsLookupByName[methodForCell.methodName] ?? false)
            return methodCell

        case self.modelsTableView:
            // No out-of-bounds crashes please.
            guard row <= self.sortedModels.count else
            {
                return nil
            }
            
            // Instantiate a view for the cell.
            guard let modelCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerContainerModelTableCell"), owner: self) as? SwaggerContainerModelTableCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            modelCell.delegate = self
            let modelForCell = self.sortedModels[row]
            modelCell.configureFor(model: modelForCell, isSelected: self.selectedModelsLookupByName[modelForCell.modelName] ?? false)
            return modelCell

        default:
            return nil
        }
    }
    
    // MARK:- SwaggerContainerMethodTableCellDelegate
    
    func swaggerContainerMethodCell(_ cell: SwaggerContainerMethodTableCell, method: SwaggerMethod?, wasSelected: Bool)
    {
        guard let toggledMethod = method else
        {
            return
        }
        self.selectedMethodsLookupByName[toggledMethod.methodName] = wasSelected
    }
    
    // MARK:- SwaggerContainerModelTableCellDelegate
    
    func swaggerContainerModelCell(_ cell: SwaggerContainerModelTableCell, model: SwaggerObjectModel?, wasSelected: Bool)
    {
        guard let toggledModel = model else
        {
            return
        }
        self.selectedModelsLookupByName[toggledModel.modelName] = wasSelected
    }
    
    // MARK:- Event Handlers
    
    @IBAction func generateSwaggerButtonPressed(_ sender: NSButton)
    {
        if let jsonSwagger = self.container?.generateSwaggerJson()
        {
            let jsonString = (jsonSwagger as NSDictionary).description
            print(jsonString)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func saveButtonPressed(_ sender: NSButton)
    {
        // Must have a container name.
        guard self.nameTextField.stringValue.count > 0 else
        {
            return
        }
        
        // Create a new container object if needed.
        if self.container == nil
        {
            self.container = SwaggerContainer()
        }
        
        // Copy the UI info over to the container object.
        self.container?.containerTitle = self.nameTextField.stringValue
        self.container?.containerOwner = self.ownerTextField.stringValue
        self.container?.containerDescription = self.descriptionTextField.stringValue
        
        var selectedMethods: [SwaggerMethod] = []
        for method in self.sortedMethods
        {
            if self.selectedMethodsLookupByName[method.methodName] ?? false
            {
                selectedMethods.append(method)
            }
        }
        self.container?.containerMethods = selectedMethods

        var selectedModels: [SwaggerObjectModel] = []
        for model in self.sortedModels
        {
            if self.selectedModelsLookupByName[model.modelName] ?? false
            {
                selectedModels.append(model)
            }
        }
        self.container?.containerModels = selectedModels
        
        // Save the container to core data.
        self.container?.refreshCoreDataObject(autoSave: true)
    }
}
