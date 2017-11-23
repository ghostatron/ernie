//
//  MiniAppsViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/22/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class MiniAppsViewController: NSViewController
{
    /// The data source for the mini apps table.
    var allMiniAppsAlphabetized: [MiniApp] = []
    
    /// The data source for the containers table.
    var selectedMiniAppContainersAlphabetized: [Container] = []
    
    // MARK:- IBOutlet Properties

    @IBOutlet weak var editButton: NSButton!
    @IBOutlet weak var miniAppNameLabel: NSTextField!
    @IBOutlet weak var miniAppFolderLabel: NSTextField!
    @IBOutlet weak var miniAppDescriptionLabel: NSTextField!
    @IBOutlet weak var miniAppsTableView: NSTableView!
    @IBOutlet weak var containersTableView: NSTableView!
    
    @IBAction func addMiniAppButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func editButtonPressed(_ sender: NSButton)
    {
    }
}
