//
//  SwaggerContainerImportConfirmViewController.swift
//  Ernie
//
//  Created by Randy Haid on 2/5/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

class SwaggerContainerImportConfirmViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, SwaggerContainerMethodTableCellDelegate, SwaggerContainerModelTableCellDelegate
{
    var container: SwaggerContainer?
    private var sortedMethods: [SwaggerMethod] = []
    private var selectedMethodsLookupByName: [String : Bool] = [:]
    private var sortedModels: [SwaggerObjectModel] = []
    private var selectedModelsLookupByName: [String : Bool] = [:]
    var modalDelegate: ModalDialogDelegate?
    
    @IBOutlet weak var containerCheckBox: NSButton!
    @IBOutlet weak var methodsTableView: NSTableView!
    @IBOutlet weak var modelsTableView: NSTableView!
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.buildDataSources()
        self.refreshUIForContainer()
        if let jsonDictionary = self.container?.generateSwaggerJson()
        {
            print((jsonDictionary as NSDictionary).description)
        }
    }
    
    // MARK:- Event Handlers
    
    @IBAction func saveButtonPressed(_ sender: NSButton)
    {
        // If we have a container and the user wants to save it, we can use the container's save feature.
        if let container = self.container, self.containerCheckBox.state == NSControl.StateValue.on
        {
            // Update the container to have the selected methods.
            var selectedMethods: [SwaggerMethod] = []
            for method in self.sortedMethods
            {
                if self.selectedMethodsLookupByName[method.methodName] ?? false
                {
                    selectedMethods.append(method)
                }
            }
            container.containerMethods = selectedMethods
            
            // Update the container to have the selected models.
            var selectedModels: [SwaggerObjectModel] = []
            for model in self.sortedModels
            {
                if self.selectedModelsLookupByName[model.modelName] ?? false
                {
                    selectedModels.append(model)
                }
            }
            container.containerModels = selectedModels
            
            // Save the container (which cascades to save the methods and models).
            container.refreshCoreDataObject(autoSave: true)
        }
        else
        {
            // Add each selected method to core data.
            for method in self.sortedMethods
            {
                if self.selectedMethodsLookupByName[method.methodName] ?? false
                {
                    method.refreshCoreDataObject()
                }
            }
            
            // Add each selected model to core data.
            for model in self.sortedModels
            {
                if self.selectedModelsLookupByName[model.modelName] ?? false
                {
                    model.refreshCoreDataObject()
                }
            }
            
            // Save the methods and models we just added.
            try? AppDelegate.mainManagedObjectContext().save()
        }
        
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
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
    
    // MARK:- Data Source Generation
    
    private func buildDataSources()
    {
        guard let container = self.container else
        {
            self.sortedMethods = []
            self.sortedModels = []
            return
        }
        
        self.sortedMethods = container.containerMethods.sorted  { $0.methodName < $1.methodName }
        for method in self.sortedMethods
        {
            self.selectedMethodsLookupByName[method.methodName] = true
        }
        self.sortedModels = container.containerModels.sorted  { $0.modelName < $1.modelName }
        for model in self.sortedModels
        {
            self.selectedModelsLookupByName[model.modelName] = true
        }
    }
    
    private func refreshUIForContainer()
    {
        if let container = self.container
        {
            self.containerCheckBox.title = "\(container.containerTitle ?? "<Empty>") (\(container.containerDescription ?? "<Empty>")"
            self.containerCheckBox.state = NSControl.StateValue.on
        }
        else
        {
            self.containerCheckBox.title = "<Empty>"
            self.containerCheckBox.state = NSControl.StateValue.off
        }
        
        self.methodsTableView.reloadData()
        self.modelsTableView.reloadData()
    }
}
