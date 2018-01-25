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
    
    // MARK:- Private Methods
    
    private func configureForContainer()
    {
        var container: SwaggerContainer! = self.container
        if container == nil
        {
            container = SwaggerContainer()
        }
        
        self.nameTextField.stringValue = container.containerTitle ?? ""
        self.ownerTextField.stringValue = container.containerOwner ?? ""
        self.descriptionTextField.stringValue = container.containerDescription ?? ""
        
        self.sortedMethods = SwaggerMethod.getAllMethods().sorted  { $0.methodName < $1.methodName }
        for method in self.sortedMethods
        {
            self.selectedMethodsLookupByName[method.methodName] = false
        }
        for method in container.containerMethods
        {
            self.selectedMethodsLookupByName[method.methodName] = true
        }
        
        self.sortedModels = SwaggerObjectModel.getAllModels(sorted: true)
        for model in self.sortedModels
        {
            self.selectedModelsLookupByName[model.modelName] = false
        }
        for model in container.containerModels
        {
            self.selectedModelsLookupByName[model.modelName] = true
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
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func saveButtonPressed(_ sender: NSButton)
    {
        // TODO: Save
    }
}
