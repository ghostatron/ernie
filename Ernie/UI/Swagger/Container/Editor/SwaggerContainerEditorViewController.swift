//
//  SwaggerContainerEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/24/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

class SwaggerContainerEditorViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var ownerTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var methodsTableView: NSTableView!
    @IBOutlet weak var modelsTableView: NSTableView!
    
    var modalDelegate: ModalDialogDelegate?
    var container: SwaggerContainer?
    private var sortedMethods: [SwaggerMethod] = []
    private var sortedModels: [SwaggerObjectModel] = []
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureForContainer()
    }
    
    // MARK:- Private Methods
    
    private func configureForContainer()
    {
        guard let container = self.container else
        {
            return
        }
        
        self.nameTextField.stringValue = container.containerTitle ?? ""
        self.ownerTextField.stringValue = container.containerOwner ?? ""
        self.descriptionTextField.stringValue = container.containerDescription ?? ""
        self.sortedMethods = container.containerMethods.sorted { $0.methodName < $1.methodName }
        self.sortedModels = container.containerModels.sorted { $0.modelName < $1.modelName }
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
            //containerCell.delegate = self
            //containerCell.configureFor(container: self.sortedContainers[row])
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
            //containerCell.delegate = self
            //containerCell.configureFor(container: self.sortedContainers[row])
            return modelCell

        default:
            return nil
        }
        
        
    }
    
    // MARK:- Event Handlers
    
    @IBAction func addMethodButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func addModelButtonPressed(_ sender: NSButton)
    {
    }
    
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
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
}
