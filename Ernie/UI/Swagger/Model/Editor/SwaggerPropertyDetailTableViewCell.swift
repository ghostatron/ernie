//
//  SwaggerPropertyDetailTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 12/19/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

protocol SwaggerPropertyDetailTableViewCellDelegate
{
    func deleteButtonPressed(sender: SwaggerPropertyDetailTableViewCell, property: SwaggerModelProperty?)
    func editButtonPressed(sender: SwaggerPropertyDetailTableViewCell, property: SwaggerModelProperty?)
}

class SwaggerPropertyDetailTableViewCell: NSTableCellView
{
    @IBOutlet weak var propertyInfoLabel: NSTextField!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var editButton: NSButton!
    
    private(set) var property: SwaggerModelProperty?
    var buttonDelegate: SwaggerPropertyDetailTableViewCellDelegate?
    
    func configureForProperty(_ property: SwaggerModelProperty)
    {
        self.property = property
        self.propertyInfoLabel.stringValue = "\(property.propertyIsRequired ? "* " : "")\(property.propertyName) [\(property.propertyDataType.stringValue())]"
    }
    
    @IBAction func deleteButtonPressed(_ sender: NSButton)
    {
        self.buttonDelegate?.deleteButtonPressed(sender: self, property: self.property)
    }
    
    @IBAction func editButtonPressed(_ sender: NSButton)
    {
        self.buttonDelegate?.editButtonPressed(sender: self, property: self.property)
    }
}
