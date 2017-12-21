//
//  SwaggerPropertyEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 12/20/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerPropertyEditorViewController: NSViewController, NSComboBoxDataSource
{
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var requiredCheckBox: NSButton!
    @IBOutlet weak var arrayCheckBox: NSButton!
    @IBOutlet weak var dataTypeComboBox: NSComboBox!
    @IBOutlet weak var formatComboBox: NSComboBox!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var okButton: NSButton!
    
    var property: SwaggerModelProperty?
    var modalDelegate: ModalDialogDelegate?
    
    var sortedPrimitiveTypes: [String] = []
    var sortedModelNames: [String] = []
    var orderedDataTypes: [String] = []
    var sortedFormats: [String] = []
    
    // MARK:- Event Handlers
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func okButtonPressed(_ sender: NSButton)
    {
        if self.property == nil
        {
            //self.property = SwaggerModelProperty(name: "", dataType: <#T##SwaggerDataType#>)
        }
        
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
    
    // MARK:- NSComboBoxDataSource
    
    func numberOfItems(in comboBox: NSComboBox) -> Int
    {
        switch comboBox
        {
        case self.dataTypeComboBox:
            return self.orderedDataTypes.count
            
        case self.formatComboBox:
            return self.sortedFormats.count
            
        default:
            return 0
        }
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any?
    {
        guard index < self.orderedDataTypes.count else
        {
            return nil
        }
        return self.orderedDataTypes[index]
    }
}
