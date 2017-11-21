//
//  ContainerViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/20/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class ContainerViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, ModalDialogDelegate
{
    /// The container currently selected in the containers table view.
    private var selectedContainer: Container?
    
    /// The data sources for the containers and mini-app tables.
    private var containersAlphabetized: [Container] = []
    private var selectedContainerMiniAppsAlphabetized: [MiniApp] = []
    
    // MARK:- IBOutlet Properties

    @IBOutlet weak var containersTableView: NSTableView!
    @IBOutlet weak var miniAppsTableView: NSTableView!
    @IBOutlet weak var containerNameLabel: NSTextField!
    @IBOutlet weak var containerFolderLabel: NSTextField!
    @IBOutlet weak var containerDescriptionLabel: NSTextField!
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.containersAlphabetized = self.allContainers() ?? []
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = "Containers"
    }
    
    // MARK:- Event Handlers

    @IBAction func regenerateButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func editButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func addContainerButtonPress(_ sender: NSButton)
    {
    }
    
    // MARK:- Private Methods
    
    private func allContainers() -> [Container]?
    {
        let request: NSFetchRequest<Container> = Container.fetchRequest()
        let alphabeticalSort = NSSortDescriptor(key: "containerName", ascending: true)
        request.sortDescriptors = [alphabeticalSort]
        let containers = try? AppDelegate.mainManagedObjectContext().fetch(request)
        return containers
    }
    
    private func configureViewForSelectedContainer()
    {
        if let container = self.selectedContainer
        {
            self.containerNameLabel.isHidden = false
            self.containerFolderLabel.isHidden = false
            self.containerDescriptionLabel.isHidden = false
            self.miniAppsTableView.isHidden = false
            
            self.containerNameLabel.stringValue = container.containerName ?? "<No Name>"
            self.containerFolderLabel.stringValue = container.containerFolder ?? "<No Folder>"
            self.containerDescriptionLabel.stringValue = container.containerDescription ?? ""
            self.miniAppsTableView.reloadData()
        }
        else
        {
            self.containerNameLabel.isHidden = true
            self.containerFolderLabel.isHidden = true
            self.containerDescriptionLabel.isHidden = false
            self.miniAppsTableView.isHidden = true
            
            self.containerDescriptionLabel.stringValue = "Select a container on the left to view it's mini apps."
        }
    }
    
    // MARK:- ModalDialogDelegate
    
    // If the "Edit" or "Add" dialog returns with "OK", then we need to refresh the page.
    func dismissedWithOK()
    {
        // Reload the table.
        self.containersAlphabetized = self.allContainers() ?? []
        self.containersTableView.reloadData()
    }
    
    func dismissedWithCancel()
    {
        // Don't care
    }
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
        case self.containersTableView:
            // One row per container.
            return self.containersAlphabetized.count
            
        case self.miniAppsTableView:
            // One row per mini app for the selected container.
            if let container = self.selectedContainer
            {
                return container.miniApps?.count ?? 0
            }
            else
            {
                return 0
            }
            
        default:
            return 0
        }
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        switch tableView
        {
        case self.containersTableView:
            
            // No out-of-bounds crashes please.
            guard row < self.containersAlphabetized.count else
            {
                return nil
            }
            
            // Instantiate a view for the cell.
            guard let containerCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "containerRow"), owner: self) as? ContainersTableViewCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            containerCell.configureForContainer(self.containersAlphabetized[row])
            return containerCell
            
        case self.miniAppsTableView:
            
            // No out-of-bounds crashes please.
            guard row < self.selectedContainerMiniAppsAlphabetized.count else
            {
                return nil
            }
            
            // Instantiate a view for the cell.
            guard let miniAppCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "miniAppRow"), owner: self) as? ContainersMiniAppTableViewCell else
            {
                return nil
            }
            
            // Configure the view and return it.
            miniAppCell.configureForMiniApp(self.selectedContainerMiniAppsAlphabetized[row])
            return miniAppCell
            
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
        
        // We only care if the user selects someting in the container table.
        if tableView == self.containersTableView
        {
            // Figure out which container was just selected.
            if tableView.selectedRow < 0 || tableView.selectedRow >= self.containersAlphabetized.count
            {
                // No container selected, make sure to wipe out the mini-apps data source.
                self.selectedContainer = nil
                self.selectedContainerMiniAppsAlphabetized = []
            }
            else
            {
                // Update the selected container and update the mini-apps data source.
                self.selectedContainer = self.containersAlphabetized[tableView.selectedRow]
                if let miniAppsArray = self.selectedContainer?.miniApps?.allObjects as? [MiniApp]
                {
                    self.selectedContainerMiniAppsAlphabetized = miniAppsArray.sorted { $0.miniAppName ?? "" < $1.miniAppName ?? "" }
                }
            }
            
            // Update the UI for that newly selected container.
            self.configureViewForSelectedContainer()
        }
    }
}
