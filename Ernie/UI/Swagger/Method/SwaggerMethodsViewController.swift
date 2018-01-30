//
//  SwaggerMethodsViewConstroller.swift
//  Ernie
//
//  Created by Randy Haid on 12/29/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerMethodsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, ModalDialogDelegate
{
    @IBOutlet weak var methodsTableView: NSTableView!
    @IBOutlet weak var argumentsTableView: NSTableView!
    @IBOutlet weak var newButton: NSButton!
    @IBOutlet weak var editButton: NSButton!
    
    private var sortedMethods: [SwaggerMethod] = []
    private var selectedMethod: SwaggerMethod?
    private var selectedMethodSortedArguments: [SwaggerMethodArgument] = []
    private var launchEditorInEditMode = false
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.buildMethodDataSource()
        self.configureViewForSelectedMethod()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = "Methods"
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?)
    {
        if let editorVC = segue.destinationController as? SwaggerMethodEditorViewController
        {
            editorVC.method = self.selectedMethod
            editorVC.title = self.launchEditorInEditMode ? "\(self.selectedMethod?.methodName ?? "Method") [Edit]" : "Method [New]"
            editorVC.modalDelegate = self
        }
        else if let editorVC = segue.destinationController as? SwaggerMethodFromSwiftViewController
        {
            editorVC.modalDelegate = self
        }
    }
    
    // MARK:- Event Handlers
    
    @IBAction func newButtonPressed(_ sender: NSButton)
    {
        self.launchEditorInEditMode = false
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toSwiftMethodSignature"), sender: self)
    }
    
    @IBAction func editButtonPressed(_ sender: NSButton)
    {
        if self.selectedMethod != nil
        {
            self.launchEditorInEditMode = true
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toMethodEditor"), sender: self)
        }
    }
    
    // MARK:- ModalDialogDelegate
    
    // If the "Edit" or "New" dialog returns with "OK", then we need to refresh the page.
    func dismissedWithOK(dialog: NSViewController)
    {
        if let dialog = dialog as? SwaggerMethodFromSwiftViewController
        {
            self.selectedMethod = dialog.method
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toMethodEditor"), sender: self)
        }
        else
        {
            // Reload the table.
            self.buildMethodDataSource()
            self.methodsTableView.reloadData()
            self.configureViewForSelectedMethod()
        }
    }
    
    func dismissedWithCancel(dialog: NSViewController)
    {
        if dialog is SwaggerMethodFromSwiftViewController
        {
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toMethodEditor"), sender: self)
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
            
        case self.argumentsTableView:
            // One row per argument for the selected method.
            return self.selectedMethodSortedArguments.count
            
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
            guard row < self.sortedMethods.count else
            {
                return nil
            }
            
            // Instantiate a view for the cell.
            guard let methodlCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerMethodRow"), owner: self) as? SwaggerMethodTableViewCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            methodlCell.configureFor(method: self.sortedMethods[row])
            return methodlCell
            
        case self.argumentsTableView:
            
            // No out-of-bounds crashes please.
            guard row < self.selectedMethodSortedArguments.count else
            {
                return nil
            }
            
            // Instantiate a view for the cell.
            guard let argumentCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerArgumentRow"), owner: self) as? SwaggerArgumentTableViewCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            argumentCell.configureFor(argument: self.selectedMethodSortedArguments[row])
            return argumentCell
            
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
        
        // We only care if the user selects someting in the methods table.
        if tableView == self.methodsTableView
        {
            // Figure out which method was just selected.
            if tableView.selectedRow < 0 || tableView.selectedRow >= self.sortedMethods.count
            {
                // No method selected, make sure to wipe out the arguments data source.
                self.selectedMethod = nil
                self.selectedMethodSortedArguments = []
                self.editButton.isEnabled = false
            }
            else
            {
                // Update the selected method and update the arguments data source.
                self.selectedMethod = self.sortedMethods[tableView.selectedRow]
                if let argumentsArray = self.selectedMethod?.methodArguments
                {
                    self.selectedMethodSortedArguments = argumentsArray.sorted { $0.argumentName < $1.argumentName }
                }
                else
                {
                    self.selectedMethodSortedArguments = []
                }
                self.editButton.isEnabled = true
            }
            
            // Update the UI for that newly selected container.
            self.configureViewForSelectedMethod()
        }
    }
    
    // MARK:- Private Methods
    
    private func buildMethodDataSource()
    {
        let unsortedMethods = SwaggerMethod.getAllMethods()
        self.sortedMethods = unsortedMethods.sorted { $0.methodName < $1.methodName }
    }
    
    private func configureViewForSelectedMethod()
    {
        self.editButton.isEnabled = (self.selectedMethod != nil)
        self.argumentsTableView.reloadData()
    }
}
