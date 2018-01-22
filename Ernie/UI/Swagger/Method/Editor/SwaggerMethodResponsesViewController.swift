//
//  SwaggerMethodResponsesViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/3/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerMethodResponsesViewController: NSViewController
{
    @IBOutlet weak var responsesTableView: NSTableView!
    @IBOutlet weak var httpCodeTextField: NSTextField!
    @IBOutlet weak var dataTypeComboBox: NSComboBox!
    @IBOutlet weak var descriptionTextView: NSScrollView!
    
    var modalDelegate: ModalDialogDelegate?
    var responses: [SwaggerResponse]?
    
    // MARK:- Event Handlers
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
    }
    
    @IBAction func okButtonPressed(_ sender: NSButton)
    {
    }
}
