//
//  SwaggerMethodArgumentTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/3/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

protocol SwaggerArgumentDetailTableViewCellDelegate
{
    func deleteButtonPressed(sender: SwaggerMethodArgumentTableViewCell, argument: SwaggerMethodArgument?)
    func editButtonPressed(sender: SwaggerMethodArgumentTableViewCell, argument: SwaggerMethodArgument?)
}

class SwaggerMethodArgumentTableViewCell: NSTableCellView
{
    @IBOutlet weak var argumentInfoLabel: NSTextField!
    private(set) var argument: SwaggerMethodArgument?
    var delegate: SwaggerArgumentDetailTableViewCellDelegate?
    
    func configureFor(argument: SwaggerMethodArgument)
    {
        self.argument = argument
        self.argumentInfoLabel.stringValue = argument.swiftSignature()
    }
    
    @IBAction func deleteButtonPressed(_ sender: NSButton)
    {
        self.delegate?.deleteButtonPressed(sender: self, argument: self.argument)
    }
    
    @IBAction func editButtonPressed(_ sender: NSButton)
    {
        self.delegate?.editButtonPressed(sender: self, argument: self.argument)
    }
}
